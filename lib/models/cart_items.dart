import 'package:eatit/models/dish_retaurant.dart';

class CartItem {
  final String id; // Unique identifier
  final String restaurantName;
  final String orderType;
  final AvailableDish dish;
  int quantity;
  final String location;

  CartItem({
    required this.id,
    required this.restaurantName,
    required this.orderType,
    required this.dish,
    required this.quantity,
    required this.location,
  });

  // Convert CartItem to a Map (for JSON encoding)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'orderType': orderType,
      'dish': dish.toMap(),
      'quantity': quantity,
      'location': location,
    };
  }

  // Create a CartItem from a Map (for JSON decoding)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
        id: map['id'],
        restaurantName: map['restaurantName'],
        orderType: map['orderType'],
        dish: AvailableDish.fromMap(map['dish']),
        quantity: map['quantity'],
        location: map['location']
    );
  }
}
