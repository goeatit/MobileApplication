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
    required orderType,
    required status,
    required totalAmount,
  });

  get numberOfPeople => null;

  get totalAmount => null;

  get status => null;
}

class OrderItem {
  String name;
  int quantity;

  OrderItem({
    required this.name,
    required this.quantity,
    required price,
  });

  get price => null;
}
