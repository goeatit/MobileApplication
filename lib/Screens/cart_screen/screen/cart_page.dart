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
  }

  @override
  void didChangeDependencies() {
    final restaurantCarts = context.watch<CartProvider>().restaurantCarts;
    _updateCartItems(restaurantCarts);
    super.didChangeDependencies();
  }

  void _updateCartItems(restaurantCarts) {
    final items = restaurantCarts;
    final newCartItems = <CartItemWithDetails>[];
    items.forEach((id, orderTypes) {
      orderTypes.forEach((orderType, cartItems) {
        if (cartItems.isNotEmpty) {
          newCartItems.add(CartItemWithDetails(
            cartItem: cartItems.first,
            restaurantName: cartItems.first.restaurantName,
            id: id,
            orderType: orderType,
            allItems: cartItems,
          ));
        }
      });
    });
    if (_cartItems.length <= newCartItems.length) {
      print("1st ");
      _listKey.currentState?.insertItem(newCartItems.length);
    } else {
      for (int i = _cartItems.length - 1; i >= newCartItems.length; i--) {
        _listKey.currentState?.removeItem(
            i,
            (context, animation) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOutCubic)),
                ),
                child: const SizedBox.shrink()));
      }
    }
    if (mounted) {
      setState(() {
        _cartItems = newCartItems;
      });
    }
  }

  void removeItem(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });

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
    final cartProvider =
        context.watch<CartProvider>(); // Ensures UI rebuilds when cart updates
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Add this line to remove the back arrow
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
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
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CartProvider>(builder: (ctx, cartProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: _cartItems.isNotEmpty
                      ? AnimatedList(
                          key: _listKey,
                          initialItemCount: _cartItems.length,
                          itemBuilder: (context, index, animation) {
                            if (index >= _cartItems.length) {
                              print(index);
                              return const SizedBox.shrink();
                            }
                            print("outside $index");
                            return _buildCartItem(_cartItems[index], animation);
                          },
                        )
                      : const Center(
                          child: Text(
                            'You have nothing in your cart!',
                            style: TextStyle(
                              color: Color(0xFF718EBF),
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
              ],
            );
          })),
    );
  }

  Widget _buildCartItem(
      CartItemWithDetails cartItemWithDetails, Animation<double> animation) {
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
          restaurantName: cartItemWithDetails.restaurantName,
          orderType: cartItemWithDetails.orderType,
          imageUrl: 'https://via.placeholder.com/100',
          items: cartItemWithDetails.allItems
              .map((itm) => '${itm.quantity} x ${itm.dish.dishId.dishName}')
              .toList(),
          instructions: 'Make one of them spicy',
          icon: const Icon(Icons.remove),
          restaurantId: cartItemWithDetails.id,
          allItems: cartItemWithDetails.allItems,
          index: _cartItems.indexOf(cartItemWithDetails),
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
