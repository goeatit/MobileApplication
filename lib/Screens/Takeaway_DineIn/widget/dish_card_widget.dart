import 'package:flutter/material.dart';

class DishCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String calories;
  final int quantity;
  final VoidCallback onAddToCart; // Add a callback for adding to cart
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DishCard(
      {super.key,
      required this.name,
      required this.quantity,
      required this.price,
      required this.imageUrl,
      required this.calories,
      required this.onAddToCart,
      required this.onIncrement,
      required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 157, // Adjust the width as needed
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Image.asset(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Corner Ribbon
                  // Replace the existing Corner Ribbon Positioned widget with this:
                  Positioned(
                    top: 12,
                    left: -27, // Adjust this value to position the ribbon
                    child: Transform.rotate(
                      angle: -0.6, // Approximately -28.6 degrees in radians
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 1,
                          horizontal: 35,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Most Rated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dish Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "$price • $calories",
                  style: const TextStyle(
                    color: Color(0xff737373),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          // Floating Add Button
          quantity == 0
              ? Positioned(
                  bottom: 70,
                  right: 6,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: onAddToCart,
                      icon: const Icon(
                        Icons.add_circle_outline,
                      ),
                    ),
                  ),
                )
              : Positioned(
                  bottom: 70,
                  right: 6,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: onDecrement,
                            icon: const Icon(
                              Icons.remove_circle_outline,
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: onIncrement,
                            icon: const Icon(
                              Icons.add_circle_outline,
                            ),
                          ),
                        ],
                      )),
                )
        ],
      ),
    );
  }
}
