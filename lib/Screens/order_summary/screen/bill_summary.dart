import 'package:dio/dio.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn/widget/dish_card_widget.dart';
import 'package:eatit/Screens/order_summary/screen/no_of_people.dart';
import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/Screens/order_summary/service/restaurant_service.dart';
import 'package:eatit/Screens/order_summary/widget/Order_summary_cart.dart';
import 'package:eatit/Screens/order_summary/widget/Select_no_people_widget.dart';
import 'package:eatit/Screens/order_summary/widget/Time_slot_reserve_widget.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:provider/provider.dart';

class BillSummaryScreen extends StatefulWidget {
  static const routeName = "/bill-summary";
  final String name;
  final String orderType;
  final String id;

  const BillSummaryScreen(
      {super.key,
      required this.name,
      required this.orderType,
      required this.id});

  @override
  State<StatefulWidget> createState() => _BillSummaryScreen();
}

class _BillSummaryScreen extends State<BillSummaryScreen> {
  late List<CartItem> cartItems = [];
  bool isLoading = true;
  bool isCheckingConditions = true;
  bool hasChanges = false;
  List<Map<String, dynamic>> changedPrices = [];
  bool isRestaurantClosed = false;
  RestaurantService restaurantService = RestaurantService();
  CurrentData? currentData;
  // Add cancellation token for API requests
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    // Initialize the order provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.initializeOrder(
        id: widget.id,
        name: widget.name,
        type: widget.orderType,
        items: [], // Will be updated in fetchData
      );
      fetchCurrentData();
    });
  }

  late OrderProvider orderProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    orderProvider = Provider.of<OrderProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // Cancel any ongoing API requests
    _cancelToken.cancel("Screen disposed");

    // Clear memory and ongoing operations for local variables only
    currentData = null;
    changedPrices.clear();
    // Do NOT clear cartItems as it's needed by the CartProvider

    // Only reset the order provider state which is temporary
    if (!mounted) return;
    orderProvider.clearOrder();

    super.dispose();
  }

  fetchData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Get a reference to cart items - do NOT modify these directly
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with cart items
      orderProvider.updateCartItems(List.from(cartItems));
    } catch (error) {
      // Handle errors appropriately
      print("Error fetching cart items: $error");
    }
  }

  fetchCurrentData() async {
    if (_cancelToken.isCancelled) return;

    setState(() {
      isCheckingConditions = true;
    });

    try {
      await fetchData(); // This gets cart items from CartProvider

      // Store a local copy of cart items for bill summary calculations
      List<CartItem> localCartItems = List.from(cartItems);

      // Early return if we don't have any cart items to check
      if (localCartItems.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
            isCheckingConditions = false;
          });
        }
        return;
      }

      // Pass the _cancelToken to the service call
      final response = await restaurantService.getCurrentDataWithCancelToken(
          widget.id, widget.name, localCartItems, _cancelToken);

      if (response != null && !_cancelToken.isCancelled) {
        currentData = CurrentData.fromJson(response.data);

        // Update order provider with current data
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.updateWithCurrentData(currentData!);

        // Check for price changes and restaurant availability
        final checkResult = restaurantService.checkPriceChangesAndAvailability(
            currentData!, localCartItems);

        if (!mounted || _cancelToken.isCancelled) return;

        setState(() {
          isRestaurantClosed = checkResult['isRestaurantClosed'];
          changedPrices =
              List<Map<String, dynamic>>.from(checkResult['changedPrices']);
          hasChanges = checkResult['hasChanges'];
          isLoading = false;
          isCheckingConditions = false;
        });

        // If there are changes, show the appropriate dialog
        if (hasChanges && mounted && !_cancelToken.isCancelled) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showChangesDialog();
          });
        }
      } else if (mounted) {
        setState(() {
          isLoading = false;
          isCheckingConditions = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted || _cancelToken.isCancelled) return;

      print("Error fetching current data: $e");
      setState(() {
        isLoading = false;
        isCheckingConditions = false;
      });
      _showErrorDialog("Network Error",
          "Could not connect to the server. Please try again.");
    } catch (error) {
      if (!mounted || _cancelToken.isCancelled) return;

      print("Error fetching current data: $error");
      setState(() {
        isLoading = false;
        isCheckingConditions = false;
      });
      _showErrorDialog(
          "Error", "An unexpected error occurred. Please try again.");
    }
  }

  void _updatePriceChanges() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    for (var change in changedPrices) {
      if (change.containsKey('newPrice')) {
        // Update the price in the cart
        cartProvider.updateItemPrice(
            widget.id, change['dishId'], change['newPrice']);
      }
    }

    // Refresh cart items
    setState(() {
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with updated cart items
      orderProvider.updateCartItems(cartItems);
    });
  }

  void _handleUnavailableItems() {
    // Filter out only the unavailable items
    final unavailableItems = changedPrices
        .where((change) =>
            change.containsKey('available') && change['available'] == false)
        .toList();

    if (unavailableItems.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Unavailable Items'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The following items are no longer available:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...unavailableItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('• ${item['dishName']}',
                                style: const TextStyle(color: Colors.red)),
                          ))
                      .toList(),
                  const SizedBox(height: 10),
                  const Text(
                      'Would you like to remove these items and continue?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('Cancel Order'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _removeUnavailableItems();
                  // Show price changes dialog if there are any
                  if (changedPrices
                      .any((change) => change.containsKey('newPrice'))) {
                    _showPriceChangesDialog();
                  }
                },
                child: const Text('Remove Items & Continue'),
              ),
            ],
          ),
        ),
      );
    } else if (changedPrices.isNotEmpty) {
      // If there are only price changes, show that dialog
      _showPriceChangesDialog();
    }
  }

  void _removeUnavailableItems() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    for (var change in changedPrices) {
      if (change.containsKey('available') && change['available'] == false) {
        // Remove unavailable items
        cartProvider.removeItem(widget.id, change['dishId']);
      }
    }

    // Refresh cart items
    setState(() {
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with updated cart items
      orderProvider.updateCartItems(cartItems);
    });
  }

  void _showPriceChangesDialog() {
    // Filter out only the price changes
    final priceChanges = changedPrices
        .where((change) => change.containsKey('newPrice'))
        .toList();

    if (priceChanges.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Price Changes'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The following price changes have been detected:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...priceChanges
                      .map((change) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '• ${change['dishName']} price changed from ₹${change['oldPrice']} to ₹${change['newPrice']}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 10),
                  const Text('Would you like to continue with the new prices?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('Cancel Order'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _updatePriceChanges(); // Apply the price changes only when user accepts
                },
                child: const Text('Accept & Continue'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showRestaurantClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Restaurant Closed'),
          content: const Text(
            'This restaurant is currently closed. Please try again later or choose another restaurant.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCartWithNewPrices() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    for (var change in changedPrices) {
      if (change.containsKey('newPrice')) {
        // Update the price in the cart
        cartProvider.updateItemPrice(
            widget.id, change['dishId'], change['newPrice']);
      }

      if (change.containsKey('available') && change['available'] == false) {
        // Remove unavailable items
        cartProvider.removeItem(widget.id, change['dishId']);
      }
    }

    // Refresh cart items
    cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
        widget.id, widget.orderType);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangesDialog() {
    if (isRestaurantClosed) {
      _showRestaurantClosedDialog();
    } else if (changedPrices.any((change) =>
        change.containsKey('available') && change['available'] == false)) {
      _handleUnavailableItems();
    } else if (changedPrices.any((change) => change.containsKey('newPrice'))) {
      _showPriceChangesDialog();
    }
  }

  void _removeItem(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Save item for potential undo
    final removedItem = item;

    // Remove item from cart
    cartProvider.removeItem(widget.id, item.dish.id);

    // Refresh cart items
    setState(() {
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with updated cart items
      orderProvider.updateCartItems(cartItems);
    });

    // Show a snackbar to confirm removal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.dish.dishId.dishName} removed from cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Add the item back
            cartProvider.addToCart(widget.id, widget.orderType, removedItem);

            // Refresh cart items
            setState(() {
              cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
                  widget.id, widget.orderType);

              // Update order provider with updated cart items
              orderProvider.updateCartItems(cartItems);
            });
          },
        ),
      ),
    );
  }

  void _incrementItem(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Increment the item quantity
    cartProvider.incrementQuantity(widget.id, widget.orderType, item.id);

    // Refresh cart items
    setState(() {
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with updated cart items
      orderProvider.updateCartItems(cartItems);
    });
  }

  void _decrementItem(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // If quantity is 1, show a confirmation dialog before removing
    if (item.quantity == 1) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove Item'),
          content: Text('Remove ${item.dish.dishId.dishName} from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();

                // Check if this is the last item in the cart
                if (cartItems.length == 1) {
                  // Remove the item
                  cartProvider.removeItem(widget.id, item.dish.id);

                  // Clear the order provider
                  orderProvider.clearOrder();

                  // Pop back to previous screen
                  Navigator.of(context).pop();
                } else {
                  _removeItem(item);
                }
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    } else {
      // Decrement the item quantity
      cartProvider.decrementQuantity(widget.id, widget.orderType, item.id);

      // Refresh cart items
      setState(() {
        cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
            widget.id, widget.orderType);

        // Update order provider with updated cart items
        orderProvider.updateCartItems(cartItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the OrderProvider for calculations
    final orderProvider = Provider.of<OrderProvider>(context);
    double subTotal = orderProvider.subTotal;
    double gst = orderProvider.gst;
    double grandTotal = orderProvider.grandTotal;

    // Check if required fields are filled
    bool isReadyToContinue = !isRestaurantClosed &&
        cartItems.isNotEmpty &&
        orderProvider.selectedTime != null &&
        orderProvider.selectedTime!.isNotEmpty;

    // For dine-in, also check number of people
    if (widget.orderType.toLowerCase() == "dine-in") {
      isReadyToContinue =
          isReadyToContinue && orderProvider.numberOfPeople.isNotEmpty;
    }

    return PopScope(
        onPopInvokedWithResult: (didPop, _) {
          // Only clear the order provider when back button is pressed
          // Do NOT clear the cart provider data
          final orderProvider =
              Provider.of<OrderProvider>(context, listen: false);
          orderProvider.clearOrder();
        },
        canPop: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  onTap: () {
                    // Only clear the order provider when back button is pressed
                    // Do NOT clear the cart provider data
                    final orderProvider =
                        Provider.of<OrderProvider>(context, listen: false);
                    orderProvider.clearOrder();
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    'assets/svg/graybackArrow.svg',
                    width: 31,
                    height: 30,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          textAlign: TextAlign.right,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: const Color(0xFF737373),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w100),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the row only takes necessary space
                          children: [
                            const Text(
                              "25 Min from location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Container(
                              height: 14, // Adjust height to match text
                              width: 3, // Thin vertical divider
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Flexible(
                              child: Text(
                                "Location",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        'assets/svg/save_appbar.svg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.scaleDown,
                      ))
                ],
              )),
          body: isCheckingConditions
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        "Checking menu availability...",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                )
              : isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Dismiss keyboard when tapping outside
                              FocusScope.of(context).unfocus();
                            },
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          // BoxShadow(
                                          //   color: Colors.black12,
                                          //   blurRadius: 6,
                                          //   offset: Offset(0, 3),
                                          // ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          for (var item in cartItems)
                                            CartItemOrderSummary(
                                              dishName:
                                                  item.dish.dishId.dishName,
                                              price:
                                                  item.dish.resturantDishPrice,
                                              quantity: item.quantity,
                                              totalPrice:
                                                  item.dish.resturantDishPrice *
                                                      item.quantity,
                                              isVeg:
                                                  item.dish.dishId.dishType == 0
                                                      ? true
                                                      : false,
                                              spiceLevel: "Extra Spicy",
                                              onRemove: () => _removeItem(item),
                                              onIncrement: () =>
                                                  _incrementItem(item),
                                              onDecrement: () =>
                                                  _decrementItem(item),
                                            ),
                                          const SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              // Navigate back to add more items
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  SingleRestaurantScreen
                                                      .routeName,
                                                  arguments: {
                                                    'name': widget.name,
                                                    'location': cartItems
                                                        .first.location,
                                                    'id': widget.id
                                                  });
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(Icons.add,
                                                    color: primaryColor),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Add items",
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/svg/WidgetAdd.svg',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.scaleDown,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Complete your meal with",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          // Add SingleChildScrollView for horizontal scrolling
                                          SizedBox(
                                            height:
                                                190, // Adjust height as needed for your DishCard
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  for (int i = 0;
                                                      i < 10;
                                                      i++) ...[
                                                    if (i > 0)
                                                      const SizedBox(
                                                          width:
                                                              2), // 2px gap between cards
                                                    SizedBox(
                                                      width:
                                                          150, // Adjust width as needed for your DishCard
                                                      child: DishCard(
                                                          name: 'Briyani',
                                                          quantity: 1,
                                                          price: '200',
                                                          imageUrl:
                                                              'assets/images/home_style.png',
                                                          calories: "200",
                                                          onAddToCart: () {},
                                                          onIncrement: () {},
                                                          onDecrement: () {}),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Only show number of people for dine-in orders
                                    if (widget.orderType.toLowerCase() ==
                                        "dine-in")
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: const [
                                            // BoxShadow(
                                            //   color: Colors.black12,
                                            //   blurRadius: 6,
                                            //   offset: Offset(0, 3),
                                            // ),
                                          ],
                                        ),
                                        child: const SelectNoPeopleWidget(),
                                      ),

                                    // Show time slots for all order types
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: const [
                                          // BoxShadow(
                                          //   color: Colors.black12,
                                          //   blurRadius: 6,
                                          //   offset: Offset(0, 3),
                                          // ),
                                        ],
                                      ),
                                      child: const TimeSlotsReserveWidget(),
                                    ),

                                    // Add bottom padding to ensure content isn't hidden behind the fixed button
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Fixed button at the bottom
                        Container(
                          decoration: const BoxDecoration(
                            //color: Colors.white,
                            boxShadow: [
                              // BoxShadow(
                              //   color: Colors.black12,
                              //   offset: Offset(0, -2),
                              //   blurRadius: 4,
                              //   spreadRadius: 1,
                              // ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: isReadyToContinue
                                  ? () {
                                      // If all required info is provided, go straight to confirmation/payment
                                      Navigator.pushNamed(context,
                                          OrderSummaryScreen.routeName);
                                    }
                                  : null,
                              child: const Text(
                                "Continue",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ));
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
