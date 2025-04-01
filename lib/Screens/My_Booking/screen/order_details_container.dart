import 'package:eatit/main.dart' show CustomTextTheme;
import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OrderDetailsContainer extends StatefulWidget {
  final UserElement order;

  const OrderDetailsContainer({super.key, required this.order});

  @override
  State<OrderDetailsContainer> createState() => _OrderDetailsContainerState();
}

class _OrderDetailsContainerState extends State<OrderDetailsContainer> {
  bool isExpanded = false;

  String _formatDateTime(String dateTimeString) {
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

      if (dateToCheck == today) {
        return '$timeText Today';
      } else if (dateToCheck == yesterday) {
        return '$timeText Yesterday';
      } else {
        return '${DateFormat('dd.MM.yyyy').format(localDateTime)} $timeText';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  Color _getStatusBackgroundColor(String? status) {
    if (status == null) return Colors.transparent;

    switch (status.toLowerCase()) {
      case 'preparing':
      case 'order placed':
      case 'Ready':
      case 'completed':
        return const Color(0xFFDAFCDD);
      case 'Delayed':
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
      case 'Ready':
      case 'completed':
        return const Color(0xFF1F982A);
      case 'Delayed':
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color.fromARGB(255, 255, 253, 253),
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
                        'Order ID: ${widget.order.user.orderId}',
                        style: customTheme.montserratOrderId,
                      ),
                      const SizedBox(width: 0),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.copy,
                          size: 15,
                          color: Color(0xFF8BA3CB),
                        ),
                        onPressed: _copyOrderId,
                      ),
                      const SizedBox(width: 0),
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
              style: customTheme.nunitoSansRestaurantName,
            ),
            const SizedBox(height: 5),
            Text(
              _formatDateTime(widget.order.user.createdAt.toString()),
              style: customTheme.montserratOrderItem.copyWith(
                color: const Color(0xFF8BA3CB),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0x54CACACA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                title: Text(
                  firstItem != null
                      ? '${firstItem.quantity}x ${firstItem.name}'
                      : '',
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
                              padding: const EdgeInsets.symmetric(vertical: 4),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: customTheme.montserratOrderItem.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '₹${widget.order.user.subTotal.toStringAsFixed(2)}',
                                style: customTheme.montserratOrderItem.copyWith(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement cancel order functionality
                    },
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
                    child: Text(
                      'Cancel Order',
                      style: customTheme.montserratButton.copyWith(
                        color: const Color(0xFFFA9494),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement see direction functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF64C4D),
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
