import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OrderSummaryScreen extends StatefulWidget {
  static const routeName = '/order-summary-screen';
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Set up event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openRazorpay() {
    var options = {
      'key': 'rzp_test_hFCEk6LC58uQgh', // Replace with your Razorpay Key ID
      'amount': 22705, // Amount in paise (227.05 * 100)
      'currency': 'INR', // Change to 'INR' if you're using Indian Rupees
      'name': 'Your App Name',
      'description': 'Payment for reservation',
      'prefill': {
        'contact': '+12 3456 7890',
        'email': 'bijeet123@gmail.com',
      },
      'theme': {
        'color': '#F8951D'

      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Successful: ${response.paymentId}");
    // Navigate to success screen or show a success message
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Failed: ${response.code} - ${response.message}");
    // Show error message to the user
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(
          value: 0.8,
          backgroundColor: Colors.grey.shade300,
          color: Colors.black,
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
            _buildInfoRow("Name", "Bijeet Nath", isBold: true),
            _buildInfoRow("Phone Number", "+12 3456 7890", isBold: true),
            _buildInfoRow("Email", "bijeet123@gmail.com", isBold: true),
            _buildInfoRow("Date", "20 July 2025", isBold: true),
            _buildInfoRow("Time", "01:30PM", isBold: true),
            _buildInfoRow("Number of People", "2 People", isBold: true),
            const Divider(),
            _buildInfoRow("Subtotal", "\$206.45", isBold: true, isRightAligned: true),
            _buildInfoRow("Tax", "\$20.6", isRightAligned: true),
            _buildInfoRow("Grand Total", "\$227.05", isBold: true, isRightAligned: true),
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
                onPressed: _openRazorpay,
                child: const Text(
                  "Pay and Reserve",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isBold = false, bool isRightAligned = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isRightAligned ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
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
