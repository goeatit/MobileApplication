import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FoodCartSection extends StatefulWidget {
  const FoodCartSection({super.key});

  @override
  State<FoodCartSection> createState() => _FoodCartSectionState();
}

class _FoodCartSectionState extends State<FoodCartSection> {
  bool isSlided = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(right: 24.0, bottom: 20, left: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 7,
            shadowColor: const Color(0x33090909),
            child: Container(
                width: 412,
                height: 70,
                clipBehavior:
                    Clip.antiAlias, // This will hide overflowing content
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDDBDB),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Handle remove action
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
                      transform: Matrix4.translationValues(
                          isSlided ? -70.0 : 0.0, 0.0, 0.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(isSlided ? 0 : 10),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (isSlided) {
                            setState(() {
                              isSlided = false;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          width: 412,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // First Container
                              Container(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.24),
                                      child: Image.asset(
                                        "assets/images/restaurant.png",
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Sabzi - The Indian Cuisine",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                Colors.black.withOpacity(0.87),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "View Menu",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SvgPicture.asset(
                                              "assets/images/double-arrow.svg",
                                              width: 20,
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Second Container
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 114,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Handle "View Cart" action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "View Cart",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              "1 Items",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
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
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF4F4F4),
                                              borderRadius:
                                                  BorderRadius.circular(17.64),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
