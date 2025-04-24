import 'package:flutter/foundation.dart';

class SelectedCategoryProvider with ChangeNotifier {
  String _selectedCategory = '';

  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategory = '';
    notifyListeners();
  }
}
