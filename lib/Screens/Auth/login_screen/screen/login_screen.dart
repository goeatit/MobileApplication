import 'package:country_flags/country_flags.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eatit/Screens/Auth/login_screen/service/auth_mobile_otp_service.dart';
import 'package:eatit/Screens/Auth/login_screen/service/google_sign_in.dart';
import 'package:eatit/Screens/Auth/verify_otp/screen/verify_otp.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eatit/Screens/Auth/login_screen/service/facebook_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../../api/api_repository.dart';

class LoginScreeen extends StatefulWidget {
  static const routeName = "/login-screen";

  const LoginScreeen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreeen> {
  String selectedCountryCode = "+91"; // Default country code
  final TextEditingController phoneNumberController = TextEditingController();
  bool isContinueButton = true; // Flag to toggle button text
  bool isLoading = false; // Loading state
  bool isGoogleLoading = false; // Track Google login state
  bool isFacebookLoading = false; // Track Facebook login state
  late GoogleLoginService? _googleLoginService;
  late FacebookSignInService? _facebookSignInService;
  late OtpService? _otpService;

  bool _servicesInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_servicesInitialized) {
      final apiRepository = Provider.of<ApiRepository>(context, listen: false);
      _otpService = OtpService(apiRepository: apiRepository);
      _googleLoginService = GoogleLoginService(apiRepository: apiRepository);
      _facebookSignInService =
          FacebookSignInService(apiRepository: apiRepository);

      _servicesInitialized = true;
    }
  }

  @override
  void dispose() {
    phoneNumberController.dispose(); // Dispose the controller
    _otpService = null; // Cancel any ongoing requests
    _googleLoginService = null; // Cancel Google login request
    _facebookSignInService = null; // Cancel Facebook login request
    _servicesInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> countryCodes = [
      {
        "code": "+91",
        "flag": "🇮🇳",
      },
      {
        "code": "+966",
        "flag": "🇸🇦",
      },
      {
        "code": "+1",
        "flag": "🇺🇸",
      },
      {
        "code": "+44",
        "flag": "🇬🇧",
      },
      {"code": "+971", "flag": "🇦🇪"},
    ];

    Future<void> _handleGoogleLogin(BuildContext context) async {
      setState(() {
        isGoogleLoading = true; // Show loading overlay
      });

      try {
        await _googleLoginService!.loginWithGoogle(context);
      } finally {
        setState(() {
          isGoogleLoading = false; // Hide loading overlay
        });
      }
    }

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(width: 15), // Add some padding from the left edge
            const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF999999),
              size: 15,
            ),
            const SizedBox(width: 5), // 5px gap between icon and text
            Text(
              "Back",
              style: textTheme.labelMedium?.copyWith(
                fontSize: 20,
                color: const Color(0xFF999999),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        leadingWidth: 100, // Adjust this value based on your content width
        backgroundColor: white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Log In",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF1D1929),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Enter your mobile number. We will send a confirmation code to your number.",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1D1929),
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                children: [
                  Container(
                    width: 84,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        // Add this to help with width management
                        value: selectedCountryCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1D1929),
                        ),
                        items: countryCodes
                            .map<DropdownMenuItem<String>>((country) {
                          return DropdownMenuItem<String>(
                            value: country["code"],
                            child: FittedBox(
                              // Wrap with FittedBox to ensure content fits
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    country["flag"]!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  // Minimal spacing
                                  Text(
                                    country["code"]!,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 47,
                          padding: EdgeInsets.zero,
                          width: 84, // Match container width
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          maxHeight: 200,
                          offset: Offset(0, 10),
                          width: 84, // Match container width
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 23,
                          ),
                          iconSize: 16,
                          iconEnabledColor: Color(0xFF1D1929),
                          //iconPadding: EdgeInsets.only(right: 4), // Reduce icon padding
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // 10px gap

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D1929),
                        ),
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Mobile Number',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_checkNumber(phoneNumberController.text) == true) {
                          // Step 2: Send OTP on "Send OTP" click
                          setState(() {
                            isLoading = true;
                          });
                          bool otpSent = await _otpService!.sendOtp(
                            selectedCountryCode,
                            phoneNumberController.text,
                          );
                          setState(() {
                            isLoading = false;
                          });
                          if (otpSent) {
                            Navigator.pushNamed(context, VerifyOtp.routeName,
                                arguments: {
                                  'countryCode': selectedCountryCode,
                                  'phoneNumber': phoneNumberController.text
                                });
                          } else {
                            Fluttertoast.showToast(
                              msg: "Failed to send OTP. Please try again.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFFF8951D),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF8951D)),
                      )
                    : const Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            // login with another way.
            // another way
            const SizedBox(
              height: 120,
            ),
            const Center(
                child: Text(
              "or log in via social networks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D1929),
              ),
            )),
            const SizedBox(height: 10),
            // Drawable Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isGoogleLoading
                    ? null // Disable button while loading
                    : () => _handleGoogleLogin(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFFF8951D), // Button color
                ),
                child: isGoogleLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF8951D)),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/google.png",
                            height: 30,
                            width: 30,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Text(
                              "Login with Google",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Drawable Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isFacebookLoading
                    ? null // Disable button while loading
                    : () async {
                        setState(() {
                          isFacebookLoading = true;
                        });
                        try {
                          await _facebookSignInService!
                              .signInWithFacebook(context);
                        } finally {
                          setState(() {
                            isFacebookLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFFF8951D),
                ),
                child: isFacebookLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFF8951D)),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/facebook.png",
                            height: 30,
                            width: 30,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Text(
                              "Login with Facebook",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  bool? _checkNumber(String _phonenumber) {
    if (_phonenumber.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please Enter the Phone Number",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      return false;
    } else if (_phonenumber.length != 10) {
      Fluttertoast.showToast(
        msg: "Please Enter 10 digit Phone Number",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      return false;
    } else if (!_phonenumber.contains(RegExp(r'^[0-9]+$'))) {
      Fluttertoast.showToast(
        msg: "Phone Number should contain only digits",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      return false;
    } else if (!['9', '7', '8', '6'].contains(_phonenumber[0])) {
      Fluttertoast.showToast(
        msg: "Please Enter a Valid Phone Number",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
  }
}
