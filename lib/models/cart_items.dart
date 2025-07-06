import 'package:eatit/models/dish_retaurant.dart';

class CartItem {
  final String id; // Unique identifier
  final String restaurantName;
  final String restaurantImageUrl;
  final String orderType;
  final AvailableDish dish;
  int quantity;
  final String location;
  final DateTime? createTime;
  String? cartId;
  CartItem({
    required this.id,
    required this.restaurantName,
    required this.restaurantImageUrl,
    required this.orderType,
    required this.dish,
    required this.quantity,
    required this.location,
    this.createTime,
    this.cartId,
  });
  @override
  String toString() {
    return '''
CartItem(
  id: $id,
  restaurantName: $restaurantName,
  orderType: $orderType,
  quantity: $quantity,
  location: $location,
  createTime: ${createTime?.toIso8601String() ?? 'null'},
  cartId: ${cartId ?? 'null'},
  dish: ${dish.toString()}
)''';
  }

  // Convert CartItem to a Map (for JSON encoding)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'orderType': orderType,
      'dish': dish.toMap(),
      'quantity': quantity,
      'location': location,
      'cartId': cartId,
      'createTime': createTime?.toIso8601String(), // Add this line
    };
  }

  // Create a CartItem from a Map (for JSON decoding)

  factory CartItem.fromMap(Map<String, dynamic> map) {
    String? rawDate = map['createTime'];
    DateTime? parsedDate;
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {
        parsedDate = null;
      }
    }
    return CartItem(
      id: map['id'],
      restaurantName: map['restaurantName'],
      restaurantImageUrl: map['restaurantImageUrl'] ?? '',
      orderType: map['orderType'],
      dish: AvailableDish.fromMap(map['dish']),
      quantity: map['quantity'],
      location: map['location'],
      cartId: map['cartId'],
      createTime: parsedDate, // Add this line
    );
  }
}
