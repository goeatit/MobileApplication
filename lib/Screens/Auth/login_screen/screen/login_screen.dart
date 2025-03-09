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


  @override
  Widget build(BuildContext context) {
    final GoogleLoginService _googleLoginService = GoogleLoginService();
    final FacebookSignInService _facebookSignInService =
        FacebookSignInService();
    final OtpService _otpService = OtpService();
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
        await _googleLoginService.loginWithGoogle(context);
      } finally {
        setState(() {
          isGoogleLoading = false; // Hide loading overlay
        });
      }
    }

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Back",
          style:
              textTheme.labelMedium?.copyWith(fontSize: 20, color: blackBase),
        ),
        centerTitle: false,
        leading: const Icon(
          Icons.arrow_back_ios_new,
          color: blackBase,
        ),
        backgroundColor: white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Log In",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter your mobile number. We will send a\nconfirmation code to your number.",
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 100, // Fixed width for dropdown
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        value: selectedCountryCode,
                        items: countryCodes
                            .map<DropdownMenuItem<String>>((country) {
                          return DropdownMenuItem<String>(
                            value: country["code"],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(country["flag"]!),
                                const SizedBox(width: 4),
                                Text(country["code"]!),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 6),
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          maxHeight: 200,
                          offset: Offset(0, 10),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // 10px gap

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
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Mobile Number',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
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
              width: 250,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_checkNumber(phoneNumberController.text) == true) {
                          // Step 2: Send OTP on "Send OTP" click
                          setState(() {
                            isLoading = true;
                          });
                          bool otpSent = await _otpService.sendOtp(
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
                  backgroundColor: primaryColor,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      )
                    : const Text(
                        "Send OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
              "Or login with via social networks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 10),
            // Drawable Button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: isGoogleLoading
                    ? null // Disable button while loading
                    : () => _handleGoogleLogin(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: primaryColor, // Button color
                ),
                child: isGoogleLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(primaryColor),
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
                            padding: EdgeInsets.only(left: 13),
                            child: Text(
                              "Login with Google",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
              width: 250,
              child: ElevatedButton(
                onPressed: () async {
                  await _facebookSignInService.signInWithFacebook(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: primaryColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/facebook.png",
                      height: 30,
                      width: 33,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: Text(
                        "Login with Facebook",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
