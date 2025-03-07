import 'dart:async';
import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:eatit/Screens/noftification/screen/notification_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/utils/reverse_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationScreen extends StatefulWidget {
  static const routeName = "/location-screen";
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controllerMap = Completer();
  final TextEditingController _controller = TextEditingController();

  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(28.7041, 77.1025), // Default location (e.g., Delhi, India)
    zoom: 1.0,
  );
  LatLng _currentLatLng = const LatLng(28.7041, 77.1025);

  String country = "";
  String city = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (kDebugMode) {
        print("Location permission granted");
      }
      _fetchLocation();
      // Proceed with accessing the location
    } else {
      bool isOpened = await Geolocator.openAppSettings();
      if (!isOpened) {
        if (kDebugMode) {
          print("Failed to open app settings.");
        }
      }
      // requestLocationPermission();
      // Handle the case where permission is denied
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => isLoading = true);

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
          msg: "Please enable location permissions.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
        return;
      }
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100,
      );
      Position currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setDouble("lat", currentPosition.latitude);
      prefs.setDouble("log", currentPosition.longitude);

      Map<String, String>? location = await reverseGeocode(
          currentPosition.latitude, currentPosition.longitude);

      if (location != null) {
        setState(() {
          _currentLatLng =
              LatLng(currentPosition.latitude, currentPosition.longitude);
          _currentCameraPosition =
              CameraPosition(target: _currentLatLng, zoom: 15);
          city = location['city'] ?? '';
          country = location['country'] ?? '';
          String address = location['fullAddress'] ?? '';
          prefs.setString("full_address", address);
          prefs.setString("city", city);
          prefs.setString("country", country);
          _controller.text = address;
          isLoading = false;
        });
        final GoogleMapController controller = await _controllerMap.future;
        controller.animateCamera(
            CameraUpdate.newCameraPosition(_currentCameraPosition));
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching location: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controllerMap.complete(controller);
            },
            initialCameraPosition: _currentCameraPosition,
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: _currentLatLng,
                infoWindow: const InfoWindow(title: 'Your Current Location'),
              ),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) const CircularProgressIndicator(),
                  const Text(
                    "Hang on! We will find restaurants for you.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the address or select on the map.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(20)), // Added small border radius
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () {
                        if (!isLoading) {
                          Navigator.pushReplacementNamed(
                              context, NotificationScreen.routeName);
                        } else {
                          requestLocationPermission();
                        }
                      },
                      child: const Text('Next',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
