import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

class FoodItemBottomSheet extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String calories;
  final int quantity;
  final String price;
  final String categories;
  final VoidCallback onAddToCart; // Add a callback for adding to cart
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FoodItemBottomSheet(
      {super.key,
      required this.name,
      required this.imageUrl,
      required this.calories,
      required this.quantity,
      required this.onAddToCart,
      required this.onIncrement,
      required this.onDecrement,
      required this.categories,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height /
          1.6, // Height for the bottom sheet
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        'assets/images/dish.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: Colors.black),
                              onPressed: () {
                                // Handle share action
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        calories,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹$price',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categories,
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Images',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildImageThumbnail(
                              'https://via.placeholder.com/60'),
                          const SizedBox(width: 8),
                          _buildImageThumbnail(
                              'https://via.placeholder.com/60'),
                          const SizedBox(width: 8),
                          _buildImageThumbnail(
                              'https://via.placeholder.com/60'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      quantity == 0
                          ? InkWell(
                              onTap: onAddToCart,
                              child: Container(
                                padding: const EdgeInsets.all(10.0), // Add
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: neutrals200, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      8), // Optional: Rounded corners
                                ),
                                width: double.infinity,
                                child: const Center(
                                    child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Ensures Row takes minimal width
                                  children: [
                                    Text(
                                      'Add',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Adds spacing between the Text and Icon
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.black,
                                    ),
                                  ],
                                )),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(10.0), // Add
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(
                                  color: neutrals200, // Border color
                                  width: 2.0, // Border width
                                ),
                                borderRadius: BorderRadius.circular(
                                    8), // Optional: Rounded corners
                              ),
                              width: double.infinity,
                              child: Center(
                                  child: Row(
                                // Ensures Row takes minimal width
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: onDecrement,
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  InkWell(
                                    onTap: onIncrement,
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )),
                            )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(String url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
