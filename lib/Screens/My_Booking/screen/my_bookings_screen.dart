import 'package:eatit/Screens/My_Booking/screen/order_details_container.dart';
import 'package:flutter/material.dart';
import 'package:eatit/models/my_booking_modal.dart';
import 'package:eatit/Screens/My_Booking/service/My_Booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  static const routeName = "/my-bookings-screen";
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isLoading = false;
  String? _error;
  List<UserElement> _orders = [];
  late MyBookingService _bookingService;

  @override
  void initState() {
    super.initState();
    // Initialize the booking service
    _bookingService = MyBookingService();
    // Fetch order details when screen loads
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    // Cancel any ongoing requests when screen is disposed
    _bookingService.cancelRequest();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _bookingService.fetchOrderDetails();
      setState(() {
        if (response != null) {
          _orders = response.user;
        } else {
          _error = 'Failed to fetch orders';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrderDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrderDetails,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final UserElement order = _orders[index];
          return OrderDetailsContainer(
            order: order,
          );
        },
      ),
    );
  }
}
