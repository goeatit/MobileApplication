import 'package:eatit/Screens/cart_screen/widget/cart_item.dart';
import 'package:eatit/Screens/order_summary/screen/bill_summary.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  static const routeName = "/cart-page";
  const CartPage({super.key});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<CartItemWithDetails> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _updateCartItems();
  }

  void _updateCartItems() {
    final items = context.read<CartProvider>().restaurantCarts;
    _cartItems = [];

    items.forEach((id, orderTypes) {
      orderTypes.forEach((orderType, cartItems) {
        if (cartItems.isNotEmpty) {
          _cartItems.add(CartItemWithDetails(
            cartItem: cartItems.first,
            restaurantName: cartItems.first.restaurantName,
            id: id,
            orderType: orderType,
            allItems: cartItems,
          ));
        }
      });
    });
  }

  void removeItem(int index) {
    final removedItem = _cartItems[index];
    _cartItems.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        ),
        child: CartItemWidget(
          restaurantName: removedItem.restaurantName,
          orderType: removedItem.orderType,
          imageUrl: 'https://via.placeholder.com/100',
          items: removedItem.allItems
              .map((itm) => '${itm.quantity} x ${itm.dish.dishId.dishName}')
              .toList(),
          instructions: 'Make one of them spicy',
          icon: const Icon(Icons.remove),
          restaurantId: removedItem.id,
          allItems: removedItem.allItems,
          index: index,
        ),
      ),
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            const SizedBox(height: 16),
            Expanded(
              child: _cartItems.isNotEmpty
                  ? AnimatedList(
                      key: _listKey,
                      initialItemCount: _cartItems.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index, animation) {
                        final cartItemWithDetails = _cartItems[index];
                        return SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOutCubic)),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                BillSummaryScreen.routeName,
                                arguments: {
                                  'name': cartItemWithDetails.restaurantName,
                                  'orderType': cartItemWithDetails.orderType,
                                  'id': cartItemWithDetails.id,
                                },
                              );
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: CartItemWidget(
                              restaurantName:
                                  cartItemWithDetails.restaurantName,
                              orderType: cartItemWithDetails.orderType,
                              imageUrl: 'https://via.placeholder.com/100',
                              items: cartItemWithDetails.allItems
                                  .map((itm) =>
                                      '${itm.quantity} x ${itm.dish.dishId.dishName}')
                                  .toList(),
                              instructions: 'Make one of them spicy',
                              icon: const Icon(Icons.remove),
                              restaurantId: cartItemWithDetails.id,
                              allItems: cartItemWithDetails.allItems,
                              index: index,
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
  final List<CartItem> allItems;

  CartItemWithDetails({
    required this.cartItem,
    required this.restaurantName,
    required this.orderType,
    required this.allItems,
    required this.id,
  });
}
