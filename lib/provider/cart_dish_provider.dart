import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatit/models/cart_items.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, Map<String, List<CartItem>>> _restaurantCarts = {};

  Map<String, Map<String, List<CartItem>>> get restaurantCarts => _restaurantCarts;

  double get totalPrice {
    double total = 0.0;
    _restaurantCarts.forEach((restaurantName, orderTypes) {
      orderTypes.forEach((orderType, cartItems) {
        for (var item in cartItems) {
          total += item.dish.resturantDishPrice * item.quantity;
        }
      });
    });
    return total;
  }

  Future<void> saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Serialize _restaurantCarts to JSON
    final cartJson = json.encode(_restaurantCarts.map((restaurant, orderTypes) {
      return MapEntry(
        restaurant,
        orderTypes.map((orderType, items) {
          return MapEntry(orderType, items.map((item) => item.toMap()).toList());
        }),
      );
    }));

    // Save to SharedPreferences
    await prefs.setString('cart_items', cartJson);
  }

  Future<void> loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string
    final cartJson = prefs.getString('cart_items');
    if (cartJson != null) {
      // Deserialize JSON back to _restaurantCarts
      final decodedCart = json.decode(cartJson) as Map<String, dynamic>;

      _restaurantCarts.clear();
      decodedCart.forEach((restaurant, orderTypes) {
        _restaurantCarts[restaurant] = (orderTypes as Map<String, dynamic>).map(
              (orderType, items) {
            return MapEntry(
              orderType,
              (items as List<dynamic>)
                  .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
                  .toList(),
            );
          },
        );
      });
      notifyListeners();
    }
  }

  void addToCart(String restaurantName, String orderType, CartItem item) {
    if (!_restaurantCarts.containsKey(restaurantName)) {
      print("no resturant name");
      _restaurantCarts[restaurantName] = {};
    }

    if (!_restaurantCarts[restaurantName]!.containsKey(orderType)) {
      print("order type");
      _restaurantCarts[restaurantName]![orderType] = [];
    }

    final existingIndex = _restaurantCarts[restaurantName]![orderType]!
        .indexWhere((cartItem) => cartItem.id == item.id);

    if (existingIndex >= 0) {
      print("order Present");
      _restaurantCarts[restaurantName]![orderType]![existingIndex].quantity +=
          item.quantity;
    } else {
      print("item not present");
      _restaurantCarts[restaurantName]![orderType]!.add(item);
    }

    saveCartToStorage(); // Save changes to storage
    notifyListeners();
  }

  void incrementQuantity(String restaurantName, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[restaurantName]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        cartItems[index].quantity++;
        saveCartToStorage(); // Save changes to storage
        notifyListeners();
      }
    }
  }

  void decrementQuantity(String restaurantName, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[restaurantName]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        if (cartItems[index].quantity > 1) {
          cartItems[index].quantity--;
        } else {
          cartItems.removeAt(index);
        }
        if (cartItems.isEmpty) {
          _restaurantCarts[restaurantName]?.remove(orderType);

          // If the restaurant has no order types left, remove the restaurant
          if (_restaurantCarts[restaurantName]?.isEmpty ?? false) {
            _restaurantCarts.remove(restaurantName);
          }
        }

        saveCartToStorage(); // Save changes to storage
        notifyListeners();
      }
    }
  }

  void removeFromCart(String restaurantName, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[restaurantName]?[orderType];
    if (cartItems != null) {
      cartItems.removeWhere((item) => item.id == cartItemId);
      saveCartToStorage(); // Save changes to storage
      notifyListeners();
    }
  }

  void clearCart(String restaurantName, String orderType) {
    _restaurantCarts[restaurantName]?.remove(orderType);
    if (_restaurantCarts[restaurantName]?.isEmpty ?? false) {
      _restaurantCarts.remove(restaurantName);
    }
    saveCartToStorage(); // Save changes to storage
    notifyListeners();
  }

  int getQuantity(String restaurantName, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[restaurantName]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        return cartItems[index].quantity; // Return the quantity of the item
      }
    }
    return 0; // Return 0 if the item is not found
  }
  List<CartItem> getItemsByOrderTypeAndRestaurant(String restaurantName, String orderType) {
    if (_restaurantCarts.containsKey(restaurantName) &&
        _restaurantCarts[restaurantName]!.containsKey(orderType)) {
      return _restaurantCarts[restaurantName]![orderType]!;
    }
    return []; // Return an empty list if no items found for the specified restaurant and orderType
  }


}
