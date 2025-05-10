import 'package:eatit/models/my_booking_modal.dart';
import 'package:flutter/widgets.dart';

class MyBookingProvider extends ChangeNotifier {
  List<UserElement> _myBookings = [];
  List<UserElement> get myBookings => _myBookings;
  void setMyBookings(List<UserElement> bookings) {
    _myBookings.clear();
    _myBookings = bookings;
    notifyListeners();
  }
}
