import 'dart:async';

import 'package:eatit/Screens/Auth/login_screen/screen/login_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

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
  Map<int, double> _indicatorFillProgress = {};
  Timer? _fillTimer;

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
  // Modify the _buildIndicator method
  Widget _buildIndicator(int index) {
    if (!_indicatorFillProgress.containsKey(index)) {
      _indicatorFillProgress[index] = 0.0;
      _startFillAnimation(index);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        double width = (i == index) ? 24 : 10;
        double height = (i == index) ? 10 : 10;
        Color color;

        if (i == index) {
          // Create gradient effect for active indicator
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(47),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    _indicatorFillProgress[index]!,
                    _indicatorFillProgress[index]!
                  ],
                  colors: const [
                    Color(0xFFF8951D), // Filling color
                    Color(0xFFFDDCB4), // Background color
                  ],
                ),
              ),
            ),
          );
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

// Add this method to handle the filling animation
  void _startFillAnimation(int index) {
    _fillTimer?.cancel();
    _indicatorFillProgress[index] = 0.0;

    _fillTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_indicatorFillProgress[index]! < 1.0) {
        setState(() {
          _indicatorFillProgress[index] = _indicatorFillProgress[index]! + 0.01;
        });
      } else {
        timer.cancel();
        if (index < _images.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
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
    _startFillAnimation(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fillTimer?.cancel();
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
                height: 530,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _startFillAnimation(index);
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
                          const SizedBox(height: 40),
                          Text(
                            _titles[index],
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1929),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle[index],
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEA8307)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 9),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _descriptions[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
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
                          style: const TextStyle(
                              color: white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
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
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(
                                color: Color(0xFFE5E5E5), // Neutrals200 color
                                width: 1.0,
                              ),
                            ),
                            backgroundColor: white,
                            elevation: 0, // Removes the box shadow
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color(0xFF1D1929),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
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
    );
  }
}
