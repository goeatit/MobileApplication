import 'package:dio/dio.dart';
import 'package:eatit/Screens/order_summary/service/restaurant_service.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OrderSummaryScreen extends StatefulWidget {
  static const routeName = '/order-summary-screen';
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 15;
    double dashSpace = 10;
    double startX = 0;
    final paint = Paint()
      ..color = const Color(0xFFD4D4D4)
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  late Razorpay _razorpay;
  final restaurantService = RestaurantService();
  bool _isLoading = false;
  bool _isVerifyingPayment = false;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Set up event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  void _openRazorpay(String orderId) {
    try {
      // Get order details from provider
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final userProvider =
          Provider.of<UserModelProvider>(context, listen: false);
      final amount =
          (orderProvider.grandTotal * 100).toInt(); // Convert to paise

      var options = {
        'key': 'rzp_test_hFCEk6LC58uQgh', // Replace with your Razorpay Key ID
        'amount': amount, // Amount in paise
        'currency': 'INR',
        'name': orderProvider.restaurantName ?? 'Restaurant Order',
        'description': 'Payment for ${orderProvider.orderType} order',
        'order_id': orderId, // Use the order ID from the API response
        'prefill': {
          'contact': userProvider.userModel?.phoneNumber ?? '',
          'email': userProvider.userModel?.useremail ?? '',
        },
        'theme': {'color': '#F8951D'},
      };

      print("Opening Razorpay with order ID: $orderId");
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening payment gateway: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Successful: ${response.paymentId}");
    print("Order ID: ${response.orderId}");
    print("Signature: ${response.signature}");

    // Show loading overlay
    if (!mounted) return;
    setState(() {
      _isVerifyingPayment = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Your order has been placed.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Verify payment with backend
    await _verifyPayment(
      response.paymentId ?? '',
      response.orderId ?? '',
      response.signature ?? '',
    );

    // Check if widget is still mounted after async operation
    if (!mounted) return;

    // Get the order type to determine how many screens to pop
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDineIn = orderProvider.orderType?.toLowerCase() == "dine-in";

    // Clear the cart for this restaurant and order type
    if (orderProvider.restaurantId != null && orderProvider.orderType != null) {
      cartProvider.clearCart(
          orderProvider.restaurantId!, orderProvider.orderType!);
    }

    // Clear the order data after successful payment
    orderProvider.clearOrder();

    // For dine-in orders, pop 3 screens (summary, people, time)
    // For takeaway orders, pop 2 screens (summary, time)
    final screensToPop = isDineIn ? 4 : 3;

    // Pop the appropriate number of screens
    for (int i = 0; i < screensToPop; i++) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  // Method to verify payment with backend
  Future<void> _verifyPayment(
      String paymentId, String orderId, String signature) async {
    try {
      // Here you would call your backend API to verify the payment
      // This is a placeholder for the actual implementation
      print(
          "Verifying payment: PaymentID: $paymentId, OrderID: $orderId, Signature: $signature");

      // Example of how you might call your backend API
      final response = await restaurantService.verifyPayment(
          paymentId, orderId, signature, _orderId!);
      print("Payment verification response: $response");
      if (response?.statusCode == 200) {
        print("Payment verified successfully");
        // store the data for the future reference
      }
    } catch (e) {
      print("Error verifying payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Hide loading overlay if it's showing
    if (_isVerifyingPayment && mounted) {
      setState(() {
        _isVerifyingPayment = false;
      });
    }

    debugPrint("Payment Failed: ${response.code} - ${response.error}");
    // Show error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.error}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handleSubmitOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final response = await restaurantService.createOrder(
          orderProvider.restaurantId!,
          orderProvider.orderType!,
          orderProvider.restaurantName!,
          orderProvider.selectedTime!,
          orderProvider.numberOfPeople,
          orderProvider.grandTotal.toString(),
          cartProvider.getItemsByOrderTypeAndRestaurant(
              orderProvider.restaurantId!, orderProvider.orderType!));

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        if (response.statusCode == 201) {
          print("Order created response: ${response.data}");

          // Extract the order ID from the response
          final responseData = response.data;
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('payment') &&
              responseData['payment'] is Map<String, dynamic>) {
            final paymentData = responseData['payment'] as Map<String, dynamic>;
            final orderId = paymentData['id'] as String?;

            if (orderId != null) {
              setState(() {
                _orderId = orderId;
              });

              // Open Razorpay with the order ID
              _openRazorpay(orderId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Order ID not found in response'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Invalid response format'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order creation failed: ${response.data}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.response?.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order creation failed: ${e.response?.data}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order creation failed: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print("Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order creation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // Access the providers
    final orderProvider = Provider.of<OrderProvider>(context);
    final userProvider = Provider.of<UserModelProvider>(context);
    final user = userProvider.userModel;

    // Format date for display
    final now = DateTime.now();
    final date = "${now.day} ${_getMonthName(now.month)} ${now.year}";

    // Format currency
    String formatCurrency(double amount) {
      return '₹${amount.toStringAsFixed(2)}';
    }

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
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.grey.shade300,
              color: Colors.black,
            ),
          ),
        ),
            centerTitle: false,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // User Information
                _buildInfoRow("Name", user?.name ?? "Guest", isBold: true),
                _buildInfoRow(
                    "Phone Number",
                    user?.phoneNumber != null
                        ? "${user?.countryCode ?? ''} ${user?.phoneNumber ?? ''}"
                        : "Not provided",
                    isBold: true),
                _buildInfoRow("Email", user?.useremail ?? "Not provided",
                    isBold: true),

                // Order Information
                _buildInfoRow("Date", date, isBold: true),
                _buildInfoRow("Time", orderProvider.selectedTime ?? "",
                    isBold: true),

                // Conditionally show number of people for dine-in orders
                if (orderProvider.orderType?.toLowerCase() == "dine-in")
                  _buildInfoRow("Number of People",
                      "${orderProvider.numberOfPeople} People",
                      isBold: true),

 const SizedBox(height: 80), // Add some spacing
            // Dashed divider for subtotal section
            CustomPaint(
              size: const Size(double.infinity, 30),
              painter: DashedLinePainter(),
            ),
                // Order Totals
                _buildInfoRow(
                    "Subtotal", formatCurrency(orderProvider.subTotal),
                    isBold: true, isRightAligned: true),
                _buildInfoRow("Tax", formatCurrency(orderProvider.gst),
                    isRightAligned: true),
                _buildInfoRow(
                    "Grand Total", formatCurrency(orderProvider.grandTotal),
                    isBold: true, isRightAligned: true),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSubmitOrder,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Pay and Reserve",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Payment verification loading overlay
        if (_isVerifyingPayment)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Verifying payment...",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
  Widget _buildInfoRow(String title, String value,
      {bool isBold = false, bool isRightAligned = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isRightAligned
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
