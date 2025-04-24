import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:eatit/Screens/noftification/screen/notification_screen.dart';

class RestaurantAddressScreen extends StatefulWidget {
  static const routeName = '/restaurant-address';
  const RestaurantAddressScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantAddressScreen> createState() =>
      _RestaurantAddressScreenState();
}

class _RestaurantAddressScreenState extends State<RestaurantAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _buildingNoController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String _error = '';
  LatLng _currentPosition = const LatLng(28.7041, 77.1025); // Default: Delhi
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLocationSelected = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupMarker();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _moveToLocation(_currentPosition);
    } catch (e) {
      setState(() {
        _error = '';
      });
    }
  }

  void _setupMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('restaurant_location'),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateAddressFromLatLng(newPosition);
          },
        ),
      };
    });
  }

  Future<void> _updateAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _searchController.text =
              '${place.subLocality} ${place.locality}'.trim();
          // Combine area details with postal code
          String areaText = '';
          if (place.subLocality?.isNotEmpty ?? false) {
            areaText += place.subLocality!;
          }
          if (place.thoroughfare?.isNotEmpty ?? false) {
            areaText += areaText.isEmpty
                ? place.thoroughfare!
                : ', ${place.thoroughfare}';
          }
          if (place.postalCode?.isNotEmpty ?? false) {
            areaText +=
                areaText.isEmpty ? place.postalCode! : ' - ${place.postalCode}';
          }
          _areaController.text = areaText;
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _countryController.text = place.country ?? '';
          _currentPosition = position;
          _isLocationSelected = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching address details';
      });
    }
  }

  Future<void> _moveToLocation(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
    _updateAddressFromLatLng(position);
    _setupMarker();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      const apiKey =
          'AIzaSyCjmfQmCwj-979ON6348F86vUyhVGuXjNk'; // Replace with your API key
      final response = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:in'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(
              data['predictions'].map((prediction) => {
                    'description': prediction['description'],
                    'place_id': prediction['place_id'],
                  }),
            );
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error searching for places';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _selectPlace(String placeId) async {
    try {
      const apiKey =
          'AIzaSyCjmfQmCwj-979ON6348F86vUyhVGuXjNk'; // Replace with your API key
      final response = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final newPosition = LatLng(location['lat'], location['lng']);

          setState(() {
            _searchResults = [];
          });

          await _moveToLocation(newPosition);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error selecting place';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SvgPicture.asset(
              'assets/svg/graybackArrow.svg',
              width: 31,
              height: 30,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: const Text(
          'Select Address',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/svg/search.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    suffixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    _searchPlaces(value);
                  },
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchResults[index]['description']),
                          onTap: () {
                            _selectPlace(_searchResults[index]['place_id']);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition,
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onTap: (LatLng position) {
                        _moveToLocation(position);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _areaController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Area / Sector / Locality / Postal Code*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a location from the map';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'City*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a location from the map';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // After the existing city field
                TextFormField(
                  controller: _stateController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'State*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a location from the map';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _countryController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Country*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a location from the map';
                    }
                    return null;
                  },
                ),

                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8951D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLocationSelected
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                // Get SharedPreferences instance
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                // Save the address details
                                await prefs.setDouble(
                                    "lat", _currentPosition.latitude);
                                await prefs.setDouble(
                                    "log", _currentPosition.longitude);

                                // Construct and save full address
                                // In the save button onPressed callback
                                String fullAddress = '';
                                if (_buildingNoController.text.isNotEmpty) {
                                  fullAddress +=
                                      '${_buildingNoController.text}, ';
                                }
                                if (_floorController.text.isNotEmpty) {
                                  fullAddress += '${_floorController.text}, ';
                                }
                                fullAddress += '${_areaController.text}, ';
                                if (_landmarkController.text.isNotEmpty) {
                                  fullAddress +=
                                      '${_landmarkController.text}, ';
                                }
                                fullAddress += '${_cityController.text}, ';
                                fullAddress += '${_stateController.text}, ';
                                fullAddress += '${_countryController.text} ';
                                fullAddress += _postalCodeController.text;

                                await prefs.setString(
                                    "full_address", fullAddress);
                                await prefs.setString(
                                    "city", _cityController.text);
                                await prefs.setString(
                                    "state", _stateController.text);
                                await prefs.setString(
                                    "country", _countryController.text);

                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Address saved successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pop();

                                  // Navigate to notification screen
                                  Navigator.pushReplacementNamed(
                                    context,
                                    NotificationScreen.routeName,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error saving address: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        : null,
                    child: const Text(
                      'Save & Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _buildingNoController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    _stateController.dispose();
    _countryController.dispose();

    super.dispose();
  }
}
