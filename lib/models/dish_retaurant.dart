class DishSchema {
  Restaurant restaurant;
  List<AvailableDish> availableDishes;
  List<String> categories;

  DishSchema({
    required this.restaurant,
    required this.availableDishes,
    required this.categories,
  });

  // Factory method for creating a DishSchema object from JSON
  factory DishSchema.fromJson(Map<String, dynamic> json) {
    return DishSchema(
      restaurant: Restaurant.fromJson(json['restaurant']),
      availableDishes: (json['availableDishes'] as List)
          .map((dish) => AvailableDish.fromJson(dish))
          .toList(),
      categories: List<String>.from(json['categories']),
    );
  }

  // Method for converting a DishSchema object to JSON
  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant.toJson(),
      'availableDishes': availableDishes.map((dish) => dish.toJson()).toList(),
      'categories': categories,
    };
  }
}

class AvailableDish {
  String id;
  bool available;
  dynamic ratting;
  dynamic resturantDishPrice;
  DishId dishId;

  AvailableDish({
    required this.id,
    required this.available,
    required this.ratting,
    required this.resturantDishPrice,
    required this.dishId,
  });

  factory AvailableDish.fromJson(Map<String, dynamic> json) {
    return AvailableDish(
      id: json['_id'],
      available: json['available'],
      ratting: json['ratting'],
      resturantDishPrice: json['resturantDishPrice'],
      dishId: DishId.fromJson(json['dishId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'available': available,
      'ratting': ratting,
      'resturantDishPrice': resturantDishPrice,
      'dishId': dishId.toJson(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'dishId': dishId,
      'id': id,
      'available': available,
      'ratting': ratting,
      'resturantDishPrice': resturantDishPrice,
    };
  }

  // Create an AvailableDish from a Map
  factory AvailableDish.fromMap(Map<String, dynamic> map) {
    return AvailableDish(
      dishId: DishId.fromJson(map['dishId'] as Map<String, dynamic>),
      resturantDishPrice: map['resturantDishPrice'],
      id: map['id'],
      available: map['available'],
      ratting: map['ratting'],
    );
  }
}

class DishId {
  String dishName;
  dynamic dishDescription;
  dynamic dishImageUrl;
  String dishCatagory;
  int dishType;

  DishId({
    required this.dishName,
    required this.dishDescription,
    required this.dishImageUrl,
    required this.dishCatagory,
    required this.dishType,
  });

  factory DishId.fromJson(Map<String, dynamic> json) {
    return DishId(
      dishName: json['dishName'],
      dishDescription: json['dishDescription'],
      dishImageUrl: json['dishImageUrl'],
      dishCatagory: json['dishCatagory'],
      dishType: json['dishType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'dishDescription': dishDescription,
      'dishImageUrl': dishImageUrl,
      'dishCatagory': dishCatagory,
      'dishType': dishType,
    };
  }
}

class Restaurant {
  dynamic resetTime;
  String id;
  String restaurantName;
  RestaurantAddress restaurantAddress;
  String restaurantAddressDetails;
  String restaurantPhoneNumber;
  String restaurantDescription;
  String restaurantImageUrl;
  int restaurantType;
  String restaurantTime;
  int minWaitingTime;
  dynamic resturantLatitute;
  dynamic resturantLongitute;
  bool forceClose;
  dynamic restaurantRating;
  List<String> addedCategory;

  Restaurant({
    required this.resetTime,
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantAddressDetails,
    required this.restaurantPhoneNumber,
    required this.restaurantDescription,
    required this.restaurantImageUrl,
    required this.restaurantType,
    required this.restaurantTime,
    required this.minWaitingTime,
    required this.resturantLatitute,
    required this.resturantLongitute,
    required this.forceClose,
    required this.restaurantRating,
    required this.addedCategory,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      resetTime: json['resetTime'],
      id: json['_id'],
      restaurantName: json['restaurantName'],
      restaurantAddress: RestaurantAddress.fromJson(json['restaurantAddress']),
      restaurantAddressDetails: json['restaurantAddressDetails'],
      restaurantPhoneNumber: json['restaurantPhoneNumber'],
      restaurantDescription: json['restaurantDescription'],
      restaurantImageUrl: json['restaurantImageUrl'],
      restaurantType: json['restaurantType'],
      restaurantTime: json['restaurantTime'],
      minWaitingTime: json['minWaitingTime'],
      resturantLatitute: json['resturantLatitute'],
      resturantLongitute: json['resturantLongitute'],
      forceClose: json['forceClose'],
      restaurantRating: json['restaurantRating'],
      addedCategory: List<String>.from(json['addedCategory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resetTime': resetTime,
      'id': id,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress.toJson(),
      'restaurantAddressDetails': restaurantAddressDetails,
      'restaurantPhoneNumber': restaurantPhoneNumber,
      'restaurantDescription': restaurantDescription,
      'restaurantImageUrl': restaurantImageUrl,
      'restaurantType': restaurantType,
      'restaurantTime': restaurantTime,
      'minWaitingTime': minWaitingTime,
      'resturantLatitute': resturantLatitute,
      'resturantLongitute': resturantLongitute,
      'forceClose': forceClose,
      'restaurantRating': restaurantRating,
      'addedCategory': addedCategory,
    };
  }
}

class RestaurantAddress {
  String id;
  String city;
  String state;
  String zipCode;
  String country;

  RestaurantAddress({
    required this.id,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) {
    return RestaurantAddress(
      id: json['_id'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}
