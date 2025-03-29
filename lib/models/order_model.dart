class Order {
  String id;
  String restaurantName;
  String time;
  List<OrderItem> items;

  Order({
    required this.id,
    required this.restaurantName,
    required this.time,
    required this.items,
  });
}

class OrderItem {
  String name;
  int quantity;

  OrderItem({
    required this.name,
    required this.quantity,
  });
}
