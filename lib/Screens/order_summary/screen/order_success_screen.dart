import 'package:eatit/Screens/order_summary/screen/order_confirmation_screen.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class OrderSuccessScreen extends StatefulWidget {
  static const routeName = '/order-success-screen';
  final String? location;
  final double? lat;
  final double? long;

  const OrderSuccessScreen({
    super.key,
    this.location,
    this.lat,
    this.long,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // In the initState method, update the Future.delayed block:
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();

    // Modified navigation logic
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        // Get the cart items to access location
        final cartItems =
            cartProvider.restaurantCarts[orderProvider.restaurantId];
        final location = cartItems?.values.first.first.location ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              restaurantId: orderProvider.restaurantId ?? '',
              restaurantName: orderProvider.restaurantName ?? '',
              location: location, // Add the location parameter
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated check mark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Animated text
              FadeTransition(
                opacity: _opacityAnimation,
                child: const Text(
                  'Order Successfully Placed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _opacityAnimation,
                child: const Text(
                  'Thank you for your order',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
