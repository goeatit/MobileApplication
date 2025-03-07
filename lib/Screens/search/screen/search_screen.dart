import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/network_manager.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "/search-page";

  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> recentSearches = ["Indian", "KFC", "Continental"];
  List<dynamic> searchResultsRestaurant = []; // Stores API search results
  List<dynamic> topDishes = [];
  bool isLoading = false; // Indicates if a search is in progress
  String? errorMessage; // Stores error message, if any

  void removeSearch(String search) {
    setState(() {
      recentSearches.remove(search);
    });
  }

  Timer? _debounce;
  void onSearchChanged(String query) {
    try {
      final Connectivity connectivity = Connectivity();
      final NetworkManager networkManager = NetworkManager(connectivity);
      final ApiRepository apiRepository = ApiRepository(networkManager);

      // Cancel any existing debounce timer
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () async {
        if (query.isNotEmpty) {
          setState(() {
            isLoading = true;
            errorMessage = null; // Reset error state
          });

          try {
            final response = await apiRepository.fetchSearch(query);

            if (response != null && response.statusCode == 200) {
              final responseResult = SearchModel.fromJson(response.data);

              setState(() {
                searchResultsRestaurant = responseResult.searchResults;
                topDishes = responseResult.topRatedDishes;
                isLoading = false;
              });
            } else {
              setState(() {
                isLoading = false;
                errorMessage = 'Failed to fetch results. Please try again.';
              });
            }
          } catch (e) {
            setState(() {
              isLoading = false;
              errorMessage = e.toString(); // Capture the error message
            });
          }
        } else {
          setState(() {
            searchResultsRestaurant.clear(); // Clear results for empty query
            topDishes.clear();
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  final List<Map<String, String>> trendingData = [
    {
      "name": "Sabzi - The Indian Cuisine",
      "type": "Indian • Biryani",
      "price": "₹1200-₹1500 for two",
      "rating": "4.3",
      "imageUrl": "https://via.placeholder.com/300"
    },
    {
      "name": "Aroma Mocha Café",
      "type": "Coffee • Snacks",
      "price": "₹200-₹1500 for two",
      "rating": "4.3",
      "imageUrl": "https://via.placeholder.com/300"
    },
    {
      "name": "Italian Bistro",
      "type": "Italian • Pasta",
      "price": "₹1000-₹1200 for two",
      "rating": "4.5",
      "imageUrl": "https://via.placeholder.com/300"
    },
    {
      "name": "Sushi Place",
      "type": "Japanese • Sushi",
      "price": "₹1800-₹2200 for two",
      "rating": "4.8",
      "imageUrl": "https://via.placeholder.com/300"
    },
  ];
  TextTheme? textTheme;
  String fullAddress = "";

  @override
  void initState() {
    super.initState();
    _retrieveFullAddress();
  }

  Future<void> _retrieveFullAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullAddress = prefs.getString("full_address") ?? "Address not available";
    });
  }

  @override
  Widget build(BuildContext context) {
    textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // decoration: BoxDecoration(
                  //   border: Border.all(width: 2),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 50,
                            child: Icon(Icons.location_on, color: primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Home ▾',
                                style: textTheme?.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.47, // Constrain width
                                child: Text(
                                  fullAddress,
                                  style: textTheme?.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // Adds ellipsis
                                  maxLines: 1, // Restricts to one line
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(width: 2),
                      //   ),
                      //   child:
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        // ),
                      )
                    ],
                  ),
                )),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  hintText: "Search food or restaurant...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              if (!isLoading && searchResultsRestaurant.isNotEmpty)
                const Text("Trending near you",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (!isLoading && searchResultsRestaurant.isNotEmpty)
                GridView.builder(
                  shrinkWrap:
                      true, // Makes the grid view take only the necessary space
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents the grid from scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: searchResultsRestaurant.length,
                  itemBuilder: (context, index) {
                    final item = searchResultsRestaurant[index];
                    return InkWell(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, SingleRestaurantScreen.routeName,
                              arguments: {
                                'name': item.restaurantName.toString(),
                                'location':
                                    item.restaurantAddress.city.toString(),
                              });
                        },
                        child: SizedBox(
                          height: 220,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  child: Image.asset(
                                      "assets/images/restaurant.png",
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.restaurantName,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: success,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "${item.restaurantRating} ⭐",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text("",
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text("200",
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
              if (!isLoading && topDishes.isNotEmpty)
                const Text("Top Dishes",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (!isLoading && topDishes.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: topDishes.length,
                  itemBuilder: (context, index) {
                    final item = topDishes[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, SingleRestaurantScreen.routeName,
                            arguments: {
                              'name': item.restaurantIdDetails.restaurantName
                                  .toString(),
                              'location': item
                                  .restaurantIdDetails.restaurantAddress.city
                                  .toString(),
                            });
                      },
                      child: SizedBox(
                        height: 220,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.asset(
                                    "assets/images/restaurant.png",
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                            child: Text(
                                          '${item.dishId.dishName}, ${item.restaurantIdDetails.restaurantName} ',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: success,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${item.rating} ⭐",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text("",
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text("200",
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
