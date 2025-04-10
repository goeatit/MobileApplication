import 'dart:async';

import 'package:eatit/Screens/Takeaway_DineIn//screen/singe_restaurant_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/saved_restaurant_model.dart';
import 'package:eatit/provider/saved_restaurants_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RestaurantWidget extends StatefulWidget {
  final String imageUrl;
  final String restaurantName;
  final String cuisineType;
  final String priceRange;
  final String id;
  final double rating;
  final String location;
  final String? promotionText; // Make promotionText nullable
  final String? promoCode; // Make promoCode nullable
  final dynamic lat; // Make lat nullable
  final dynamic long; // Make long nullable
  const RestaurantWidget({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    required this.cuisineType,
    required this.priceRange,
    required this.rating,
    required this.location,
    this.promotionText, // Nullable
    this.promoCode, // Nullable
    this.lat,
    this.long,
    required this.id,
  });

  @override
  State<RestaurantWidget> createState() => _RestaurantWidgetState();
}

class _RestaurantWidgetState extends State<RestaurantWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaved = false;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _isSaved =
        context.read<SavedRestaurantsProvider>().isRestaurantSaved(widget.id);

    // Add auto-scroll timer
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      final List<String> images = _getRestaurantImages();
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel(); // Cancel timer when disposing
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getRestaurantImages() {
    // Extract the base name and number from the imageUrl
    String baseName = widget.imageUrl.split('/').last;
    baseName = baseName.replaceAll('.png', '').replaceAll('.jpg', '');

    return [
      'assets/images/$baseName.png',
      'assets/images/${baseName}table.png',
      'assets/images/${baseName}dish.png',
    ];
  }

  void _openMap(dynamic latitude, dynamic longitude, {String? name}) async {
    Uri googleMapsUrl;
    if (latitude == null || longitude == null) {
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name!)}");
    } else if (name != null && name.isNotEmpty) {
      // Try searching by name near the location
      final String encodedQuery =
          Uri.encodeComponent("$name near $latitude,$longitude");
      googleMapsUrl = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedQuery");
    } else {
      // Drop a pin at the location, Google Maps will automatically show the place name
      googleMapsUrl =
          Uri.parse("https://www.google.com/maps?q=$latitude,$longitude");
    }

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = _getRestaurantImages();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2.19),
            blurRadius: 21.46,
            color: Color(0x0D000000), // This is equivalent to #0000000D
          ),
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          //borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, SingleRestaurantScreen.routeName,
                arguments: {
                  'name': widget.restaurantName,
                  'location': widget.location,
                  'id': widget.id,
                  'imageUrl': widget.imageUrl,
                  'cuisineType': widget.cuisineType,
                  'priceRange': widget.priceRange,
                  'rating': widget.rating.toString(),
                });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: Image.asset(
                            images[index],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error_outline,
                                      size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Page Indicator
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          dotColor: Colors.white60,
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (widget.promoCode != null && widget.promotionText != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/svg/promotion.svg"),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              "Promoted",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer<SavedRestaurantsProvider>(
                      builder: (context, savedProvider, child) {
                        // Check if restaurant is saved
                        bool isSaved =
                            savedProvider.isRestaurantSaved(widget.id);

                        return GestureDetector(
                          onTap: () async {
                            if (isSaved) {
                              // Show delete confirmation
                              bool? remove = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  titlePadding:
                                      const EdgeInsets.only(top: 20, bottom: 5),
                                  title: Column(
                                    children: [
                                      const Icon(
                                        Icons.warning_rounded,
                                        color: Color(0xFFF8951D),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Remove Restaurant',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ],
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    top: 5,
                                    left: 24,
                                    right: 24,
                                    bottom: 20,
                                  ),
                                  content: Text(
                                    'Remove ${widget.restaurantName} from saved?',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: const Color(0xFF666666),
                                        ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                side: const BorderSide(
                                                  color: Color(0xFFF8951D),
                                                  width: 1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: const Color(
                                                          0xFFF8951D),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFF8951D),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Remove',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (remove == true) {
                                await savedProvider.toggleSaveRestaurant(
                                  SavedRestaurant(
                                    id: widget.id,
                                    imageUrl: widget.imageUrl,
                                    restaurantName: widget.restaurantName,
                                    cuisineType: widget.cuisineType,
                                    priceRange: widget.priceRange,
                                    rating: widget.rating,
                                    location: widget.location,
                                    lat: widget.lat,
                                    long: widget.long,
                                  ),
                                );
                              }
                            } else {
                              // Direct save
                              await savedProvider.toggleSaveRestaurant(
                                SavedRestaurant(
                                  id: widget.id,
                                  imageUrl: widget.imageUrl,
                                  restaurantName: widget.restaurantName,
                                  cuisineType: widget.cuisineType,
                                  priceRange: widget.priceRange,
                                  rating: widget.rating,
                                  location: widget.location,
                                  lat: widget.lat,
                                  long: widget.long,
                                ),
                              );
                            }
                          },
                          child: SvgPicture.asset(
                            isSaved
                                ? "assets/svg/Saved.svg"
                                : "assets/svg/bookmark.svg",
                            width: 45,
                            height: 45,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          gradient: mapLinearGradient,
                          borderRadius:
                              BorderRadius.circular(20), // Adjust as needed
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.lat != null && widget.long != null) {
                              _openMap(widget.lat, widget.long,
                                  name: widget.restaurantName);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Location not found'),
                                ),
                              );
                            }
                            _openMap(widget.lat, widget.long,
                                name: widget.restaurantName);
                          },
                          label:
                              const Text("Map", style: TextStyle(fontSize: 12)),
                          icon: const Icon(
                            IconData(0xf8ca,
                                fontFamily: "CupertinoIcons",
                                fontPackage: "cupertino_icons"),
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      )),
                ],
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurantName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: darkBlack,
                                    fontSize: 22,
                                    overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF139456),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${widget.rating.toString()} ⭐",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.cuisineType,
                          style: const TextStyle(
                            color: cusineType,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.priceRange,
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
              //   child: Container(
              //     width: double.infinity,
              //     height: 2,
              //     color: neutrals200,
              //   ),
              // ),

              // Promotion Section (Conditional Rendering)
              if (widget.promotionText != null && widget.promoCode != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: offerGradient,
                    border: Border(
                      top: BorderSide(
                        width: 1.07,
                        color: Color(0xFFE5E5E5), // Neutrals200 color
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.promotionText!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use "${widget.promoCode}" to avail flat 10% off.',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
