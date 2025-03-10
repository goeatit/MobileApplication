import 'package:eatit/Screens/cart_screen/widget/cart_item.dart';
import 'package:eatit/Screens/order_summary/screen/bill_summary.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CartProvider>().restaurantCarts;
    // Flatten the cart items into a list of all items from Take-away and Dine-in order types
    List<CartItemWithDetails> allCartItems = [];

    items.forEach((id, orderTypes) {
      orderTypes.forEach((orderType, cartItems) {
        if (cartItems.isNotEmpty) {
          // Group all items for a single order type (Take-away or Dine-in) into one CartItemWithDetails
          allCartItems.add(CartItemWithDetails(
            cartItem: cartItems
                .first, // Just a placeholder for CartItem, you can use any item from the list
            restaurantName: cartItems.first.restaurantName,
            id: id,
            orderType: orderType,
            allItems: cartItems, // Pass all items of the same order type
          ));
        }
      });
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Container
            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFF8951D),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: Color(0xFFF8951D),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Spacing between header and list
            // Cart Items List
            Expanded(
              child: items.isNotEmpty
                  ? ListView.builder(
                      itemCount: allCartItems.length,
                      itemBuilder: (ctx, resIndex) {
                        final cartItemWithDetails = allCartItems[resIndex];

                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, BillSummaryScreen.routeName,
                                arguments: {
                                  'name': cartItemWithDetails.restaurantName,
                                  'orderType': cartItemWithDetails.orderType,
                                   'id': cartItemWithDetails.id,
                                });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: CartItemWidget(
                            restaurantName: cartItemWithDetails.restaurantName,
                            orderType: cartItemWithDetails.orderType,
                            imageUrl:
                                'https://via.placeholder.com/100', // Replace with actual image
                            items: cartItemWithDetails.allItems
                                .map((itm) =>
                                    '${itm.quantity} x ${itm.dish.dishId.dishName}')
                                .toList(),
                            instructions: 'Make one of them spicy',
                            icon: const Icon(
                              Icons.remove,
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Your cart is empty.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemWithDetails {
  final CartItem cartItem;
  final String restaurantName;
  final String orderType;
  final String id;
  final List<CartItem> allItems; // All items for the same order type

  CartItemWithDetails(
      {required this.cartItem,
      required this.restaurantName,
      required this.orderType,
      required this.allItems,
      required this.id});
}
