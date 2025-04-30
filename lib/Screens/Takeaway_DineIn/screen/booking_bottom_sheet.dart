import 'package:eatit/Screens/order_summary/service/time_slot_generater.dart';
import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/material.dart';

// Custom Dashed Divider
class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    this.height = 1,
    this.color = Colors.grey,
    this.dashWidth = 6,
    this.dashSpace = 4,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: height,
              color: color,
              margin: EdgeInsets.only(right: dashSpace),
            );
          }),
        );
      },
    );
  }
}

class BookingBottomSheet extends StatefulWidget {
  final VoidCallback onClosePressed;
  final List<UserElement> orders;

  const BookingBottomSheet({
    required this.onClosePressed,
    required this.orders,
    Key? key,
  }) : super(key: key);

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  void _showTimeSlotDialog(BuildContext context, UserElement order) {
    final timeSlots = TimeSlotGenerator().generateTimeSlots(
      order.user.vendorWaitingTime ?? 0,
      order.user.restaurantTiming ?? "10:00 AM - 10:00 PM",
    );
    String? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.access_alarm, size: 24, color: Colors.black),
                  SizedBox(width: 10),
                  Text('Select Time Slot',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final time = timeSlots[index];
                    final isClosedSlot = time == "Closed";

                    return GestureDetector(
                      onTap: isClosedSlot
                          ? null
                          : () {
                              setStateDialog(() {
                                selectedTime = time;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selectedTime == time
                              ? Colors.green.shade100
                              : isClosedSlot
                                  ? Colors.grey.shade200
                                  : Colors.white,
                          border: Border.all(
                            color: selectedTime == time
                                ? const Color(0xFF139456)
                                : isClosedSlot
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              time,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: selectedTime == time
                                        ? const Color(0xFF139456)
                                        : isClosedSlot
                                            ? Colors.grey
                                            : Colors.black,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFF8951D)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Color(0xFFF8951D))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextButton(
                        onPressed: selectedTime == null
                            ? null
                            : () => Navigator.of(context).pop(selectedTime),
                        style: TextButton.styleFrom(
                          backgroundColor: selectedTime == null
                              ? Colors.grey.shade300
                              : const Color(0xFFF8951D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: selectedTime == null
                                ? Colors.grey.shade700
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          order.user.pickupTime =
              selectedTime; // ✅ Update the pick up time directly
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup time updated to: $selectedTime'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
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

  bool _shouldDisplayBooking(String? status) {
    if (status == null) return false;
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'preparing' ||
        lowerStatus == 'order placed' ||
        lowerStatus == 'ready' ||
        lowerStatus == 'delayed';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Grab Handle
          Container(
            width: 50,
            height: 6,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Bookings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.1,
                  fontSize: 24,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 28,
                  color: Colors.black,
                ),
                onPressed: widget.onClosePressed,
                splashRadius: 24,
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of bookings
          if (widget.orders
              .where((order) => _shouldDisplayBooking(order.user.orderStatus))
              .isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No bookings found!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.orders.length,
              itemBuilder: (context, index) {
                final order = widget.orders[index];
                if (_shouldDisplayBooking(order.user.orderStatus)) {
                  return _buildBookingItem(context, order);
                } else {
                  return const SizedBox(); // Don't show anything if status doesn't match
                }
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, UserElement order) {
    final theme = Theme.of(context);
    final booking = order.user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant name and icon
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.primaryColor.withOpacity(0.15),
                  child: Icon(Icons.restaurant_menu,
                      color: theme.primaryColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    booking.restaurantName ?? 'Unknown Restaurant',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.grey[900],
                    size: 35,
                  ),
                  onPressed: () => _showTimeSlotDialog(context, order),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                Icons.confirmation_number, 'Order ID:', booking.orderId, theme),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.event_seat, 'Order Type:',
                booking.orderType ?? 'N/A', theme),
            const SizedBox(height: 8),

            _buildDetailRow(
              Icons.timer,
              'Waiting Time:',
              (booking.orderStatus?.toLowerCase() == 'order placed')
                  ? booking.vendorComment
                  : (booking.vendorWaitingTime != null
                      ? '${booking.vendorWaitingTime} mins'
                      : 'N/A'),
              theme,
            ),

            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time_filled_rounded, 'Pickup Time:',
                booking.pickupTime ?? 'N/A', theme),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.pending_actions_rounded,
              'Order Status:',
              booking.orderStatus ?? 'Pending',
              theme,
            ),

            const SizedBox(height: 20),
            const DashedDivider(
              color: Colors.grey,
              height: 1,
              dashWidth: 8,
              dashSpace: 4,
            ),
            const SizedBox(height: 16),
            _buildOrderItems(booking.items ?? []),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '₹${booking.subTotal ?? 0}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, ThemeData theme) {
    // Special handling for Order Status
    if (label == 'Order Status:') {
      return Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            label,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(value),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getStatusTextColor(value),
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    // Default rendering for other detail rows

    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Add this to handle text overflow
        ),
      ],
    );
  }

  Widget _buildOrderItems(List<Item> items) {
    return Column(
      children: items
          .map((item) => _buildOrderItemRow(
                item.name,
                item.quantity,
                item.price,
              ))
          .toList(),
    );
  }

  Widget _buildOrderItemRow(String itemName, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/home_style.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  'x$quantity',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${(price * quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
