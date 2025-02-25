import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSlotSelection extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onClick;
  final String times;

  const TimeSlotSelection({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onClick,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.35;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        color: white,
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.only(bottom: 2),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            isSelected
                ? SizedBox(
              width: screenWidth,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 3.5,
                      valueColor:
                      const AlwaysStoppedAnimation(primaryColor),
                      backgroundColor:white,
                    ),
                  );
                },
              ),
            )
                : SizedBox(
              height: 4,
              width: screenWidth,
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.black : Colors.grey),
                ),
                Text(
                  times,
                  style: textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.black : Colors.grey),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
