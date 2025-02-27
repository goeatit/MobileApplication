import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

class FoodCartSection extends StatelessWidget {
  const FoodCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(right: 24.0, bottom: 20, left: 10),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/images/restaurant.png", // Replace with actual image
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Column(
                    children: [
                      Text(
                        "Sabzi - The Indian Cuisine",
                        style: TextStyle(fontSize: 10),
                      ),
                      Text("View Menu"),
                    ],
                  ),
                  SizedBox(width: 12,),
                  ElevatedButton(
                    onPressed: () {
                      // Handle "View Cart" action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rectangular shape
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View Cart",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text("data",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20,
                      ))
                ],
              ),
            ),
          ),
          // Food Cart Item 2
        ],
      ),
    );
  }
}
