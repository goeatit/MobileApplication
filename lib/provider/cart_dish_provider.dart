import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatit/models/cart_items.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, Map<String, List<CartItem>>> _restaurantCarts = {};
  bool _isLoading = false;

  Map<String, Map<String, List<CartItem>>> get restaurantCarts =>
      _restaurantCarts;
  bool get isLoading => _isLoading;

  double get totalPrice {
    double total = 0.0;
    _restaurantCarts.forEach((id, orderTypes) {
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
          return MapEntry(
              orderType, items.map((item) => item.toMap()).toList());
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

  void addToCart(String id, String orderType, CartItem item) {
    if (!_restaurantCarts.containsKey(id)) {
      _restaurantCarts[id] = {};
    }

    if (!_restaurantCarts[id]!.containsKey(orderType)) {
      _restaurantCarts[id]![orderType] = [];
    }

    final existingIndex = _restaurantCarts[id]![orderType]!
        .indexWhere((cartItem) => cartItem.id == item.id);

    if (existingIndex >= 0) {
      _restaurantCarts[id]![orderType]![existingIndex].quantity +=
          item.quantity;
    } else {
      _restaurantCarts[id]![orderType]!.add(item);
    }

    saveCartToStorage(); // Save changes to storage
    notifyListeners();
  }

  void incrementQuantity(String id, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[id]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        cartItems[index].quantity++;
        saveCartToStorage(); // Save changes to storage
        notifyListeners();
      }
    }
  }

  void decrementQuantity(String id, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[id]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        if (cartItems[index].quantity > 1) {
          cartItems[index].quantity--;
        } else {
          // Remove the item if quantity becomes 0
          cartItems.removeAt(index);

          // If this was the last item in the order type, remove the order type
          if (cartItems.isEmpty) {
            _restaurantCarts[id]?.remove(orderType);

            // If this was the last order type for the restaurant, remove the restaurant
            if (_restaurantCarts[id]?.isEmpty ?? false) {
              _restaurantCarts.remove(id);
            }
          }
        }

        saveCartToStorage(); // Save changes to storage
        notifyListeners();
      }
    }
  }

  void removeFromCart(String id, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[id]?[orderType];
    if (cartItems != null) {
      cartItems.removeWhere((item) => item.id == cartItemId);

      // Clean up empty lists
      if (cartItems.isEmpty) {
        _restaurantCarts[id]?.remove(orderType);

        // If the restaurant has no order types left, remove the restaurant
        if (_restaurantCarts[id]?.isEmpty ?? false) {
          _restaurantCarts.remove(id);
        }
      }

      saveCartToStorage(); // Save changes to storage
      notifyListeners();
    }
  }

  void clearCart(String id, String orderType) {
    _restaurantCarts[id]?.remove(orderType);
    if (_restaurantCarts[id]?.isEmpty ?? false) {
      _restaurantCarts.remove(id);
    }
    saveCartToStorage(); // Save changes to storage
    notifyListeners();
  }

  int getQuantity(String id, String orderType, String cartItemId) {
    final cartItems = _restaurantCarts[id]?[orderType];
    if (cartItems != null) {
      final index = cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        return cartItems[index].quantity; // Return the quantity of the item
      }
    }
    return 0; // Return 0 if the item is not found
  }

  List<CartItem> getItemsByOrderTypeAndRestaurant(String id, String orderType) {
    if (_restaurantCarts.containsKey(id) &&
        _restaurantCarts[id]!.containsKey(orderType)) {
      return _restaurantCarts[id]![orderType]!;
    }
    return []; // Return an empty list if no items found for the specified restaurant and orderType
  }

  int getTotalUniqueItems(String id, String orderType) {
    int totalItems = 0;
    if (_restaurantCarts.containsKey(id) &&
        _restaurantCarts[id]!.containsKey(orderType)) {
      for (var item in _restaurantCarts[id]![orderType]!) {
        totalItems += item.quantity;
      }
      return totalItems;
    }
    return 0; // Return 0 if no items found for the given restaurant and order type
  }

  bool hasRestaurantItems(String id) {
    return _restaurantCarts.containsKey(id) &&
        _restaurantCarts[id]!.values.any((items) => items.isNotEmpty);
  }

  void updateItemPrice(String restaurantId, String dishId, int newPrice) {
    _restaurantCarts.forEach((id, orderTypes) {
      if (id == restaurantId) {
        orderTypes.forEach((orderType, cartItems) {
          for (var item in cartItems) {
            if (item.dish.id == dishId) {
              item.dish.resturantDishPrice = newPrice;
            }
          }
        });
      }
    });
    saveCartToStorage();
    notifyListeners();
  }

  void removeItem(String restaurantId, String dishId) {
    // Create a list of entries to remove to avoid concurrent modification
    List<String> orderTypesToRemove = [];

    if (_restaurantCarts.containsKey(restaurantId)) {
      var orderTypes = _restaurantCarts[restaurantId]!;

      orderTypes.forEach((orderType, cartItems) {
        cartItems.removeWhere((item) => item.dish.id == dishId);

        // If this order type is now empty, mark it for removal
        if (cartItems.isEmpty) {
          orderTypesToRemove.add(orderType);
        }
      });

      // Remove empty order types
      for (var orderType in orderTypesToRemove) {
        _restaurantCarts[restaurantId]?.remove(orderType);
      }

      // If the restaurant has no order types left, remove the restaurant
      if (_restaurantCarts[restaurantId]?.isEmpty ?? false) {
        _restaurantCarts.remove(restaurantId);
      }
    }

    saveCartToStorage();
    notifyListeners();
  }

  void updateCartId(
      String newCartId, String dishId, String orderType, String restaurantId) {
    final cartItems = _restaurantCarts[restaurantId]?[orderType];

    if (cartItems != null) {
      for (var item in cartItems) {
        if (item.dish.id == dishId) {
          item.cartId = newCartId; // Update the cartId field
        }
      }
    }
    saveCartToStorage(); // Persist changes
    notifyListeners();
  }

  void printLongString(String text, {int chunkSize = 800}) {
    final pattern = RegExp('.{1,$chunkSize}', dotAll: true);
    for (final match in pattern.allMatches(text)) {
      print(match.group(0));
    }
  }

  Future<void> printStoredCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_items');

    if (cartJson != null) {
      final decoded = json.decode(cartJson);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
      print('✅ Printing full cart JSON in chunks:');
      printLongString(prettyJson); // 👈 this prints in chunks
    } else {
      print('🛑 No cart data found in storage.');
    }
  }

  void loadGroupedCartFromResponse(Map<String, dynamic> response) {
    _restaurantCarts.clear(); // Optional: clear existing cart data

    response.forEach((restaurantId, orderTypesMap) {
      orderTypesMap.forEach((orderType, itemsList) {
        for (var item in itemsList) {
          try {
            final cartItem = CartItem.fromMap(item as Map<String, dynamic>);

            // Add to the cart
            addToCart(restaurantId, orderType, cartItem);
          } catch (e) {
            print('❌ Error parsing CartItem: $e');
          }
        }
      });
    });
    saveCartToStorage();

    notifyListeners();
  }
}
