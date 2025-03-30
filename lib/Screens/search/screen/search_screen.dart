import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eatit/Screens/Takeaway_DineIn/screen/singe_restaurant_screen.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/network_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  void dispose() {
    _debounce?.cancel();
    searchResultsRestaurant.clear();
    topDishes.clear();
    super.dispose();
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8951D),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                'assets/svg/location.svg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Home',
                                    style: textTheme?.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.47, // Constrain width
                                child: Text(
                                  fullAddress,
                                  style: textTheme?.bodySmall?.copyWith(
                                    color: Colors.black,
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  size: 22,
                                  color: Colors.black87,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color:
                          Color(0x0D000000), // This is equivalent to #0000000D
                      blurRadius: 20,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.search, color: primaryColor),
                          hintText: "Search food or restaurant...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F4F4F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: white),
                        onPressed: () {
                          // Add your filter functionality here
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              if (!isLoading && searchResultsRestaurant.isNotEmpty)
                const Text("Trending near you",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    childAspectRatio:
                        0.78, // Fixed aspect ratio for better content fit
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
                                'id': item.id.toString(),
                              });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: AspectRatio(
                                  aspectRatio:
                                      16 / 9, // Fixed aspect ratio for image
                                  child: Image.asset(
                                    "assets/images/restaurant.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                // Wrap content in Expanded
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Space content evenly
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.restaurantName,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF139456),
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
                                          const Text(
                                            "Indian • Biryani",
                                            style: TextStyle(
                                              color: Color(0xFF4F4F4F),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Column(
                                        children: [
                                          Divider(
                                            height: 4,
                                            thickness: 1,
                                            color: Color(0xFFE5E5E5),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "₹1200-₹1500 for two",
                                            style: TextStyle(
                                                color: darkBlack, fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                    childAspectRatio:
                        0.78, // Fixed aspect ratio for better content fit
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
                              'id': item.restaurantIdDetails.id.toString(),
                            });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8)),
                              child: AspectRatio(
                                aspectRatio:
                                    16 / 9, // Fixed aspect ratio for image
                                child: Image.asset(
                                  "assets/images/restaurant.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              // Wrap content in Expanded
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Space content evenly
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item.dishId.dishName}, ${item.restaurantIdDetails.restaurantName}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                        Text(
                                          "Indian • Biryani",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹200",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
