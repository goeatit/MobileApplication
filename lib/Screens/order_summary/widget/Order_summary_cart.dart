import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

class CartItemOrderSummary extends StatelessWidget {
  final String dishName;
  final int price;
  final int quantity;
  final int totalPrice;
  final bool isVeg;
  final String spiceLevel;
  final VoidCallback? onRemove;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CartItemOrderSummary({
    super.key,
    required this.dishName,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.isVeg,
    required this.spiceLevel,
    this.onRemove,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: isVeg
                          ? const Color(0xFF36F456)
                          : const Color(0xFFF44336)), // Updated hex colors
                ),
                child: Center(
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: isVeg
                        ? const Color(0xFF36F456)
                        : const Color(0xFFF44336), // Updated hex colors
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dishName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1D1929),
                        fontSize: 18,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEEDD9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onDecrement,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child:
                            Icon(Icons.remove, size: 14, color: Colors.black),
                      ),
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: onIncrement,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.add, size: 14, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹$price",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF737373),
                      fontSize: 16,
                    ),
              ),
              Text(
                "₹$totalPrice",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: black,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
          Text(
            spiceLevel,
            style: const TextStyle(
              fontSize: 14,
              color: fontColor7979,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Row(
              children: [
                Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF737373),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.play_arrow,
                  size: 14,
                  color: Color(0xFFF8951D),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
