import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:eatit/Screens/profile/screen/order_details_container.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // body: Consumer<OrderProvider>(
      //   builder: (context, orderProvider, child) {
      //     if (orderProvider.getOrders.isEmpty) {
      //       return const Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(
      //               Icons.receipt_long_outlined,
      //               size: 64,
      //               color: Colors.grey,
      //             ),
      //             SizedBox(height: 16),
      //             Text(
      //               'No Bookings Found',
      //               style: TextStyle(
      //                 fontSize: 18,
      //                 color: Colors.grey,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //           ],
      //         ),
      //       );
      //     }
      //
      //     return ListView.builder(
      //       padding: const EdgeInsets.all(16),
      //       itemCount: orderProvider.getOrders.length,
      //       itemBuilder: (context, index) {
      //         return OrderDetailsContainer(
      //           order: orderProvider.getOrders[index],
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
