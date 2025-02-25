import 'package:eatit/main.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DineInTakeawayToggle extends StatefulWidget {
  const DineInTakeawayToggle({super.key});

  @override
  State<DineInTakeawayToggle> createState() => _DineInTakeawayToggleState();
}

class _DineInTakeawayToggleState extends State<DineInTakeawayToggle> {
  int selectedIndex = 0; // 0 for 'Dine In', 1 for 'Takeaway'

  @override
  Widget build(BuildContext context) {
    selectedIndex = context.watch<OrderTypeProvider>().orderType;

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color
          borderRadius: BorderRadius.circular(24), // Rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dine In
            GestureDetector(
              onTap: () {
                context.read<OrderTypeProvider>().changeOrderType(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                      color: selectedIndex == 0
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        "Dine In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              selectedIndex == 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                    )),
              ),
            ),
            // Takeaway
            GestureDetector(
              onTap: () {
                context.read<OrderTypeProvider>().changeOrderType(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        "Takeaway",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              selectedIndex == 1 ? Colors.black : Colors.grey,
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
