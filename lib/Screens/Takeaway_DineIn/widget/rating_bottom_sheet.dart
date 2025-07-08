import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({Key? key}) : super(key: key);

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _restaurantRating = 0;
  final Map<int, int> _dishRatings = {};
  final TextEditingController _commentController = TextEditingController();

  // Sample dish data - in a real app, this would come from a parameter
  final List<Map<String, dynamic>> _dishes = [
    {
      'name': 'Chicken Shawarma',
      'price': 3.00,
      'quantity': 2,
      'image': 'appetizers.png',
    },
    {
      'name': 'Vegetable Biryani',
      'price': 5.50,
      'quantity': 1,
      'image': 'appetizers.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with back arrow
            // Replace the separate arrow and progress bar sections with this:
// Header with back arrow and progress bar in a row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/svg/graybackArrow.svg',
                      // height: 34,
                      // width: 34,
                    ),
                  ),
                  const SizedBox(
                      width: 10), // 5px gap between arrow and progress bar
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //const SizedBox(height: 16),

            // Rate Restaurant Service heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Rate Restaurant Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1C),
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 16),

            // Restaurant rating stars
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _restaurantRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        _restaurantRating > index
                            ? Icons.star
                            : Icons.star_outline_rounded,
                        color: _restaurantRating > index
                            ? Colors.amber
                            : Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Restaurant name
            const Center(
              child: Text(
                'Sabzi- The Indian Cuisine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1929),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Rate your dishes text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Rate your dishes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1929),
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 5),

            // Help us improve text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This helps us to improve our food & services',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF737373),
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 16),

            // Dish rating cards
            ..._dishes.asMap().entries.map((entry) {
              final index = entry.key;
              final dish = entry.value;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Dish image
                      // Dish image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/${dish['image']}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Dish details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dish['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            Text(
                              '\$${dish['price'].toStringAsFixed(2)} | Qty: ${dish['quantity'].toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF797979),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating stars
                      Row(
                        children: List.generate(
                          4,
                          (starIndex) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _dishRatings[index] = starIndex + 1;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(
                                _dishRatings[index] != null &&
                                        _dishRatings[index]! > starIndex
                                    ? Icons.star
                                    : Icons.star_outline_rounded,
                                color: _dishRatings[index] != null &&
                                        _dishRatings[index]! > starIndex
                                    ? Colors.amber
                                    : Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Comment section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Add any comment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1929),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Comment input box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comments here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF8951D)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submission
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8951D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
