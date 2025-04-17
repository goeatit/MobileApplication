class SavedRestaurant {
  final String id;
  final String imageUrl;
  final String restaurantName;
  final String cuisineType;
  final String priceRange;
  final double rating;
  final String location;
  // final dynamic lat;
  // final dynamic long;

  SavedRestaurant({
    required this.id,
    required this.imageUrl,
    required this.restaurantName,
    required this.cuisineType,
    required this.priceRange,
    required this.rating,
    required this.location,
    // this.lat,
    // this.long,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'restaurantName': restaurantName,
      'cuisineType': cuisineType,
      'priceRange': priceRange,
      'rating': rating,
      'location': location,
      // 'lat': lat,
      // 'long': long,
    };
  }

  factory SavedRestaurant.fromMap(Map<String, dynamic> map) {
    return SavedRestaurant(
      id: map['id'],
      imageUrl: map['imageUrl'],
      restaurantName: map['restaurantName'],
      cuisineType: map['cuisineType'],
      priceRange: map['priceRange'],
      rating: map['rating'],
      location: map['location'],
      // lat: map['lat'],
      // long: map['long'],
    );
  }
}
