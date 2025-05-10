import 'dart:async';
import 'package:flutter/material.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  int _currentBannerIndex = 0;
  Timer? _timer;
  final List<String> bannerImages = [
    "assets/images/banner.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
  ];

  @override
  void initState() {
    super.initState();
    startBannerTimer();
  }

  void startBannerTimer() {
    _timer?.cancel();
    setState(() {
      _currentBannerIndex = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                bannerImages[_currentBannerIndex],
                key: ValueKey<int>(_currentBannerIndex),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == index
                    ? const Color(0xFFF8951D)
                    : const Color(0xFFFBCA8E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
