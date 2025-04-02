import 'dart:convert';

class OrderDetailsResponse {
  bool success;
  dynamic message;
  List<UserElement> user;

  OrderDetailsResponse({
    required this.success,
    required this.message,
    required this.user,
  });
  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      user: (json['user'] as List)
          .map((item) => UserElement.fromJson(item))
          .toList(),
      success: json['success'],
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': user.map((item) => item.toJson()).toList(),
    };
  }
}

class UserElement {
  dynamic id;
  UserUser user;
  List<String?> location;
  List<String?> latitude;
  List<String?> longitude;

  var restaurant;

  UserElement({
    required this.id,
    required this.user,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory UserElement.fromJson(Map<String, dynamic> json) {
    return UserElement(
      id: json['_id'],
      user: UserUser.fromJson(json['user']),
      location: List<String?>.from(json['location']),
      latitude: List<String?>.from(json['latitude']),
      longitude: List<String?>.from(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UserUser {
  dynamic id;
  dynamic restaurantName;
  dynamic resturantDetails;
  List<Item> items;
  dynamic subTotal;
  dynamic pickupTime;
  dynamic orderStatus;
  dynamic orderType;
  dynamic orderId;
  int vendorWaitingTime;
  dynamic vendorComment;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic dinein;

  UserUser({
    required this.id,
    required this.restaurantName,
    required this.resturantDetails,
    required this.items,
    required this.subTotal,
    required this.pickupTime,
    required this.orderStatus,
    required this.orderType,
    required this.orderId,
    required this.vendorWaitingTime,
    required this.vendorComment,
    required this.createdAt,
    required this.updatedAt,
    this.dinein,
  });

  factory UserUser.fromJson(Map<String, dynamic> json) {
    return UserUser(
      id: json['_id'],
      restaurantName: json['restaurantName'],
      resturantDetails: json['resturantDetails'],
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
      subTotal: json['subTotal'],
      pickupTime: json['pickupTime'],
      orderStatus: json['orderStatus'],
      orderType: json['orderType'],
      orderId: json['order_id'],
      vendorWaitingTime: json['vendorWaitingTime'],
      vendorComment: json['vendorComment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      dinein: json['dinein'],
    );
  }

  get restaurantLatitude => null;

  get restaurantLongitude => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantName': restaurantName,
      'resturantDetails': resturantDetails,
      'items': items.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      'pickupTime': pickupTime,
      'orderStatus': orderStatus,
      'orderType': orderType,
      'orderId': orderId,
      'vendorWaitingTime': vendorWaitingTime,
      'vendorComment': vendorComment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dinein': dinein,
    };
  }
}

class Item {
  String id;
  String name;
  dynamic price;
  dynamic type;
  dynamic quantity;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'].toString(),
      price: json['price'].toDouble(),
      type: json['type'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'type': type,
      'quantity': quantity,
    };
  }
}
