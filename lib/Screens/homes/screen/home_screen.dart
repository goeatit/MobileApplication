import 'package:eatit/Screens/Takeaway_DineIn//screen/dine_in_screen.dart';
import 'package:eatit/Screens/Takeaway_DineIn//screen/take_away_screen.dart';
import 'package:eatit/Screens/cart_screen/screen/cart_page.dart';
import 'package:eatit/Screens/profile/screen/profile_screen.dart';
import 'package:eatit/Screens/search/screen/search_screen.dart';
import 'package:eatit/main.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home-screen";
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List<Widget> screens = [];
  var _currentPage = 0;
  var screenWidth = 0.0;

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
    screenWidth = MediaQuery.sizeOf(context).width * 0.35;
    _currentPage = context.watch<OrderTypeProvider>().homeState;

    return PopScope(
        canPop: _currentPage == 0, // Allow pop only if on Dine-In screen
        onPopInvokedWithResult: (bool didPop, res) {
          if (!didPop) {
            if (_currentPage != 0) {
              context.read<OrderTypeProvider>().changeHomeState(0);
            }
          }
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _currentPage == 2
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Center(
                    child: Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(width: 2),
                        // ),
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
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Home',
                                            style: textTheme?.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.47, // Constrain width
                                        child: Text(
                                          fullAddress,
                                          style: textTheme?.bodySmall?.copyWith(
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Adds ellipsis
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
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, SearchScreen.routeName);
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: SvgPicture.asset(
                                      'assets/svg/search.svg',
                                      color: primaryColor,
                                      width: 25,
                                      height: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, ProfileScreen.routeName);
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: CircleAvatar(backgroundColor: const Color(0xFFF4F4F4),
                                      radius: 20,
                                      child: ClipOval(
                                        child: SvgPicture.asset(
                                          "assets/svg/profile.svg",
                                          fit: BoxFit.cover,
                                          width: 40, // Adjust as needed
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                                // ),
                              )
                            ],
                          ),
                        )),
                  )),
          body: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                // Body content here
                Expanded(
                  child: IndexedStack(
                    index: _currentPage,
                    children: const [
                      DineInScreen(),
                      TakeAwayScreen(),
                      CartPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            padding: EdgeInsets.zero,
            elevation: 2,
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                bottomNavigationItem(
                  imageIcon:
                      "assets/svg/dine-in-${_currentPage == 0 ? "select" : "unselect"}.svg",
                  label: "Dine in",
                  isSelected: _currentPage == 0,
                  onClick: () {
                    if (_currentPage != 0) {
                      context.read<OrderTypeProvider>().changeHomeState(0);
                    }
                  },
                ),
                bottomNavigationItem(
                  imageIcon:
                      "assets/svg/takeaway-${_currentPage == 1 ? "select" : "unselect"}.svg",
                  label: "TakeAway",
                  isSelected: _currentPage == 1,
                  onClick: () {
                    if (_currentPage != 1) {
                      context.read<OrderTypeProvider>().changeHomeState(1);
                    }
                  },
                ),
                bottomNavigationItem(
                  imageIcon:
                      "assets/svg/cart-${_currentPage == 2 ? "select" : "unselect"}.svg",
                  label: "Cart",
                  isSelected: _currentPage == 2,
                  onClick: () {
                    if (_currentPage != 2) {
                      context.read<OrderTypeProvider>().changeHomeState(2);
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Widget bottomNavigationItem({
    required String imageIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onClick,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onClick,
          child: Container(
            color: white,
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.only(bottom: 2),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                isSelected
                    ? SizedBox(
                        width: screenWidth,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, _) {
                            return const ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                              // child: LinearProgressIndicator(
                              //   value: value,
                              //   minHeight: 3.5,
                              //   valueColor: const AlwaysStoppedAnimation(
                              //       primaryColorVariant),
                              //   backgroundColor: white,
                              // ),
                            );
                          },
                        ),
                      )
                    : SizedBox(
                        height: 4,
                        width: screenWidth,
                      ),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      imageIcon, height: 25,
                      width: 25,
                      // colorFilter: ColorFilter.mode(isSelected ? primaryColor : grey, )
                    ),
                    // Image.asset(
                    //   imageIcon,
                    //   color: isSelected ? primaryColor : grey,
                    // ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      label,
                      style: textTheme?.bodySmall?.copyWith(
                          color: isSelected ? darkBlack : bottomnavcolor),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}
