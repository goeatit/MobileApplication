import 'package:eatit/Screens/profile/screen/edit_profile.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile-screen";
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(IconData(0xf0347, fontFamily: 'MaterialIcons'),
                  color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Consumer<UserModelProvider>(
                        builder: (ctx, cartProvider, child) {
                      UserResponse? user =
                          ctx.watch<UserModelProvider>().userModel;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.useremail ?? 'bj****@eatitgo.com',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, EditProfileScreen.routeName);
                            },
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    })),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Menu Options
            const Row(
              children: [
                Expanded(
                  child: OptionCard(
                    icon: Icons.bookmark,
                    color: Colors.green,
                    text: 'My Bookings',
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: OptionCard(
                    icon: Icons.folder,
                    color: Colors.teal,
                    text: 'Collection',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact Support
            const OptionCard(
              icon: Icons.help,
              color: Colors.blue,
              text: 'Contact Support',
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const OptionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
