import 'package:dio/dio.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart' show CustomTextTheme;
import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:eatit/Screens/My_Booking/service/My_Booking_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsContainer extends StatefulWidget {
  final UserElement order;
  final VoidCallback onOrderCancelled;

  const OrderDetailsContainer({
    super.key,
    required this.order,
    required this.onOrderCancelled,
  });

  @override
  State<OrderDetailsContainer> createState() => _OrderDetailsContainerState();
}

class _OrderDetailsContainerState extends State<OrderDetailsContainer> {
  bool isExpanded = false;
  bool _isCancelling = false;
  late MyBookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _bookingService = MyBookingService();
  }

  void _openMap(dynamic latitude, dynamic longitude, dynamic address,
      {String? name}) async {
    Uri googleMapsUrl;
    if (address != null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/${Uri.encodeComponent("${name!} $address")}");
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
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
          title: Column(
            children: [
              const Icon(
                Icons.warning_rounded, // Added alert icon
                color: Color(0xFFF8951D), // Same red color as buttons
                size: 40, // Adjust size as needed
              ),
              const SizedBox(height: 8), // Space between icon and text
              Text(
                'Confirm Cancellation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.only(
            top: 5,
            left: 24,
            right: 24,
            bottom: 20,
          ),
          content: Text(
            'Are you sure you want to cancel this order?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF666666),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFFF8951D),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'No',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFFF8951D),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _cancelOrder();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF8951D),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder() async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final response =
          await _bookingService.cancelOrder(widget.order.user.orderId);
      if (response != null && response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onOrderCancelled();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('failed to cancel order '),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Widget _buildFormattedDateTime(String dateTimeString) {
    try {
      final DateTime utcDateTime = DateTime.parse(dateTimeString);
      final DateTime localDateTime = utcDateTime.toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
      final DateTime dateToCheck = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      String timeText = DateFormat('hh:mm a').format(localDateTime);
      String dateText;

      if (dateToCheck == today) {
        dateText = 'Today';
      } else if (dateToCheck == yesterday) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('dd.MM.yyyy').format(localDateTime);
      }

      return Row(
        children: [
          Text(
            timeText,
            style: Theme.of(context)
                .extension<CustomTextTheme>()
                ?.montserratOrderItem
                .copyWith(
                  color: const Color(0xFF8BA3CB),
                  fontSize: 14,
                ),
          ),
          const SizedBox(width: 10), // 10px gap
          Text(
            dateText,
            style: Theme.of(context)
                .extension<CustomTextTheme>()
                ?.montserratOrderItem
                .copyWith(
                  color: const Color(0xFF8BA3CB),
                  fontSize: 14,
                ),
          ),
        ],
      );
    } catch (e) {
      return Text(
        dateTimeString,
        style: Theme.of(context)
            .extension<CustomTextTheme>()
            ?.montserratOrderItem
            .copyWith(
              color: const Color(0xFF8BA3CB),
              fontSize: 14,
            ),
      );
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    if (status == null) return Colors.transparent;

    switch (status.toLowerCase()) {
      case 'preparing':
      case 'order placed':
      case 'ready':
      case 'completed':
        return const Color(0xFFDAFCDD);
      case 'delayed':
        return const Color(0xFFFFF5D9);
      case 'cancelled':
        return const Color(0xFFFCE4DA);
      default:
        return Colors.transparent;
    }
  }

  Color _getStatusTextColor(String? status) {
    if (status == null) return Colors.black;

    switch (status.toLowerCase()) {
      case 'preparing':
      case 'order placed':
      case 'ready':
      case 'completed':
        return const Color(0xFF1F982A);
      case 'delayed':
        return const Color(0xFFD1A017);
      case 'cancelled':
        return const Color(0xFFE34301);
      default:
        return Colors.black;
    }
  }

  void _copyOrderId() {
    Clipboard.setData(ClipboardData(text: widget.order.id)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order ID copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstItem =
        widget.order.user.items.isNotEmpty ? widget.order.user.items[0] : null;
    final customTheme = Theme.of(context).extension<CustomTextTheme>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: white,
        borderRadius:
            BorderRadius.circular(18), // You can adjust this value as needed
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Id: ${widget.order.user.orderId}',
                        style: customTheme.montserratOrderId,
                        textScaler: TextScaler.noScaling,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _copyOrderId,
                        child: const Icon(
                          Icons.copy,
                          size: 14,
                          color: Color(0xFF8BA3CB),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(
                        widget.order.user.orderStatus),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.order.user.orderStatus ?? '',
                    style: customTheme.montserratOrderItem.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusTextColor(widget.order.user.orderStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.user.restaurantName,
              style: customTheme.nunitoSansRestaurantName.copyWith(
                //letterSpacing: 0.5,
                height: 1.3,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: darkBlack,
              ),
            ),
            const SizedBox(height: 9),
            _buildFormattedDateTime(widget.order.user.createdAt.toString()),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0x54CACACA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ListTileTheme(
                  dense: true,
                  child: ExpansionTile(
                    title: Text(
                      // firstItem != null
                      //     ? '${firstItem.quantity}x ${firstItem.name}'
                      //     : '',
                      "Order Items",
                      style: customTheme.montserratOrderItem,
                    ),
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    childrenPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    initiallyExpanded: false,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.order.user.items.length,
                              itemBuilder: (context, index) {
                                final item = widget.order.user.items[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.quantity}x ${item.name}',
                                        style: customTheme.montserratOrderItem,
                                      ),
                                      Text(
                                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: customTheme.montserratOrderItem,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: customTheme.montserratOrderItem
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.order.user.subTotal.toStringAsFixed(2)}',
                                    style: customTheme.montserratOrderItem
                                        .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.order.user.orderStatus?.toLowerCase() != 'cancelled')
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isCancelling ? null : _showCancelConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        side: const BorderSide(
                          color: Color(0x1A1D1929),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFA9494)),
                              ),
                            )
                          : Text(
                              'Cancel Order',
                              style: customTheme.montserratButton.copyWith(
                                color: const Color(0xFFFA9494),
                              ),
                            ),
                    ),
                  ),
                if (widget.order.user.orderStatus?.toLowerCase() != 'cancelled')
                  const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.order.latitude.isNotEmpty &&
                          widget.order.longitude.isNotEmpty) {
                        _openMap(
                          widget.order.latitude[0],
                          widget.order.longitude[0],
                          widget.order.location[0],
                          name: widget.order.user.restaurantName,
                        );
                      } else {
                        _openMap(
                          null,
                          null,
                          widget.order.location[0],
                          name: widget.order.user.restaurantName,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8951D),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'See Direction',
                      style: customTheme.montserratButton.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
