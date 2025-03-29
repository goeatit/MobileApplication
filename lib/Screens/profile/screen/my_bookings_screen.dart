import 'package:eatit/Screens/profile/screen/order_details_container.dart';
import 'package:flutter/material.dart';
import 'package:eatit/models/order_model.dart';
import 'package:eatit/provider/order_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final OrderProvider _orderProvider = OrderProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _orderProvider.getOrders.isEmpty
          ? const Center(
              child: Text(
                'No bookings found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _orderProvider.getOrders.length,
              itemBuilder: (context, index) {
                return OrderDetailsContainer(
                  order: _orderProvider.getOrders[index],
                );
              },
            ),
    );
  }
}
