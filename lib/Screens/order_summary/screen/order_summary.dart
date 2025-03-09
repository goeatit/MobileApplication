import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
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
      'theme': {'color': '#F8951D'},
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
            _buildInfoRow("Name", "Bijeet Nath", isBold: true),
            const Divider(
              color: Color(0xFFD4D4D4),
            ),
            _buildInfoRow("Phone Number", "+12 3456 7890", isBold: true),
            const Divider(
              color: Color(0xFFD4D4D4),
            ),
            _buildInfoRow("Email", "bijeet123@gmail.com", isBold: true),
            const Divider(
              color: Color(0xFFD4D4D4),
            ),
            _buildInfoRow("Date", "20 July 2025", isBold: true),
            const Divider(
              color: Color(0xFFD4D4D4),
            ),
            _buildInfoRow("Time", "01:30PM", isBold: true),
            const Divider(
              color: Color(0xFFD4D4D4),
            ),
            _buildInfoRow("Number of People", "2 People", isBold: true),

            const SizedBox(height: 80), // Add some spacing
            // Dashed divider for subtotal section
            CustomPaint(
              size: const Size(double.infinity, 30),
              painter: DashedLinePainter(),
            ),
            _buildInfoRow("Subtotal", "\$206.45",
                isBold: true, isRightAligned: true),
            _buildInfoRow("Tax", "\$20.6", isRightAligned: true),
            _buildInfoRow("Grand Total", "\$227.05",
                isBold: true, isRightAligned: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
