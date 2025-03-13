import 'dart:convert'; // For JSON encoding/decoding
import 'package:eatit/models/user_model.dart'; // Your UserModel class
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModelProvider extends ChangeNotifier {
  UserResponse? _userModel;

  UserResponse? get userModel => _userModel;

  static const _userModelKey = 'user_model';

  // Update the user model and save to SharedPreferences
  Future<void> updateUserModel(UserResponse userModel) async {
    _userModel = userModel;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userModelJson = json.encode(userModel.toJson());
    await prefs.setString(_userModelKey, userModelJson);
    notifyListeners();
  }

  Future<void> updateData(String name, String email, String? dob,
      String? gender, String countryCode, String phoneNumber) async {
    if (_userModel != null) {
      _userModel!.name = name;
      _userModel!.useremail = email;
      _userModel!.dob = dob;
      _userModel!.gender = gender;
      _userModel!.countryCode = countryCode;
      _userModel!.phoneNumber = phoneNumber;

      // Save updated data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userModelJson = json.encode(_userModel!.toJson());
      await prefs.setString(_userModelKey, userModelJson);

      notifyListeners();
    }
  }

  // Load the user model from SharedPreferences
  Future<void> loadUserModel() async {
    final prefs = await SharedPreferences.getInstance();
    final userModelJson = prefs.getString(_userModelKey);

    if (userModelJson != null) {
      final Map<String, dynamic> userModelMap = json.decode(userModelJson);
      _userModel = UserResponse.fromJson(userModelMap);
      notifyListeners();
    }
  }

  // Clear user data and remove from SharedPreferences
  Future<void> clearUserModel() async {
    _userModel = null;

    // Remove from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userModelKey);

    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    if (_userModel != null) {
      _userModel!.useremail = email;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> updatePhone(String phone) async {
    if (_userModel != null) {
      _userModel!.phoneNumber = phone;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> updateDob(String dob) async {
    if (_userModel != null) {
      _userModel!.dob = dob;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> updateGender(String gender) async {
    if (_userModel != null) {
      _userModel!.gender = gender;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userModelJson = json.encode(_userModel!.toJson());
    await prefs.setString(_userModelKey, userModelJson);
  }
}
