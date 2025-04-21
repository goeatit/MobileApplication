import 'package:flutter/material.dart';

class DishCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String calories;
  final int quantity;
  final bool isAvailable;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DishCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.calories,
    required this.isAvailable,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 157,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : Colors.grey.shade500,
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
              // Image Section with grey filter if unavailable
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: ColorFiltered(
                      colorFilter: isAvailable
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : ColorFilter.mode(
                              Colors.grey.shade900,
                              BlendMode.saturation,
                            ),
                      child: Image.asset(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // "Currently Unavailable" overlay
                  if (!isAvailable)
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Currently Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Corner Ribbon (unchanged)
                  Positioned(
                    top: 12,
                    left: -27,
                    child: Transform.rotate(
                      angle: -0.6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 1,
                          horizontal: 35,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.orange
                              : Colors.grey.shade800,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isAvailable ? Colors.black : Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Price and Calories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "$price • $calories",
                  style: TextStyle(
                    color: isAvailable
                        ? const Color(0xff737373)
                        : Colors.grey.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          // Floating Add Button or Quantity Controls
          Positioned(
            bottom: 70,
            right: 6,
            child: isAvailable
                ? quantity == 0
                    ? CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: isAvailable ? onAddToCart : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: isAvailable ? Colors.black : Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: isAvailable ? onDecrement : null,
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: isAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                fontSize: 16,
                                color: isAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: isAvailable ? onIncrement : null,
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: isAvailable ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                : const SizedBox
                    .shrink(), // Hide controls when dish is unavailable
          ),
        ],
      ),
    );
  }
}
