import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/saved_restaurant_model.dart';

class SavedRestaurantsProvider with ChangeNotifier {
  List<SavedRestaurant> _savedRestaurants = [];

  List<SavedRestaurant> get savedRestaurants => [..._savedRestaurants];

  Future<void> loadSavedRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('savedRestaurants');
    if (savedData != null) {
      final List<dynamic> decodedData = json.decode(savedData);
      _savedRestaurants =
          decodedData.map((item) => SavedRestaurant.fromMap(item)).toList();
      notifyListeners();
    }
  }

  Future<void> toggleSaveRestaurant(SavedRestaurant restaurant) async {
    final isExisting =
        _savedRestaurants.any((element) => element.id == restaurant.id);

    if (isExisting) {
      _savedRestaurants.removeWhere((element) => element.id == restaurant.id);
    } else {
      _savedRestaurants.add(restaurant);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedRestaurants',
        json.encode(_savedRestaurants.map((e) => e.toMap()).toList()));

    notifyListeners();
  }

  bool isRestaurantSaved(String id) {
    return _savedRestaurants.any((element) => element.id == id);
  }
}
