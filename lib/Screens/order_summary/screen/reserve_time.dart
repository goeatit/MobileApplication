import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

class ReserveTime extends StatefulWidget {
  static const routeName = '/reserve-time';
  const ReserveTime({super.key});

  @override
  State<ReserveTime> createState() => _ReserveTimeState();
}

class _ReserveTimeState extends State<ReserveTime> {
  List<String> timeSlots = [
    "11:30AM",
    "12:00PM",
    "12:30PM",
    "01:00PM",
    "01:30PM",
    "02:00PM",
  ];
  String? selectedTime; // To track the selected time slot

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
                      return GestureDetector(
                        onTap: () {
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
                            print("Reserved time: $selectedTime");
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
