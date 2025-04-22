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
import 'package:eatit/models/saved_restaurant_model.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:eatit/provider/saved_restaurants_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:provider/provider.dart';
import 'package:eatit/Screens/order_summary/widget/coupon_section_widget.dart';

class BillSummaryScreen extends StatefulWidget {
  static const routeName = "/bill-summary";
  final String name;
  final String orderType;
  final String id;
  final String imageUrl;
  final String cuisineType;
  final String priceRange;
  final double rating;
  final String locationOfRestaurant;

  const BillSummaryScreen({
    super.key,
    required this.name,
    required this.orderType,
    required this.id,
    required this.imageUrl,
    required this.cuisineType,
    required this.priceRange,
    required this.rating,
    required this.locationOfRestaurant,
  });

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
  String? currentLocation;
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
        currentLocation = currentData!.location;
        String? lat = currentData?.latitude;
        String? long = currentData?.longitude;
        print(currentData?.recommendedDishes);

        // Update order provider with current data
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.updateWithCurrentData(currentData!);
        orderProvider.setLocationAndlatlong(currentLocation, lat, long);

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
              backgroundColor: Colors.white,
              titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
              title: Column(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFF8951D),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unavailable Items',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.only(
                top: 5,
                left: 24,
                right: 24,
                bottom: 20,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'The following items are no longer available:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ...unavailableItems
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                '• ${item['dishName']}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 10),
                    Text(
                      'Would you like to remove these items and continue?',
                      style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF666666),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: Color(0xFFF8951D),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel Order',
                            style:
                                Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                      color: const Color(0xFFF8951D),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _removeUnavailableItems();
                            if (changedPrices.any(
                                (change) => change.containsKey('newPrice'))) {
                              _showPriceChangesDialog();
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF8951D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Remove Items',
                            style:
                                Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
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
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
            title: Column(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFF8951D),
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Price Changes',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
              ],
            ),
            contentPadding: const EdgeInsets.only(
              top: 5,
              left: 24,
              right: 24,
              bottom: 20,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'The following price changes have been detected:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ...priceChanges
                      .map((change) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '• ${change['dishName']} price changed from ₹${change['oldPrice']} to ₹${change['newPrice']}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 10),
                  Text(
                    'Would you like to continue with the new prices?',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: Color(0xFFF8951D),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel Order',
                          style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFF8951D),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _updatePriceChanges();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF8951D),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Accept & Continue',
                          style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
          title: Column(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF8951D),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Restaurant Closed',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.only(
            top: 5,
            left: 24,
            right: 24,
            bottom: 20,
          ),
          content: const Text(
            'This restaurant is currently closed. Please try again later or choose another restaurant.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF8951D),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
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
        builder: (BuildContext ctx) => AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
          title: Column(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF8951D),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Remove Item',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.only(
            top: 5,
            left: 24,
            right: 24,
            bottom: 20,
          ),
          content: Text(
            'Are you sure you want to remove ${item.dish.dishId.dishName} from your cart?',
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF666666),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFFF8951D),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFFF8951D),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
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
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF8951D),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Remove',
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
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
                            Flexible(
                              child: Text(
                                currentLocation ?? "Fetching location",
                                style: const TextStyle(
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
                  Consumer<SavedRestaurantsProvider>(
                    builder: (context, savedProvider, child) {
                      final isSaved =
                          savedProvider.isRestaurantSaved(widget.id);
                      return GestureDetector(
                        onTap: () async {
                          if (isSaved) {
                            // Show delete confirmation
                            bool? remove = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                titlePadding:
                                    const EdgeInsets.only(top: 20, bottom: 5),
                                title: Column(
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Color(0xFFF8951D),
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Remove Restaurant',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.only(
                                  top: 5,
                                  left: 24,
                                  right: 24,
                                  bottom: 20,
                                ),
                                content: Text(
                                  'Remove ${widget.name} from saved?',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFF666666),
                                      ),
                                ),
                                actions: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              side: const BorderSide(
                                                color: Color(0xFFF8951D),
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color:
                                                        const Color(0xFFF8951D),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFF8951D),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              'Remove',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (remove == true) {
                              await savedProvider.toggleSaveRestaurant(
                                SavedRestaurant(
                                  id: widget.id,
                                  imageUrl: widget.imageUrl,
                                  restaurantName: widget.name,
                                  cuisineType: widget.cuisineType,
                                  priceRange: widget.priceRange,
                                  rating: widget.rating,
                                  location: widget.locationOfRestaurant,
                                  // lat: widget.latitude,
                                  // long: widget.longitude,
                                ),
                              );
                            }
                          } else {
                            // Direct save
                            await savedProvider.toggleSaveRestaurant(
                              SavedRestaurant(
                                id: widget.id,
                                imageUrl: widget.imageUrl,
                                restaurantName: widget.name,
                                cuisineType: widget.cuisineType,
                                priceRange: widget.priceRange,
                                rating: widget.rating,
                                location: widget.locationOfRestaurant,
                                // lat: widget.latitude,
                                // long: widget.longitude,
                              ),
                            );
                          }
                        },
                        child: SvgPicture.asset(
                          isSaved
                              ? 'assets/svg/Saved.svg'
                              : 'assets/svg/save_appbar.svg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.scaleDown,
                        ),
                      );
                    },
                  ),
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
                                                    'id': widget.id,
                                                    'imageUrl': widget.imageUrl,
                                                    'cuisineType':
                                                        widget.cuisineType,
                                                    'priceRange':
                                                        widget.priceRange,
                                                    'rating': widget.rating,
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
                                          // Add the recommended dishes section here
                                          if (!isLoading &&
                                              !isCheckingConditions)
                                            _buildRecommendedDishes(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Only show number of people for dine-in orders
                                    if (widget.orderType.toLowerCase() ==
                                        "dine-in")
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
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
                                    const SizedBox(height: 10),
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
                                    const SizedBox(height: 20),

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
                                      child: const CouponSectionWidget(),
                                    ),
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

  Widget _buildRecommendedDishes() {
    if (currentData?.recommendedDishes == null ||
        currentData!.recommendedDishes.isEmpty) {
      return const SizedBox.shrink();
    }

    // List of food images to cycle through
    final List<String> foodImages = [
      "assets/images/burgers.png",
      "assets/images/pizza.png",
      "assets/images/healthy.png",
      "assets/images/home_style.png",
      "assets/images/image1.png",
      "assets/images/image2.png",
      "assets/images/image3.png",
      "assets/images/image4.png",
      "assets/images/image5.png",
      "assets/images/image6.png",
      "assets/images/image7.png",
      "assets/images/image8.png",
      "assets/images/image9.png",
      "assets/images/image10.png",
    ];

    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: currentData!.recommendedDishes.length,
              itemBuilder: (context, index) {
                final dish = currentData!.recommendedDishes[index];
                // Get image based on index, cycling through the list
                final imageIndex = index % foodImages.length;
                final imageUrl = foodImages[imageIndex];

                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    child: DishCard(
                      name: dish.dishId.dishName,
                      price: "₹${dish.resturantDishPrice}",
                      isAvailable: dish.available, // Add this line

                      imageUrl: imageUrl, // Use the cycled image
                      calories: '200 cal',
                      quantity: context
                          .watch<CartProvider>()
                          .getQuantity(widget.id, widget.orderType, dish.id),
                      onAddToCart: () {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);

                        final cartItem = CartItem(
                            id: dish.id,
                            restaurantName: widget.name,
                            orderType: widget.orderType,
                            dish: dish,
                            quantity: 1,
                            location: currentLocation ?? '',
                            restaurantImageUrl: widget.imageUrl);

                        cartProvider.addToCart(
                            widget.id, widget.orderType, cartItem);

                        // Update the order provider
                        final orderProvider =
                            Provider.of<OrderProvider>(context, listen: false);
                        orderProvider.updateCartItems(
                          cartProvider.getItemsByOrderTypeAndRestaurant(
                              widget.id, widget.orderType),
                        );
                      },
                      onIncrement: () {
                        final cartProvider = context.read<CartProvider>();
                        cartProvider.incrementQuantity(
                            widget.id, widget.orderType, dish.id);

                        // Update the order provider
                        final orderProvider =
                            Provider.of<OrderProvider>(context, listen: false);
                        orderProvider.updateCartItems(
                          cartProvider.getItemsByOrderTypeAndRestaurant(
                              widget.id, widget.orderType),
                        );
                      },
                      onDecrement: () {
                        final cartProvider = context.read<CartProvider>();
                        cartProvider.decrementQuantity(
                            widget.id, widget.orderType, dish.id);

                        // Update the order provider
                        final orderProvider =
                            Provider.of<OrderProvider>(context, listen: false);
                        orderProvider.updateCartItems(
                          cartProvider.getItemsByOrderTypeAndRestaurant(
                              widget.id, widget.orderType),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
