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
  final List<String> items;
  final String instructions;
  final String restaurantId;
  final List<CartItem> allItems;
  final int index;

  const CartItemWidget({
    super.key,
    required this.restaurantName,
    required this.orderType,
    required this.imageUrl,
    required this.items,
    required this.instructions,
    required Icon icon,
    required this.restaurantId,
    required this.allItems,
    required this.index,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  bool _isExpanded = false;

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/restaurant.png',
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
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
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Remove Items'),
                                  content: const Text(
                                      'Are you sure you want to remove all items from this restaurant?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final cartProvider =
                                            Provider.of<CartProvider>(context,
                                                listen: false);
                                        cartProvider.clearCart(
                                            widget.restaurantId,
                                            widget.orderType);
                                        Navigator.of(ctx).pop();
                                        // Find the CartPage state and call removeItem
                                        if (context.mounted) {
                                          final cartPageState =
                                              context.findAncestorStateOfType<
                                                  CartPageState>();
                                          if (cartPageState != null) {
                                            cartPageState
                                                .removeItem(widget.index);
                                          }
                                        }
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
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
