import 'package:eatit/Screens/cart_screen/screen/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:eatit/provider/cart_dish_provider.dart';
import 'package:eatit/models/cart_items.dart';

class CartItemWidget extends StatefulWidget {
  final String restaurantName;
  final String orderType;
  final String imageUrl;
  final bool isAvailable;
  final List<String> items;
  final String instructions;
  final String restaurantId;
  final List<CartItem> allItems;
  final int index;
  final bool isRecentlyAdded;
  const CartItemWidget({
    super.key,
    required this.restaurantName,
    required this.orderType,
    required this.imageUrl,
    required this.isAvailable,
    required this.items,
    required this.instructions,
    required Icon icon,
    required this.restaurantId,
    required this.allItems,
    required this.index,
    required this.isRecentlyAdded,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool _isExpanded = false;
  // In the _CartItemWidgetState class, add this method to get a random restaurant image
  String getRestaurantImage(int index) {
    // Use modulo to cycle through images 0-9
    final imageIndex = index % 10;
    return 'assets/images/restaurant$imageIndex.png';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Then modify the Image.asset widget in the build method
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    // Use the widget.index passed from parent to get different images
                    getRestaurantImage(widget.index),
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to default image if the numbered image is not found
                      return Image.asset(
                        'assets/images/restaurant.png',
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.restaurantName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SvgPicture.asset('assets/svg/right-arrow.svg')
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.orderType,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF262626)),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.items.first,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (_isExpanded) ...[
                                      const SizedBox(height: 4),
                                      ...widget.items.skip(1).map((item) =>
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              item,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          )),
                                    ],
                                  ],
                                ),
                                Transform.rotate(
                                  angle: _isExpanded ? 3.14159 : 0,
                                  child: SvgPicture.asset(
                                      "assets/svg/down-arrow.svg"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.isRecentlyAdded) // Add this condition
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8951D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Recently Added',
                            style: TextStyle(
                              color: Color(0xFFF8951D),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/list.svg',
                                  width: 12,
                                  height: 12,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.instructions,
                                    style: const TextStyle(
                                        fontSize: 10, color: Color(0xFF718EBF)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    titlePadding: const EdgeInsets.only(
                                        top: 20, bottom: 5),
                                    title: Column(
                                      children: [
                                        const Icon(
                                          Icons.warning_rounded,
                                          color: Color(0xFFF8951D),
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Remove Items',
                                          style: Theme.of(ctx)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ],
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      top: 5,
                                      left: 24,
                                      right: 24,
                                      bottom: 20,
                                    ),
                                    content: Text(
                                      'Are you sure you want to remove all items from ${widget.restaurantName}?',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: const Color(0xFF666666),
                                          ),
                                    ),
                                    actions: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  side: const BorderSide(
                                                    color: Color(0xFFF8951D),
                                                    width: 1,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: const Color(
                                                            0xFFF8951D),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {
                                                  final cartProvider =
                                                      Provider.of<CartProvider>(
                                                          context,
                                                          listen: false);
                                                  cartProvider.clearCart(
                                                      widget.restaurantId,
                                                      widget.orderType);
                                                  Navigator.of(ctx).pop();
                                                  if (context.mounted) {
                                                    final cartPageState = context
                                                        .findAncestorStateOfType<
                                                            CartPageState>();
                                                    if (cartPageState != null) {
                                                      cartPageState.removeItem(
                                                          widget.index);
                                                    }
                                                  }
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFF8951D),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Remove',
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: SvgPicture.asset('assets/svg/delete.svg'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
