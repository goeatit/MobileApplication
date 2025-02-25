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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle[index],
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15), // Set the border radius here
                            ),
                            backgroundColor: primaryColor),
                        child: Text(
                          _currentIndex < _images.length - 1 ? "Next" : "Login",
                          style: const TextStyle(color: white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, LoginScreeen.routeName);
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
