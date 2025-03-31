import 'dart:convert';

class Order {
  final String id;
  final String restaurantName;
  final List<OrderItem> items;
  final double subTotal;
  final String pickupTime;
  final String orderType;
  final String? dineIn;
  final String orderId;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int vendorWaitingTime;
  final String vendorComment;
  final String resturantDetails;

  Order({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.subTotal,
    required this.pickupTime,
    required this.orderType,
    this.dineIn,
    required this.orderId,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.vendorWaitingTime,
    required this.vendorComment,
    required this.resturantDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      restaurantName: json['restaurantName'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      subTotal: (json['subTotal'] as num).toDouble(),
      pickupTime: json['pickupTime'],
      orderType: json['orderType'],
      dineIn: json['Dinein'],
      orderId: json['order_id'],
      orderStatus: json['orderStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      vendorWaitingTime: json['vendorWaitingTime'],
      vendorComment: json['vendorComment'],
      resturantDetails: json['resturantDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "restaurantName": restaurantName,
      "items": items.map((item) => item.toJson()).toList(),
      "subTotal": subTotal,
      "pickupTime": pickupTime,
      "orderType": orderType,
      "Dinein": dineIn,
      "order_id": orderId,
      "orderStatus": orderStatus,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "vendorWaitingTime": vendorWaitingTime,
      "vendorComment": vendorComment,
      "resturantDetails": resturantDetails,
    };
  }
}

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int type;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      type: json['type'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "type": type,
      "quantity": quantity,
    };
  }
}

// Function to parse list of orders from JSON
List<Order> parseOrders(String responseBody) {
  final parsed = json.decode(responseBody) as List<dynamic>;
  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}
