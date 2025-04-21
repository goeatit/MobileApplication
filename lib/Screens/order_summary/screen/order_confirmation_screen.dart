import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderConfirmationScreen extends StatefulWidget {
  static const routeName = '/order-confirmation';

  final String restaurantId;
  final String restaurantName;
  final String location;
  final String latitude;
  final String longitude;

  const OrderConfirmationScreen({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
    required this.location,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    // Disable back button on Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));
  }

  Future<void> _openMap(String? latitude, String? longitude,
      {String? name}) async {
    Uri googleMapsUrl;

    if (latitude == null || longitude == null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name ?? '')}");
    } else if (name != null && name.isNotEmpty) {
      final String encodedQuery =
          Uri.encodeComponent("$latitude,$longitude ($name)");
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedQuery");
    } else {
      googleMapsUrl =
          Uri.parse("https://www.google.com/maps?q=$latitude,$longitude");
    }

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // This disables the system back button on Android
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false, // This hides the default back button
          title: const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Map Section
                        // In the GoogleMap widget section, replace the existing code with:
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(widget.latitude),
                                  double.parse(widget.longitude)),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('restaurant'),
                                position: LatLng(double.parse(widget.latitude),
                                    double.parse(widget.longitude)),
                                infoWindow: InfoWindow(
                                  title: widget.restaurantName,
                                  snippet: widget.location,
                                ),
                              ),
                            },
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                              // Animate camera to restaurant position
                              controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                        double.parse(widget.latitude),
                                        double.parse(widget.longitude)),
                                    zoom: 15,
                                  ),
                                ),
                              );
                            },
                            myLocationEnabled: false,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: true,
                            compassEnabled: true,
                          ),
                        ),

                        // Restaurant Info Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align items to the top
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      'assets/svg/icon-park-twotone_hotel.svg',
                                      fit: BoxFit.scaleDown,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Take minimum required space
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.restaurantName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          widget
                                              .location, // Use the passed location here

                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment
                                        .topCenter, // Align button to the top
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _openMap(
                                          widget.latitude,
                                          widget.longitude,
                                          name: widget.restaurantName,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFF8951D),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ), // Add padding for better button appearance
                                      ),
                                      label: const Text('Get Directions'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Order Summary Section
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(3, 6),
                                blurRadius: 13.8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Order Summary',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              // Display cart items
                              ...orderProvider.cartItems
                                  .map((item) => _buildOrderItem(
                                        item.dish.dishId.dishName,
                                        item.quantity,
                                        item.dish.resturantDishPrice.toDouble(),
                                      )),
                              const SizedBox(height: 36),
                              const CustomDottedDivider(),
                              _buildPriceRow('SubTotal',
                                  '₹${orderProvider.subTotal.toStringAsFixed(2)}'),
                              _buildPriceRow('GST',
                                  '₹${orderProvider.gst.toStringAsFixed(2)}'),
                              _buildPriceRow('Grand Total',
                                  '₹${orderProvider.grandTotal.toStringAsFixed(2)}',
                                  isTotal: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Get the order type to determine how many screens to pop
                      final orderProvider =
                          Provider.of<OrderProvider>(context, listen: false);
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      final isDineIn =
                          orderProvider.orderType?.toLowerCase() == "dine-in";

                      // Clear the cart for this restaurant and order type
                      if (orderProvider.restaurantId != null &&
                          orderProvider.orderType != null) {
                        cartProvider.clearCart(orderProvider.restaurantId!,
                            orderProvider.orderType!);
                      }

                      // Clear the order data after successful payment
                      orderProvider.clearOrder();

                      // Calculate number of screens to pop based on order type
                      final screensToPopCount =
                          isDineIn ? 3 : 2; // 3 for dine-in, 2 for takeaway

                      // Pop the required number of screens
                      for (int i = 0; i < screensToPopCount; i++) {
                        if (mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8951D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, int quantity, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1, // Gives more space for the product name
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF737373),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            // Centers the quantity
            child: Text(
              'x$quantity',
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF737373),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '₹${price.toDouble().toStringAsFixed(2)}', // Ensure price is double
            textAlign: TextAlign.end, // Aligns price to the right
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF737373),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF1D1929),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF1D1929),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Reset the system UI overlay style when the screen is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
}

class CustomDottedDivider extends StatelessWidget {
  const CustomDottedDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: DottedLinePainter(),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    double dashWidth = 5;
    double dashSpace = 3;
    double startX = 0;

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
