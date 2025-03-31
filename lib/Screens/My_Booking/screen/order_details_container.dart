import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eatit/common/constants/colors.dart';
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
      // Parse the UTC time string
      final DateTime utcDateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone
      final DateTime localDateTime = utcDateTime.toLocal();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime orderDate =
          DateTime(localDateTime.year, localDateTime.month, localDateTime.day);

      String dateText;
      if (orderDate == today) {
        dateText = 'Today';
      } else if (orderDate == yesterday) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('MMM dd, yyyy').format(localDateTime);
      }

      final String timeText = DateFormat('hh:mm a').format(localDateTime);
      return '$dateText | $timeText';
    } catch (e) {
      // If there's any error parsing the date, return the original string
      return dateTimeString;
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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order ID: ${widget.order.user.orderId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: _copyOrderId,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.user.restaurantName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${_formatDateTime(widget.order.user.createdAt.toString())}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${widget.order.user.orderStatus}',
              style: TextStyle(
                color:
                    widget.order.user.orderStatus.toLowerCase() == 'completed'
                        ? Colors.green
                        : primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            ExpansionTile(
              title: const Text('Order Items'),
              tilePadding: EdgeInsets.zero,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.quantity}x ${item.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '₹${widget.order.user.subTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
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
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(color: Colors.white),
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
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'See Direction',
                      style: TextStyle(color: Colors.white),
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
