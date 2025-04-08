import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = const Color(0xFFD4D4D4),
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CouponSectionWidget extends StatelessWidget {
  const CouponSectionWidget({super.key});

  void _showCouponsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // Detect taps outside content
          onTap: () => Navigator.of(context).pop(), // Close when tapped outside
          child: GestureDetector(
            onTap: () {}, // Absorb taps inside to prevent bottom sheet closing
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All coupons',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              'assets/svg/mdi_cross-circle-outline.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 20,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            //vertical: 8,
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: SvgPicture.asset(
                                  'assets/svg/arcticons_cred.svg',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    '₹135 off on UPI orders via CRED UPI',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          letterSpacing: 0.1,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8951D),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Save ₹35 and get extra cashback with 2 coupons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SvgPicture.asset(
                  'assets/svg/cupon.svg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'Save ₹35 and get extra cashback with 2 coupons',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                    softWrap: true,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8951D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),

          // View all coupons + icon
          GestureDetector(
            onTap: () => _showCouponsBottomSheet(context),
            child: const Row(
              children: [
                Text(
                  'View all coupons',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF8951D),
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: Color(0xFFF8951D),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Dashed Divider
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(
              painter: DashedLinePainter(
                color: const Color(0xFFD4D4D4),
                dashWidth: 5,
                dashSpace: 3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CRED UPI Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  'assets/svg/arcticons_cred.svg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    '₹135 off on UPI orders via CRED UPI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                    softWrap: true,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8951D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
