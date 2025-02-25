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
      width: 160, // Adjust the width as needed
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
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
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Image.asset(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Corner Ribbon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Most Rated',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dish Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  "$price · $calories",
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
