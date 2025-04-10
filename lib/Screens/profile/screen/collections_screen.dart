import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../provider/saved_restaurants_provider.dart';
import '../../Takeaway_DineIn/widget/resturant_widget.dart';

class CollectionsScreen extends StatelessWidget {
  static const routeName = '/collections-screen';

  const CollectionsScreen({Key? key}) : super(key: key);

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
            return const Center(
              child: Text('No saved restaurants yet'),
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
