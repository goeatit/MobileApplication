import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/main.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  static const routeNAme = "/edit-profile";
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserResponse? user = context.watch<UserModelProvider>().userModel;
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
                    Icons.arrow_back_ios_new,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Name
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? "User",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Date of Birth
            ProfileInputField(
              label: 'Date of Birth',
              icon: Icons.calendar_today,
              value: user?.dob ?? '01/01/2000',
              onEdit: () {},
            ),
            const SizedBox(height: 16),
            // Gender
            ProfileInputField(
              label: 'Gender',
              icon: Icons.person_outline,
              value: user?.gender ?? 'Male',
              onEdit: () {},
              isDropdown: true,
            ),
            const SizedBox(height: 16),
            // Email
            ProfileInputField(
              label: 'Email',
              icon: Icons.email_outlined,
              value: user?.useremail ?? 'bijeet@eatitgo.com',
              onEdit: () {},
            ),
            const SizedBox(height: 16),
            // Phone Number
            ProfileInputField(
              label: 'Phone Number',
              icon: Icons.phone,
              value: (user?.countryCode + user?.phoneNumber) ??
                  '+ 91   98765 43210',
              onEdit: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onEdit;
  final bool isDropdown;

  const ProfileInputField({
    Key? key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onEdit,
    this.isDropdown = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                if (isDropdown)
                  const Icon(Icons.arrow_drop_down, color: Colors.grey)
                else
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, color: primaryColor),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
