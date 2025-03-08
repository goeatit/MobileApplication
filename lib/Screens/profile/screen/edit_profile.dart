import 'package:eatit/Screens/profile/widgets/Phone_input_field.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "/edit-profile";

  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreen();
}

class _EditProfileScreen extends State<EditProfileScreen> {
  String? _selectGender;
  String? dob;

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
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
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
            const SizedBox(height: 24),

            // Date of Birth (Editable if not present)
            ProfileInputField(
              label: 'Date of Birth',
              icon: Icons.calendar_today,
              value: dob ?? 'Tap to enter',
              onSave: (String value) {
                if (user?.dob == null) {
                  // Open date picker if dob is missing
                  _selectDate(context);
                }
              },
              editIcon: false,
            ),
            const SizedBox(height: 16),

            // Gender (Dropdown if not present)
            ProfileInputField(
              label: 'Gender',
              icon: Icons.person_outline,
              value: _selectGender ?? "Select Gender",
              onSave: (String value) {
                if (user?.gender == null) {
                  _showGenderSelection(context);
                }
              },
              isDropdown: user?.gender == null,
              editIcon: user?.gender == null ? true : false,
              // onSave: (String) {},
            ),
            const SizedBox(height: 16),

            // Email
            ProfileInputField(
              label: 'Email',
              icon: Icons.email_outlined,
              value: user?.useremail ?? 'bijeet@eatitgo.com',
              editIcon: user?.loginThrough == "phoneNumber",
              onSave: (String value) {
                print(value);
              },
              // onEdit: () {},
            ),
            const SizedBox(height: 16),

            // Phone Number
            ProfileInputField(
              label: 'Phone Number',
              icon: Icons.phone,
              value: (user?.countryCode ?? '') + (user?.phoneNumber ?? ''),
              editIcon: user?.loginThrough == "google",
              onSave: (String value) {
                print(value);
              },
              // onEdit: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Date Picker function
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryColor, // Header color
              colorScheme: const ColorScheme.light(primary: primaryColor),
              dialogBackgroundColor: Colors.white, // Calendar background
            ),
            child: child!,
          );
        });
    if (pickedDate != null) {
      // Convert to string and update user model
      setState(() {
        dob =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Gender Selection Dialog
  void _showGenderSelection(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Male"),
            onTap: () {
              setState(() {
                _selectGender = "Male";
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Female"),
            onTap: () {
              setState(() {
                _selectGender = "Female";
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// class ProfileInputField extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final String value;
//   final VoidCallback onEdit;
//   final bool isDropdown;
//   final bool editIcon;
//
//   const ProfileInputField({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.value,
//     required this.onEdit,
//     this.isDropdown = false,
//     required this.editIcon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: onEdit,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 Icon(icon, color: Colors.grey),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     value,
//                     style: const TextStyle(fontSize: 16, color: Colors.black),
//                   ),
//                 ),
//                 if (isDropdown)
//                   const Icon(Icons.arrow_drop_down, color: Colors.grey)
//                 else if (editIcon)
//                   GestureDetector(
//                     onTap: onEdit,
//                     child: const Icon(Icons.edit, color: primaryColor),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
