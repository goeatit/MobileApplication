import 'package:eatit/Screens/homes/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../provider/saved_restaurants_provider.dart';
import '../../Takeaway_DineIn/widget/resturant_widget.dart';

class CollectionsScreen extends StatelessWidget {
  static const routeName = '/collections-screen';

  const CollectionsScreen({super.key});

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
          'My Collection',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer<SavedRestaurantsProvider>(
        builder: (context, savedRestaurantsProvider, child) {
          final savedRestaurants = savedRestaurantsProvider.savedRestaurants;

          if (savedRestaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/emptyCollection.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  const Text(
                    'No Restaurants Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8951D),
                    ),
                  ),
                  const SizedBox(height: 30), // Add spacing before the button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, HomePage.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8951D),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Explore Restaurants',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: savedRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = savedRestaurants[index];
              return RestaurantWidget(
                id: restaurant.id,
                imageUrl: restaurant.imageUrl,
                restaurantName: restaurant.restaurantName,
                cuisineType: restaurant.cuisineType,
                priceRange: restaurant.priceRange,
                rating: restaurant.rating,
                location: restaurant.location,
                lat: restaurant.lat,
                long: restaurant.long,
              );
            },
          );
        },
      ),
    );
  }
}
