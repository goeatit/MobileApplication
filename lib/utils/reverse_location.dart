import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String key = 'AIzaSyCjmfQmCwj-979ON6348F86vUyhVGuXjNk';
const String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

Future<Map<String, String>?> reverseGeocode(double lat, double lng) async {
  try {
    final params = {'latlng': '$lat,$lng', 'key': key};
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        String fullAddress = data['results'][0]['formatted_address'];

        final result = data['results'][0];
        String city = '';
        String country = '';

        for (var component in result['address_components']) {
          if (component['types'].contains('locality')) {
            city = component['long_name'] ?? "";
          }
          if (component['types'].contains('country')) {
            country = component['long_name'] ?? "";
          }
        }

        return {'city': city, 'country': country,'fullAddress':fullAddress};
      } else {
        if (kDebugMode) {
          print('Geocoding API error: ${data['status']}');
        }
        return null;
      }
    } else {
      if (kDebugMode) {
        print('Network or other error: ${response.statusCode}');
      }
      return null;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error: $error');
    }
    return null;
  }
}
