import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class OrderTypeProvider extends ChangeNotifier {
  int _orderType = 0;
  int _homeState = 0;
  int get orderType => _orderType;
  int get homeState => _homeState;

  void changeHomeState(int ort) {
    if (ort == 0 || ort == 1) {
      _homeState = ort;
      _orderType = ort;
    } else {
      _homeState = ort;
    }
    notifyListeners();
  }

  void changeOrderType(int ort) {
    _orderType = ort;
    _homeState = ort;
    notifyListeners();
  }
}
