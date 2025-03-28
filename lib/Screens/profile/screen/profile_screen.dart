import 'package:eatit/Screens/first_time_screen/screen/first_time_screen.dart';
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
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                // Perform logout
                Navigator.of(context).pushNamedAndRemoveUntil(
                  FirstTimeScreen.routeName,
                  (Route<dynamic> route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, EditProfileScreen.routeName);
                              },
                              splashColor: Colors.white,
                              highlightColor: Colors.transparent,
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: primaryColor,
                                  decorationThickness: 2,
                                  decorationStyle: TextDecorationStyle.solid,
                                ),
                                textAlign: TextAlign.left,
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
                    icon: Icons.checklist_outlined,
                    color: Color(0xFF417C45),
                    text: 'My Bookings',
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: OptionCard(
                    icon: Icons.bookmark_border,
                    color: Color(0xFF417C71),
                    text: 'Collection',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact Support
            const OptionCard(
              icon: Icons.help_outline_rounded,
              color: Colors.blue,
              text: 'Contact Support',
            ),
            const SizedBox(height: 16),
            // Logout Option
            OptionCard(
              icon: Icons.logout,
              color: Colors.red,
              text: 'Logout',
              onTap: () => _logout(context),
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
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
