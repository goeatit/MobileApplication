class RestaurantModel {
  List<RestaurantsData> restaurants;
  String location;

  RestaurantModel({
    required this.restaurants,
    required this.location,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      location: json['location'] ?? '',
      restaurants: (json['restaurants'] as List<dynamic>)
          .map((restaurantJson) => RestaurantsData.fromJson(restaurantJson))
          .toList(),
    );
  }
}

class RestaurantsData {
  String restaurantName;
  String time;
  int ratings;
  String id;

  RestaurantsData({
    required this.restaurantName,
    required this.time,
    required this.ratings,
    required this.id,
  });

  factory RestaurantsData.fromJson(Map<String, dynamic> json) {
    return RestaurantsData(
      restaurantName: json['restaurantName'] ?? 'Unknown',
      time: json['time'] ?? '',
      ratings: json['rattings'] ?? 0,
      id: json['id'] ?? '',
    );
  }
}
