import 'package:eatit/Screens/order_summary/screen/no_of_people.dart';
import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillSummaryScreen extends StatefulWidget {
  static const routeName = "/bill-summary";
  final String name;
  final String orderType;

  const BillSummaryScreen(
      {super.key, required this.name, required this.orderType});

  @override
  State<StatefulWidget> createState() => _BillSummaryScreen();
}

class _BillSummaryScreen extends State<BillSummaryScreen> {
  late List<CartItem> cartItems = [];
  bool isLoading = true;

  fetchData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartItems = cartProvider.getItemsByOrderTypeAndRestaurant(
          widget.name, widget.orderType);
    } catch (error) {
      // Handle errors appropriately
      print("Error fetching cart items: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double subTotal = cartItems.fold(
        0, (sum, item) => sum + (item.dish.resturantDishPrice * item.quantity));
    double gst = subTotal * 0.18; // Assuming GST is 18%
    double grandTotal = subTotal + gst;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            constraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
            icon: Container(
              child: Stack(
                children: [
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 22,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new,
                    size: 22,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/restaurant.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Sub Total"),
                              Text("₹${subTotal.toStringAsFixed(2)}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("GST (18%)"),
                              Text("₹${gst.toStringAsFixed(2)}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Grand Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                    const Text("Tip Something", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (widget.orderType == 'Dine-in') {
                          Navigator.pushNamed(
                              context, SelectPeopleScreen.routeName);
                        } else {
                          Navigator.pushNamed(context, ReserveTime.routeName);
                        }
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
