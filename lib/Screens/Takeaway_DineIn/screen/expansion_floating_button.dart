import 'package:eatit/Screens/Takeaway_DineIn/screen/booking_bottom_sheet.dart';
import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/material.dart';

class ExpansionFloatingButton extends StatefulWidget {
  final List<UserElement> orders;
  final VoidCallback onRefresh;

  const ExpansionFloatingButton({
    required this.orders,
    required this.onRefresh,
    super.key,
  });

  @override
  State<ExpansionFloatingButton> createState() =>
      _ExpansionFloatingButtonState();
}

class _ExpansionFloatingButtonState extends State<ExpansionFloatingButton> {
  bool isExpanded = false;
  bool isLoading = false; // Add loading state

  // Function to handle button press with loading state
  void handleButtonPress() async {
    setState(() {
      isLoading = true; // Start loading
    });

    // Call onRefresh and wait for it to complete
    if(!isExpanded) {
      await Future.microtask(() => widget.onRefresh());
    }

    setState(() {
      isLoading = false; // Stop loading
      isExpanded = !isExpanded; // Toggle expansion
    });
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
    if (widget.orders
        .where((order) => _shouldDisplayBooking(order.user.orderStatus))
        .isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width,
          height: isExpanded ? MediaQuery.of(context).size.height * 0.7 : 50,
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isExpanded ? 28 : 0),
              ),
            ),
            child: Column(
              children: [
                if (isExpanded)
                  Expanded(
                    child: SingleChildScrollView(
                      child: BookingBottomSheet(
                        onClosePressed: () {
                          setState(() {
                            isExpanded = false;
                          });
                        },
                        orders: widget.orders,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleButtonPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8951D),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(isExpanded ? 0 : 0),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          const Text(
                            'View all my bookings',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.double_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
