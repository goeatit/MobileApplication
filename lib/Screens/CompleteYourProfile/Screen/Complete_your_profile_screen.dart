import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eatit/Screens/CompleteYourProfile/Service/Complete_your_profile_service.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/Screens/first_time_screen/screen/first_time_screen.dart';
import 'package:eatit/Screens/noftification/services/fcm_token_service.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:eatit/Screens/Auth/login_screen/service/token_Storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = "/complete-your-profile";

  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCountry = "+91";
  String? _selectedGender;
  String? selectedFlag;
  bool isChecked = false;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController verifyOtpController = TextEditingController();
  final ValueNotifier<bool> isCheckedNotifier = ValueNotifier<bool>(false);
  late final CompleteYourProfileService completeYourProfileService;
  bool _servicesInitialized = false;

  bool isNameTouched = false;
  bool isEmailTouched = false;
  bool isDobTouched = false;
  bool isFormSubmitted = false;
  bool isPhoneTouched = false;
  bool showSendOtpEmail = false;
  bool showSendOtpPhone = false;
  bool isVerifyOtpTouched = false;
  bool showVerifyOtp = false;
  bool isSendOtpPressed = false;
  bool verifyEmail = false;
  bool verifyPhone = false;
  bool isDropdownOpen = false;
  bool isNamePresent = false;
  bool isEmailPresent = false;
  bool isPhonePresent = false;

  bool _isValidPhoneNumber() {
    final phoneNumber = phoneController.text;
    final validationRule = phoneValidationRules[selectedCountry];

    if (validationRule == null || phoneNumber.isEmpty) {
      return false;
    }

    final requiredLength = validationRule['minLength'];
    return phoneNumber.length == requiredLength;
  }

  UserResponse? _userModel;

  final List<Map<String, String>> countryList = [
    {"flag": "🇮🇳", "name": "IN", "code": "+91"},
    {"flag": "🇺🇸", "name": "USA", "code": "+1"},
    {"flag": "🇬🇧", "name": "UK", "code": "+44"},
    {"flag": "🇦🇺", "name": "AU", "code": "+61"},
    {"flag": "🇸🇦", "name": "SA", "code": "+966"}, // Added Saudi Arabia
  ];
  final Map<String, Map<String, dynamic>> phoneValidationRules = {
    '+91': {'minLength': 10, 'maxLength': 10, 'name': 'India'},
    '+1': {'minLength': 10, 'maxLength': 10, 'name': 'USA/Canada'},
    '+44': {'minLength': 10, 'maxLength': 11, 'name': 'UK'},
    '+61': {'minLength': 9, 'maxLength': 9, 'name': 'Australia'},
    '+966': {'minLength': 9, 'maxLength': 9, 'name': 'Saudi Arabia'},
    // Add more countries as needed
  };

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        // Default selected date
        firstDate: DateTime(1900),
        // Earliest date selectable
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
        } // Today's date
        );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        _validateForm();
      });
    }
  }

  bool get isFormValid {
    if (_formKey.currentState?.validate() == true &&
        isChecked &&
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        !showSendOtpPhone &&
        !showSendOtpEmail) {
      if (!isEmailPresent && !verifyEmail) {
        return false;
      } else if (!isPhonePresent && !verifyPhone) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void _validateForm() {
    setState(() {});
  }

  void _sendOtpEmail() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    var res = await completeYourProfileService.sendEmailOtp(
        emailController.text, context);
    setState(() {
      isLoading = false;
    });
    if (res) {
      setState(() {
        showSendOtpEmail = false;
        isSendOtpPressed = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Send OTP: ${res}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void _sendOtpPhone() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    var res = await completeYourProfileService.sendMobilePhoneOtp(
        selectedCountry!, phoneController.text, context);
    setState(() {
      isLoading = false;
    });
    if (res) {
      setState(() {
        showSendOtpPhone = false;
        isSendOtpPressed = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Send OTP: ${res}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void _verifyOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    if (isPhonePresent) {
      // email verify
      var res = await completeYourProfileService.verifyEmailOtp(
          emailController.text, context, verifyOtpController.text);
      setState(() {
        isLoading = false;
      });
      if (res) {
        setState(() {
          verifyEmail = true;
        });
      }
    }
    if (isEmailPresent) {
      //phone verify
      var res = await completeYourProfileService.verifyPhoneNumberOtp(
          phoneController.text,
          selectedCountry!,
          context,
          verifyOtpController.text);
      setState(() {
        isLoading = false;
      });
      if (res) {
        setState(() {
          verifyPhone = true;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 20, bottom: 5),
          title: Column(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF8951D),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Confirm Logout',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.only(
            top: 5,
            left: 24,
            right: 24,
            bottom: 20,
          ),
          content: Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF666666),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFFF8951D),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFFF8951D),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop(); // Close the dialog

                        // Clear all tokens
                        final tokenManager = TokenManager();

                        // Clear user data from provider
                        await context
                            .read<UserModelProvider>()
                            .clearUserModel();

                        final FcmTokenService fcmTokenService =
                            FcmTokenService(apiRepository: Provider.of<ApiRepository>(context, listen: false));
                        // Sign out from social providers if needed
                        try {
                          await GoogleSignIn().signOut();
                          await FacebookAuth.instance.logOut();
                          await fcmTokenService.removeTokenOnLogout();
                          await tokenManager.clearTokens();
                        } catch (e) {
                          print('Error signing out from social providers: $e');
                        }

                        // Navigate to first time screen and clear all routes
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          FirstTimeScreen.routeName,
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF8951D),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    isCheckedNotifier.dispose();
    _servicesInitialized = false;
    super.dispose();
  }

  void _submitForm() async {
    try {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        // ✅ Form is valid, proceed with the action
        // print("Form submitted successfully!");

        var res = await completeYourProfileService.completeYourProfile(
            nameController.text,
            emailController.text,
            dobController.text == "" ? null : dobController.text,
            _selectedGender,
            selectedCountry!,
            phoneController.text);
        setState(() {
          isLoading = false;
        });
        if (res != null) {
          if (res.statusCode == 200) {
            await context.read<UserModelProvider>().updateData(
                nameController.text,
                emailController.text,
                dobController.text == "" ? null : dobController.text,
                _selectedGender,
                selectedCountry!,
                phoneController.text);
            Navigator.pushReplacementNamed(context, LocationScreen.routeName);
          }
        }
      } else {
        // ❌ Form has errors, show validation messages
        setState(() {}); // Trigger rebuild to show errors
      }
    } on DioException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.response != null && e.response?.statusCode == 400) {
        // Handle 400 response (Invalid OTP case)
        final responseData =
            e.response?.data; // No need to use jsonDecode, Dio handles it
        String errorMessage = responseData['message'];
        if (errorMessage == "Email already exist") {
          setState(() {
            verifyEmail = false;
            isSendOtpPressed = false;
            showSendOtpEmail = false;
            emailController.clear();
          });
        }
        if (errorMessage == "Phone number already exist") {
          setState(() {
            verifyPhone = false;
            isSendOtpPressed = false;
            showSendOtpPhone = false;
            phoneController.clear();
          });
        }
        Fluttertoast.showToast(
          msg: "Failed to Complete profile: $errorMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
        print(e);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_servicesInitialized) {
      completeYourProfileService = CompleteYourProfileService(
          apiRepository: context.read<ApiRepository>());
      _servicesInitialized = true;
    }
    _userModel = context.read<UserModelProvider>().userModel;
    setState(() {
      if (_userModel?.name != null) {
        nameController.text = _userModel?.name;
        isNamePresent = true;
        isNameTouched = true;
      }
      if (_userModel?.useremail != null) {
        emailController.text = _userModel?.useremail;
        isEmailPresent = true;
        isEmailTouched = true;
      }
      if (_userModel?.phoneNumber != null) {
        phoneController.text = _userModel?.phoneNumber;
        selectedCountry = _userModel?.countryCode;
        isPhonePresent = true;
        isPhoneTouched = true;
      }
    });
    if (_userModel?.dob != null) {
      dobController.text = _userModel?.dob;
    }
    if (_userModel?.gender != null) {
      _selectedGender = _userModel?.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Complete your\n profile!",
                          style: GoogleFonts.outfit(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  value: selectedCountry,
                                  onChanged: isPhonePresent
                                      ? null
                                      : (value) {
                                          // Add this condition
                                          setState(() {
                                            selectedCountry = value as String;
                                            // Clear phone number when country changes
                                            phoneController.clear();
                                            _validateForm();
                                          });
                                        },
                                  selectedItemBuilder: (context) {
                                    return countryList.map((country) {
                                      return ClipOval(
                                        child: Text(
                                          country["flag"]!,
                                          style: GoogleFonts.outfit(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black.withOpacity(
                                                isPhonePresent ? 1.0 : 1.0),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items: countryList.map((country) {
                                    return DropdownMenuItem<String>(
                                      value: country["code"],
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            country["flag"]!,
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            // Wrap with Flexible
                                            child: Text(
                                              "${country["name"]} (${country["code"]})",
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                // Increased font size
                                                fontWeight: FontWeight.w800,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Add ellipsis for overflow
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 207,
                                    width: 120,
                                    // Increased width to accommodate larger text
                                    offset: const Offset(-70, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      color: const Color(0xFFF6F6F6),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x24000000),
                                          blurRadius: 18,
                                          offset: Offset(7, 7),
                                        ),
                                      ],
                                    ),
                                    elevation: 0,
                                    scrollbarTheme: ScrollbarThemeData(
                                      thickness: WidgetStateProperty.all(0),
                                      thumbVisibility:
                                          WidgetStateProperty.all(false),
                                    ),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: Colors.black),
                                    iconSize: 24,
                                    iconEnabledColor: Colors.black,
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 40,
                                    selectedMenuItemBuilder: (context, child) =>
                                        Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFEEDD9),
                                      ),
                                      child: child,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Fill your details to continue",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Create your Account",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            enabled: !isNamePresent,
                            style: const TextStyle(color: darkBlack),
                            decoration: InputDecoration(
                              filled: true,
                              hintText: "Name",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
                              ),
                            ),
                            validator: (value) {
                              if (!isNameTouched && !isFormSubmitted)
                                return null;
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required";
                              }
                              if (!RegExp(r"^[A-Za-z]+([ '-.][A-Za-z]+)*$")
                                  .hasMatch(value)) {
                                return "Invalid name format";
                              }
                              return null;
                            },
                            onChanged: (_) => _validateForm(),
                            onTap: () {
                              setState(() {
                                isNameTouched = true;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setStateDropdown) {
                                return GestureDetector(
                                  onTap: () {
                                    setStateDropdown(() {
                                      isDropdownOpen = !isDropdownOpen;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedGender ?? 'Gender',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: _selectedGender != null
                                                    ? Colors.black
                                                    : Colors.grey[500],
                                              ),
                                            ),
                                            Icon(
                                              isDropdownOpen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.grey[600],
                                            ),
                                          ],
                                        ),
                                        if (isDropdownOpen) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: Colors.grey[400]!,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              'Male',
                                              'Female',
                                            ].map((String value) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedGender = value;
                                                  });
                                                  setStateDropdown(() {
                                                    isDropdownOpen = false;
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 8,
                                                  ),
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: dobController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: "Date of birth",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
                              ),
                            ),
                            readOnly: true,
                            // Prevent manual input
                            onTap: () {
                              setState(() {
                                isDobTouched = true;
                              });
                              _selectDate(context);
                            },
                            // Open calendar picker
                            validator: (value) {
                              if (!isDobTouched && !isFormSubmitted)
                                return null;
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: emailController,
                            enabled: !isEmailPresent && !verifyEmail,
                            decoration: InputDecoration(
                              filled: true,
                              suffix: (showSendOtpEmail &&
                                      !isEmailPresent &&
                                      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                          .hasMatch(emailController.text))
                                  ? InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () => _sendOtpEmail(),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "send otp",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    )
                                  : null,
                              fillColor: Colors.grey[200],
                              hintText: "Email",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (!isEmailTouched && !isFormSubmitted)
                                return null;
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                  .hasMatch(value)) {
                                return "Invalid email format";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                showSendOtpEmail = value.isNotEmpty &&
                                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                        .hasMatch(value);
                                isSendOtpPressed = false;
                                verifyOtpController.clear();
                                isVerifyOtpTouched = false;
                                showVerifyOtp = false;
                              });

                              _validateForm();
                            },
                            onTap: () {
                              setState(() {
                                isEmailTouched = true;
                              });
                            },
                          ),
                          if (!showSendOtpEmail &&
                              !isEmailPresent &&
                              isSendOtpPressed &&
                              !verifyEmail) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: verifyOtpController,
                              enabled: true,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                suffix: (showVerifyOtp && !isEmailPresent)
                                    ? InkWell(
                                        onTap: isLoading
                                            ? null
                                            : () => _verifyOtp(),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Verify Otp",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      )
                                    : null,
                                fillColor: Colors.grey[200],
                                hintStyle: TextStyle(
                                    color: Colors.grey[500], fontSize: 16),
                                hintText: "Verify Otp",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.blue),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.red),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (!isVerifyOtpTouched) {
                                  return null;
                                }
                                if (showSendOtpEmail) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return "Otp is required";
                                } else if (value.length != 6) {
                                  return "Enter a valid otp";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  showVerifyOtp =
                                      value.isNotEmpty && value.length == 6;
                                });
                                _validateForm();
                              },
                              onTap: () {
                                setState(() {
                                  isVerifyOtpTouched = true;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: phoneController,
                            enabled: !isPhonePresent && !verifyPhone,
                            maxLength: phoneValidationRules[selectedCountry]
                                    ?['maxLength'] ??
                                10,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              counterText: "",
                              suffix: (showSendOtpPhone &&
                                      !isPhonePresent &&
                                      _isValidPhoneNumber())
                                  ? InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () => _sendOtpPhone(),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          "send otp",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    )
                                  : null,
                              hintText: "Mobile Number",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.transparent),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onTap: () {
                              setState(() {
                                isPhoneTouched = true;
                              });
                            },
                            validator: (value) {
                              if (!isPhoneTouched && !isFormSubmitted)
                                return null;
                              if (value == null || value.trim().isEmpty) {
                                return "Mobile number is required";
                              }

                              // Get validation rules for selected country
                              final validationRule =
                                  phoneValidationRules[selectedCountry];
                              final minLength =
                                  validationRule?['minLength'] ?? 10;
                              final maxLength =
                                  validationRule?['maxLength'] ?? 10;
                              final countryName =
                                  validationRule?['name'] ?? 'selected country';

                              if (value.length < minLength ||
                                  value.length > maxLength) {
                                return "Please enter a valid $countryName phone number";
                              }

                              // Additional validation for specific countries if needed
                              if (selectedCountry == '+91') {
                                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                                  return "Please enter a valid Indian mobile number";
                                }
                              }

                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                phoneValidationRules[selectedCountry]
                                        ?['maxLength'] ??
                                    10,
                              ),
                            ],
                            onChanged: (value) {
                              // Get validation rules for selected country
                              final validationRule =
                                  phoneValidationRules[selectedCountry];
                              final minLength =
                                  validationRule?['minLength'] ?? 10;
                              final maxLength =
                                  validationRule?['maxLength'] ?? 10;

                              setState(() {
                                showSendOtpPhone = value.length >= minLength &&
                                    value.length <= maxLength;
                                showSendOtpPhone = _isValidPhoneNumber();
                                isSendOtpPressed = false;
                                verifyOtpController.clear();
                                isVerifyOtpTouched = false;
                                showVerifyOtp = false;
                              });
                              _validateForm();
                            },
                          ),
                          if (!showSendOtpPhone &&
                              !isPhonePresent &&
                              isSendOtpPressed &&
                              !verifyPhone) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: verifyOtpController,
                              enabled: true,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                suffix: (showVerifyOtp && !isPhonePresent)
                                    ? InkWell(
                                        onTap: isLoading
                                            ? null
                                            : () => _verifyOtp(),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            "Verify Otp",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      )
                                    : null,
                                fillColor: Colors.grey[200],
                                hintStyle: TextStyle(
                                    color: Colors.grey[500], fontSize: 16),
                                hintText: "Verify Otp",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.blue),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 2, color: Colors.red),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (!isVerifyOtpTouched) {
                                  return null;
                                }
                                if (showSendOtpPhone) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return "Otp is required";
                                } else if (value.length != 6) {
                                  return "Enter a valid otp";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  showVerifyOtp =
                                      value.isNotEmpty && value.length == 6;
                                });
                                _validateForm();
                              },
                              onTap: () {
                                setState(() {
                                  isVerifyOtpTouched = true;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Radio(
                                  value: true,
                                  groupValue: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value ?? false;
                                      _validateForm();
                                    });
                                  },
                                  activeColor: const Color(0xFFF8951D),
                                  // Set the selected radio button color
                                  fillColor:
                                      WidgetStateProperty.resolveWith<Color>(
                                          (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return const Color(
                                          0xFFF8951D); // Selected state color
                                    }
                                    return Colors
                                        .grey; // Unselected state color
                                  }),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "I agree with the Terms Condition & Privacy Policy",
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isFormValid ? primaryColor : Colors.grey,
                              ),
                              onPressed: isFormValid && !isLoading
                                  ? () => _submitForm()
                                  : null,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Continue",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          ),
        // Logout button positioned at bottom right
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              constraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 50,
              ),
              icon: const Icon(
                Icons.logout,
                size: 24,
                color: Colors.black87,
              ),
              onPressed: () => _logout(context),
            ),
          ),
        ),
      ],
    );
  }
}
