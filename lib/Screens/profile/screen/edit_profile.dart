import 'package:eatit/Screens/profile/widgets/Phone_input_field.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:eatit/Screens/profile/service/edit_profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "/edit-profile";

  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreen();
}

class _EditProfileScreen extends State<EditProfileScreen> {
  String? _selectGender;
  String? dob;
  bool _hasChanges = false;
  Map<String, String?> _changes = {};

  final List<String> genderItems = ['Male', 'Female'];

  void _handleFieldChange(String field, String? value) {
    setState(() {
      _changes[field] = value;
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final editProfileService = EditProfileSerevice();
      bool success =
          await editProfileService.saveProfileChanges(_changes, context);

      if (success) {
        // Update the provider with new values
        final userProvider = context.read<UserModelProvider>();
        if (_changes.containsKey('email')) {
          userProvider.updateEmail(_changes['email']!);
        }
        if (_changes.containsKey('phone')) {
          userProvider.updatePhone(_changes['phone']!);
        }
        if (_changes.containsKey('dob')) {
          userProvider.updateDob(_changes['dob']!);
        }
        if (_changes.containsKey('gender')) {
          userProvider.updateGender(_changes['gender']!);
        }

        setState(() {
          _hasChanges = false;
          _changes.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save changes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                icon: Container(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 2,
                        top: 2,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 22,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_back_ios_new,
                        size: 22,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  if (_hasChanges) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Unsaved Changes'),
                        content:
                            const Text('Do you want to discard your changes?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back
                            },
                            child: const Text('Discard'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
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
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor,
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
              value: (user?.dob != null && user!.dob.isNotEmpty)
                  ? user.dob
                  : (dob ?? 'Tap to enter'),
              onSave: (String value) {
                if (user?.dob == null) {
                  _handleFieldChange('dob', value);
                  _selectDate(context);
                }
              },
              editIcon: false,
              isDatePicker: true,
            ),
            const SizedBox(height: 16),

            // Gender
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: user?.gender == null
                            ? DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  hint: Text(
                                    'Select Gender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  items: genderItems
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: _selectGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectGender = value;
                                      _handleFieldChange('gender', value);
                                    });
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    height: 40,
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                  ),
                                ),
                              )
                            : Text(
                                user?.gender ?? '',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email
            ProfileInputField(
              label: 'Email',
              icon: Icons.email_outlined,
              value: user?.useremail ?? '',
              editIcon: user?.loginThrough == "phoneNumber",
              isEmail: true,
              onSave: (String value) {
                if (value != user?.useremail) {
                  _handleFieldChange('email', value);
                }
              },
              editPressed: (bool value){
                print(value);
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            ProfileInputField(
              label: 'Phone Number',
              icon: Icons.send_to_mobile,
              value: user?.phoneNumber ?? '',
              editIcon: user?.loginThrough == "google",
              isPhone: true,
              onSave: (String value) {
                if (value != user?.phoneNumber) {
                  _handleFieldChange('phone', value);
                }
              },
            ),

            const SizedBox(height: 16),

            if (_hasChanges)
              TextButton(
                onPressed: _saveChanges,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              primaryColor: primaryColor,
              colorScheme: const ColorScheme.light(primary: primaryColor),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        });
    if (pickedDate != null) {
      String newDob =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      if (newDob != dob) {
        setState(() {
          dob = newDob;
          _handleFieldChange('dob', newDob);
        });
      }
    }
  }

  // Removed the _showGenderSelection method as we're now using a dropdown
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
