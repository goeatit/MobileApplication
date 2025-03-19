import 'package:dio/dio.dart';
import 'package:eatit/Screens/order_summary/screen/no_of_people.dart';
import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/Screens/order_summary/service/restaurant_service.dart';
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

  fetchData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.id, widget.orderType);

      // Update order provider with cart items
      orderProvider.updateCartItems(cartItems);
    } catch (error) {
      // Handle errors appropriately
      print("Error fetching cart items: $error");
    }
  }

  fetchCurrentData() async {
    setState(() {
      isCheckingConditions = true;
    });

    try {
      await fetchData(); // First get cart items

      final response = await restaurantService.getCurrentData(
          widget.id, widget.name, cartItems);

      if (response != null) {
        currentData = CurrentData.fromJson(response.data);

        // Update order provider with current data
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.updateWithCurrentData(currentData!);

        // Check for price changes and restaurant availability
        final checkResult = restaurantService.checkPriceChangesAndAvailability(
            currentData!, cartItems);

        setState(() {
          isRestaurantClosed = checkResult['isRestaurantClosed'];
          changedPrices =
              List<Map<String, dynamic>>.from(checkResult['changedPrices']);
          hasChanges = checkResult['hasChanges'];
          isLoading = false;
          isCheckingConditions = false;
        });

        // If there are changes, show the appropriate dialog
        if (hasChanges) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showChangesDialog();
          });
        }
      } else {
        setState(() {
          isLoading = false;
          isCheckingConditions = false;
        });
      }
    } on DioException catch (e) {
      print("Error fetching current data: $e");
      setState(() {
        isLoading = false;
        isCheckingConditions = false;
      });
      _showErrorDialog("Network Error",
          "Could not connect to the server. Please try again.");
    } catch (error) {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We're now handling dialog display in the fetchCurrentData method
  }

  @override
  Widget build(BuildContext context) {
    // Use the OrderProvider for calculations
    final orderProvider = Provider.of<OrderProvider>(context);
    double subTotal = orderProvider.subTotal;
    double gst = orderProvider.gst;
    double grandTotal = orderProvider.grandTotal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/svg/graybackArrow.svg',
              width: 30,
              height: 30,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
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
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width:
                              80, // Same size as diameter of previous CircleAvatar (radius * 2)
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12), // 12px border radius
                            image: const DecorationImage(
                              image: AssetImage('assets/images/restaurant.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // Add textAlign property to center the text
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Container(
                              height: 35,
                              width: 100,
                              decoration: BoxDecoration(
                                color: neutrals100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  widget.orderType,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                      // selectedIndex == 0 ? Colors.black : Colors.grey,
                                      ),
                                ),
                              )),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bill Summary",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                                Radius.circular(12)), // Added border radius
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0D000000),
                                offset: Offset(0, 2.15),
                                blurRadius: 21.46,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var item in cartItems)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item.dish.dishId.dishName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "₹${item.dish.resturantDishPrice * item.quantity}",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Sub Total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹${subTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "GST (18%)",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹${gst.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Grand Total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹${grandTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text("Tip Something",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: isRestaurantClosed || cartItems.isEmpty
                              ? null // Disable button if restaurant is closed or cart is empty
                              : () {
                                  if (widget.orderType == 'Dine-in') {
                                    Navigator.pushNamed(
                                        context, SelectPeopleScreen.routeName);
                                  } else {
                                    Navigator.pushNamed(
                                        context, ReserveTime.routeName);
                                  }
                                },
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
