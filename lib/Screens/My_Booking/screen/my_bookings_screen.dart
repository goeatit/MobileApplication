import 'package:eatit/Screens/My_Booking/screen/order_details_container.dart';
import 'package:eatit/main.dart';
import 'package:eatit/provider/my_booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:eatit/models/my_booking_modal.dart';
import 'package:eatit/Screens/My_Booking/service/My_Booking_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../api/api_repository.dart';

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
  late MyBookingService? _bookingService;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize the booking service
  }

  @override
  void dispose() {
    // Cancel any ongoing requests when screen is disposed
    _bookingService!.cancelRequest();
    _bookingService = null; // Clear the service reference
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_servicesInitialized) {
      _bookingService =
          MyBookingService(apiRepository: context.read<ApiRepository>());
      _fetchOrderDetails();
      _servicesInitialized = true;
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _bookingService!.fetchOrderDetails();
      setState(() {
        if (response != null) {
          // _orders = response.user;
          _orders.clear();
          context.read<MyBookingProvider>().setMyBookings(response.user);
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
    _orders = context.watch<MyBookingProvider>().myBookings;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SvgPicture.asset(
              'assets/svg/graybackArrow.svg',
              width: 31,
              height: 30,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF4F4F4),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/emptyBooking.png',
              width: 400, // Adjust the width as needed
              height: 400, // Adjust the height as needed
              fit: BoxFit.contain,
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
            onOrderCancelled: _fetchOrderDetails,
          );
        },
      ),
    );
  }
}
