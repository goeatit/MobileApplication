import 'package:flutter/material.dart';
import 'package:eatit/models/cart_items.dart';
import 'package:eatit/models/dish_retaurant.dart';
import 'package:eatit/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  // Restaurant information
  String? restaurantId;
  String? restaurantName;
  String? orderType;
  int restaurantWaitingTime = 30;
  String restaurantTime = "11:00 AM - 11:00 PM";
  bool forceClose = false;

  // Order details
  List<CartItem> cartItems = [];
  double subTotal = 0;
  double gst = 0;
  double grandTotal = 0;

  // Time and people selection
  String? selectedTime;
  String numberOfPeople = "";

  // Current data from API
  CurrentData? currentData;

  // Orders
  List<Order> _orders = [];

  // Getters
  String? get getRestaurantName => restaurantName;
  String? get getOrderType => orderType;
  int get getRestaurantWaitingTime => restaurantWaitingTime;
  String get getRestaurantTime => restaurantTime;
  bool get getForceClose => forceClose;
  List<CartItem> get getCartItems => cartItems;
  double get getSubTotal => subTotal;
  double get getGst => gst;
  double get getGrandTotal => grandTotal;
  String? get getSelectedTime => selectedTime;
  String get getNumberOfPeople => numberOfPeople;
  CurrentData? get getCurrentData => currentData;
  List<Order> get getOrders => _orders;

  // Initialize with restaurant and order details
  void initializeOrder({
    required String id,
    required String name,
    required String type,
    required List<CartItem> items,
  }) {
    restaurantId = id;
    restaurantName = name;
    orderType = type;
    cartItems = items;
    calculateTotals();
    notifyListeners();
  }

  // Update with current data from API
  void updateWithCurrentData(CurrentData data) {
    currentData = data;
    restaurantWaitingTime = data.restaurantWaitingTime;
    restaurantTime = data.restaurantTime;
    forceClose = data.forceClose;
    notifyListeners();
  }

  // Calculate order totals
  void calculateTotals() {
    subTotal = cartItems.fold(
        0, (sum, item) => sum + (item.dish.resturantDishPrice * item.quantity));
    gst = subTotal * 0.18; // Assuming GST is 18%
    grandTotal = subTotal + gst;
    notifyListeners();
  }

  // Add order
  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  // Update cart items
  void updateCartItems(List<CartItem> items) {
    cartItems = items;
    calculateTotals();
    notifyListeners();
  }

  // Set selected time
  void setSelectedTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  // Set number of people
  void setNumberOfPeople(String people) {
    numberOfPeople = people;
    notifyListeners();
  }

  // Clear order data
  void clearOrder() {
    restaurantId = null;
    restaurantName = null;
    orderType = null;
    cartItems = [];
    selectedTime = null;
    numberOfPeople = '';
    subTotal = 0;
    gst = 0;
    grandTotal = 0;
    currentData = null;
    notifyListeners();
  }
}
