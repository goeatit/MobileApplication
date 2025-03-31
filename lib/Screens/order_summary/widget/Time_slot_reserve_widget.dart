import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:provider/provider.dart';
import 'package:eatit/Screens/order_summary/service/time_slot_generater.dart';

class TimeSlotsReserveWidget extends StatefulWidget {
  const TimeSlotsReserveWidget({super.key});

  @override
  State<TimeSlotsReserveWidget> createState() => _TimeSlotsReserveWidgetState();
}

class _TimeSlotsReserveWidgetState extends State<TimeSlotsReserveWidget> {
  List<String> timeSlots = [];
  String? selectedTime; // To track the selected time slot
  final TimeSlotGenerator timeSlotGenerator = TimeSlotGenerator();
  bool allSlotsClosed = false;

  @override
  void initState() {
    super.initState();
    // Generate time slots based on restaurant time and waiting time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateTimeSlots();
    });
  }

  void generateTimeSlots() {
    // Get data from OrderProvider
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final restaurantTime = orderProvider.restaurantTime;
    final restaurantWaitingTime = orderProvider.restaurantWaitingTime;
    var slots = timeSlotGenerator.generateTimeSlots(
        restaurantWaitingTime, restaurantTime);

    // Check if all slots are closed
    bool allClosed = slots.every((slot) => slot == "Closed");

    setState(() {
      timeSlots = slots;
      allSlotsClosed = allClosed;

      // If time already selected in provider, use that
      if (orderProvider.selectedTime != null &&
          orderProvider.selectedTime!.isNotEmpty) {
        selectedTime = orderProvider.selectedTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the OrderProvider
    final orderProvider = Provider.of<OrderProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/clock.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            const Text(
              "Select Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (allSlotsClosed)
          const Text(
            "Sorry, this restaurant is currently not accepting orders. Please try again later.",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((time) {
              bool isClosedSlot = time == "Closed";
              return GestureDetector(
                onTap: isClosedSlot
                    ? null
                    : () {
                        setState(() {
                          selectedTime = time;
                          // Update provider immediately
                          orderProvider.setSelectedTime(time);
                        });
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: selectedTime == time
                          ? const Color(0xFF139456)
                          : isClosedSlot
                              ? Colors.grey
                              : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
