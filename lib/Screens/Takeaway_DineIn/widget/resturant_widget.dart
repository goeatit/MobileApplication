import 'package:eatit/Screens/Takeaway_DineIn//screen/singe_restaurant_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, SingleRestaurantScreen.routeName,
            arguments: {
              'name': widget.restaurantName,
              'location': widget.location,
              'id': widget.id
            });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.black,
                      ),
                    ),
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
                              color: success,
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
                        style: const TextStyle(color: cusineType, fontSize: 14),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: double.infinity,
                height: 2,
                color: neutrals200,
              ),
            ),

            // Promotion Section (Conditional Rendering)
            if (widget.promotionText != null && widget.promoCode != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    gradient: offerGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
