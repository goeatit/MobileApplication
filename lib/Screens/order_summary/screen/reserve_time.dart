import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/Screens/order_summary/service/time_slot_generater.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReserveTime extends StatefulWidget {
  static const routeName = '/reserve-time';

  const ReserveTime({super.key});

  @override
  State<ReserveTime> createState() => _ReserveTimeState();
}

class _ReserveTimeState extends State<ReserveTime> {

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
    });

    // Show popup if all slots are closed
    if (allClosed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRestaurantClosedDialog();
      });
    }
  }

  void _showRestaurantClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Restaurant Closed'),
              content: const Text(
                'Sorry, this restaurant is currently closed. Please try again later or choose another restaurant.',
                style: TextStyle(fontSize: 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the OrderProvider
    final orderProvider = Provider.of<OrderProvider>(context);

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
              value: 0.8,
              backgroundColor: Colors.grey.shade300,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Select Time",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Time Slots
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: timeSlots.map((time) {
                      bool isClosedSlot = time == "Closed";
                      return GestureDetector(
                        onTap: isClosedSlot
                            ? null
                            : () {
                                setState(() {
                                  selectedTime = time;
                                });
                              },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 26),
                            decoration: BoxDecoration(
                              color: selectedTime == time
                                  ? Colors.green.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: selectedTime == time
                                    ? const Color(0xFF139456)
                                    : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(20),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: selectedTime == time
                                ? Colors.green.shade100
                                : isClosedSlot
                                    ? Colors.grey.shade200
                                    : Colors.white,
                            border: Border.all(
                                color:selectedTime == time
                                ? const Color(0xFF139456)
                                : isClosedSlot
                                    ? Colors.grey
                                    : Colors.black,
                                    ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isClosedSlot ? Colors.grey : Colors.black,
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: selectedTime == time
                                    ? const Color(0xFF139456)
                                    : Colors.black,
                              ),
                            )),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Spacer(),

                  // Continue Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: selectedTime != null
                        ? () {
                            // Update the order provider with selected time
                            orderProvider.setSelectedTime(selectedTime!);

                            Navigator.pushNamed(
                                context, OrderSummaryScreen.routeName);
                          }
                        : null,
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
