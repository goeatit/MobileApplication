import 'dart:ui';

import 'package:eatit/Screens/My_Booking/screen/my_bookings_screen.dart';
import 'package:eatit/Screens/cart_screen/widget/cart_item.dart';
import 'package:eatit/Screens/order_summary/screen/bill_summary.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            restaurantImageUrl: cartItems.first.restaurantImageUrl, // Add this
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, MyBookingsScreen.routeName);
            },
            child: Padding(
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
          )
        ],
      ),
      body: _cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Consumer<CartProvider>(builder: (ctx, cartProvider, child) {
                return Column(
                  children: [
                    Expanded(
                        child: AnimatedList(
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
                    )),
                  ],
                );
              }))
          : _buildEmptyCartView(),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top section with check orders text and arrow
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    child: SvgPicture.asset("assets/svg/arrowCartEmpty.svg"),
                  ),
                  const Positioned(
                    top: 80,
                    right: 70,
                    child: Text(
                      'Check your orders here',
                      style: TextStyle(
                        color: Color(0xFFF8951D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Empty cart image
          Image.asset(
            'assets/images/emptyCart.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          // Empty cart message
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              color: Color(0xFFF8951D),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      CartItemWithDetails cartItemWithDetails, Animation<double> animation) {
    // Calculate image index based on restaurant ID to ensure consistent image
    final imageIndex =
        cartItemWithDetails.id.hashCode % 10; // Will give numbers 0-9
    final restaurantImage = 'assets/images/restaurant${imageIndex}.png';

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
              'locationOfRestaurant':cartItemWithDetails.cartItem.location,
              'imageUrl': restaurantImage, // Using the calculated image path
              'cuisineType': "Indian • Biryani", // Add appropriate cuisine type
              'priceRange': "₹1200-₹1500 for two",
              'rating': cartItemWithDetails.cartItem.dish.ratting.toString(),
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
  final String restaurantImageUrl;

  CartItemWithDetails({
    required this.cartItem,
    required this.restaurantName,
    required this.orderType,
    required this.allItems,
    required this.id,
    required this.restaurantImageUrl,
  });
}
