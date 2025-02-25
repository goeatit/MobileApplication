class SearchModel {
  List<SearchResult> searchResults;
  List<TopRatedDish> topRatedDishes;

  SearchModel({
    required this.searchResults,
    required this.topRatedDishes,
  });

  // Factory method to parse the API response
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    var searchResultsList = (json['searchResults'] as List)
        .map((item) => SearchResult.fromJson(item))
        .toList();
    var topRatedDishesList = (json['topRatedDishes'] as List)
        .map((item) => TopRatedDish.fromJson(item))
        .toList();

    return SearchModel(
      searchResults: searchResultsList,
      topRatedDishes: topRatedDishesList,
    );
  }
}

class SearchResult {
  String id;
  String restaurantName;
  SearchResultRestaurantAddress restaurantAddress;
  String restaurantPhoneNumber;
  dynamic restaurantRating;

  SearchResult(
      {required this.id,
      required this.restaurantName,
      required this.restaurantAddress,
      required this.restaurantPhoneNumber,
      required this.restaurantRating});

  // Factory method to parse SearchResult JSON
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['_id'],
      restaurantName: json['restaurantName'],
      restaurantAddress:
          SearchResultRestaurantAddress.fromJson(json['restaurantAddress']),
      restaurantPhoneNumber: json['restaurantPhoneNumber'],
      restaurantRating: json['restaurantRating'],
    );
  }
}

class SearchResultRestaurantAddress {
  String id;
  String city;
  String state;
  String zipCode;
  String country;

  SearchResultRestaurantAddress({
    required this.id,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  // Factory method to parse RestaurantAddress JSON
  factory SearchResultRestaurantAddress.fromJson(Map<String, dynamic> json) {
    return SearchResultRestaurantAddress(
      id: json['_id'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
    );
  }
}

class TopRatedDish {
  String id;
  DishId dishId;
  dynamic rating;
  RestaurantIdDetailsAddress restaurantIdDetails;

  TopRatedDish(
      {required this.id,
      required this.dishId,
      required this.rating,
      required this.restaurantIdDetails});

  // Factory method to parse TopRatedDish JSON
  factory TopRatedDish.fromJson(Map<String, dynamic> json) {
    return TopRatedDish(
      id: json['_id'],
      dishId: DishId.fromJson(json['dishId']),
      rating: json['rating'],
      restaurantIdDetails: RestaurantIdDetailsAddress.fromJson(
          json['restaurantIdDetailsAddress']),
    );
  }
}

class DishId {
  String dishName;

  DishId({
    required this.dishName,
  });

  // Factory method to parse DishId JSON
  factory DishId.fromJson(Map<String, dynamic> json) {
    return DishId(
      dishName: json['dishName'],
    );
  }
}

class RestaurantIdDetailsAddress {
  RestaurantIdDetailsAddressRestaurantAddress restaurantAddress;
  String restaurantName;
  String id;

  RestaurantIdDetailsAddress({
    required this.restaurantAddress,
    required this.restaurantName,
    required this.id,
  });

  // Factory method to parse RestaurantId JSON
  factory RestaurantIdDetailsAddress.fromJson(Map<String, dynamic> json) {
    return RestaurantIdDetailsAddress(
      restaurantAddress: RestaurantIdDetailsAddressRestaurantAddress.fromJson(
          json['restaurantAddress']),
      restaurantName: json['restaurantName'],
      id: json['restaurantId'],
    );
  }
}

class RestaurantIdDetailsAddressRestaurantAddress {
  String city;
  String country;

  RestaurantIdDetailsAddressRestaurantAddress({
    required this.city,
    required this.country,
  });

  // Factory method to parse RestaurantIdRestaurantAddress JSON
  factory RestaurantIdDetailsAddressRestaurantAddress.fromJson(
      Map<String, dynamic> json) {
    return RestaurantIdDetailsAddressRestaurantAddress(
      city: json['city'],
      country: json['country'],
    );
  }
}
