import 'dart:async';

import 'package:eatit/Screens/Auth/login_screen/screen/login_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FirstTimeScreen extends StatefulWidget {
  static const routeName = "/first-time-screen";

  const FirstTimeScreen({super.key});

  @override
  State<FirstTimeScreen> createState() => _FirstTimeScreen();
}

class _FirstTimeScreen extends State<FirstTimeScreen> {
  bool _next = true;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  Timer? _timer;
  final List<String> _images = [
    "assets/images/first.png",
    "assets/images/second.png",
    "assets/images/third.png",
  ];

  final List<String> _titles = [
    "Fast, Simple & Hassle-free",
    "Fast, Simple & Hassle-free",
    "Fast, Simple & Hassle-free",
  ];
  final List<String> subtitle = ["Booking", "Dining", "Payment"];
  final List<String> _descriptions = [
    "Get delicious food delivered right at your doorstep at zero cost.",
    "Get delicious food delivered right at your doorstep at zero cost.",
    "Get delicious food delivered right at your doorstep at zero cost.",
  ];
  Widget _buildIndicator(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        double width = (i == index) ? 24 : 10;
        double height = (i == index) ? 10 : 10;
        Color color;

        if (i == index) {
          color = const Color(0xFFFDDCB4); // Active index color
        } else if (i < index) {
          color = const Color(0xFFF8951D); // Previous index color
        } else {
          color = const Color(0xFFFDDCB4); // Next index color
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(47),
            ),
          ),
        );
      }),
    );
  }

  void _startAutoSwipe() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < _images.length - 1) {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel(); // Stop auto swipe when the last page is reached
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startAutoSwipe();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 450,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _images[index],
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _titles[index],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle[index],
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8951D)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 1),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _descriptions[index],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              _buildIndicator(index),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex < _images.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // Navigate to login or home screen
                          }
                          // logic
                          if (_currentIndex == 2) {
                            // when login comes then it will navigate to the otp function
                            Navigator.pushReplacementNamed(
                                context, LoginScreeen.routeName);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Set the border radius here
                          ),
                          backgroundColor: const Color(0xFFEA8307),
                        ),
                        child: Text(
                          _currentIndex < _images.length - 1 ? "Next" : "Login",
                          style: const TextStyle(color: white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_currentIndex < _images.length - 1)
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, LoginScreeen.routeName);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Set the border radius here
                              ),
                              backgroundColor: white),
                          child: const Text(
                            "Skip",
                            style: TextStyle(color: blackBase),
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
    );
  }
}
