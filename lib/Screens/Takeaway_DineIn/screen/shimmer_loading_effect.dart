// lib/widgets/shimmer_loading_effect.dart

import 'package:flutter/material.dart';

class ShimmerLoadingEffect extends StatefulWidget {
  const ShimmerLoadingEffect({super.key});

  @override
  _ShimmerLoadingEffectState createState() => _ShimmerLoadingEffectState();
}

class _ShimmerLoadingEffectState extends State<ShimmerLoadingEffect>
    with TickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  final _shimmerGradient = LinearGradient(
    colors: [
      Colors.grey[200]!,
      Colors.grey[300]!,
      Colors.grey[200]!,
    ],
    stops: const [0, 0.5, 1],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  late final _animation = Tween<Alignment>(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ),
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Shimmer effect for banner
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[200]!,
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                      ],
                      stops: const [0, 0.5, 1],
                      begin: _animation.value,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
            // Shimmer effect for restaurant cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                          stops: const [0, 0.5, 1],
                          begin: _animation.value,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
