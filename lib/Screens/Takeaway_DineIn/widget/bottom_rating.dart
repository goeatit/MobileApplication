import 'package:eatit/Screens/Takeaway_DineIn/widget/rating_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomRating extends StatefulWidget {
  final String restaurantName;
  final VoidCallback pressClose;
  final VoidCallback pressRemove;

  const BottomRating({
    Key? key,
    required this.restaurantName,
    required this.pressClose,
    required this.pressRemove,
  }) : super(key: key);

  @override
  State<BottomRating> createState() => _BottomRatingState();
}

class _BottomRatingState extends State<BottomRating> {
  bool isSlided = false;
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < -5) {
          setState(() {
            isSlided = true;
          });
        } else if (details.delta.dx > 5) {
          setState(() {
            isSlided = false;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFDDBDB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDDBDB),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.pressRemove();
                    setState(() {
                      isSlided = false;
                    });
                  },
                  child: const Center(
                    child: Text(
                      'Remove',
                      style: TextStyle(
                        color: Color(0xFFF42829),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform:
                  Matrix4.translationValues(isSlided ? -70.0 : 0.0, 0.0, 0.0),
              decoration: BoxDecoration(
                color: const Color(0xFF404040), // Changed background color
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (isSlided)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  if (isSlided) {
                    setState(() {
                      isSlided = false;
                    });
                  } else {
                    // Show the rating bottom sheet
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const RatingBottomSheet(),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF404040), // Changed background color
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First Container - Rating text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rate your last order from,",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.restaurantName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),

                      // Second Container - Rating icons
                      // Second Container - Rating icons
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              4,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating = index + 1;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    _selectedRating >= index + 1
                                        ? Icons.star
                                        : Icons.star_outline_rounded,
                                    color: _selectedRating >= index + 1
                                        ? Colors.amber
                                        : Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!isSlided)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSlided = true;
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
