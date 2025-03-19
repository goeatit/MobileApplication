import 'dart:async';
import 'package:eatit/Screens/Auth/login_screen/service/auth_mobile_otp_service.dart';
import 'package:eatit/Screens/CompleteYourProfile/Screen/Complete_your_profile_screen.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/order_type_provider.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class VerifyOtp extends StatefulWidget {
  static const routeName = "/otp-screen";

  final String phoneNumber;
  final String countryCode;

  const VerifyOtp(
      {super.key, required this.phoneNumber, required this.countryCode});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final TextEditingController _otpController = TextEditingController();
  final OtpService _otpService = OtpService();
  bool _isButtonEnabled = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  String message = "";
  bool messageColor = false;
  bool _isLoading = false;
  bool? isVerificationSuccess;
  UserResponse? user;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _otpController.addListener(_onOtpChange);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpChange() {
    setState(() {
      _isButtonEnabled = _otpController.text.length == 6;
      if (message.isNotEmpty) {
        message = "";
      }
    });
  }

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    var isVerified = await _otpService.verifyOtp(
        widget.countryCode, widget.phoneNumber, _otpController.text, context);

    setState(() {
      isVerificationSuccess = isVerified;
      messageColor = isVerified;
      message = isVerified ? "Validation Success" : "Validation Failed";
      _isLoading = false;
    });

    if (isVerified) {
      // Add delay to show success state before navigation
      await Future.delayed(const Duration(milliseconds: 1500));

      user = Provider.of<UserModelProvider>(context, listen: false).userModel;
      if (!mounted) return; // Check if widget is still mounted
      Navigator.pop(context);
      if (user?.useremail == null || user?.name == null) {
        Navigator.pushReplacementNamed(context, CreateAccountScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LocationScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Row(
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
          ),
          leadingWidth: 100, // Adjust this value based on your content width
          backgroundColor: white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xFF1D1929),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the 6 digit code that has been sent to your registered number.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1D1929),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Center(
                      child: // Replace the existing Pinput widget with this updated version
                          Pinput(
                    controller: _otpController,
                    length: 6,
                    onCompleted: (value) {
                      _verifyOtp();
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    defaultPinTheme: PinTheme(
                      width: 64,
                      height: 64,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blackBase,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isVerificationSuccess == null
                              ? const Color(
                                  0xFFE5E5E5) // Gray color when no verification attempt
                              : isVerificationSuccess!
                                  ? const Color(
                                      0xFF1BD27A) // Green color for success
                                  : const Color(
                                      0xFFC80A0B), // Red color for failure
                          width: 1,
                        ),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isVerificationSuccess == null
                              ? primaryColor // Default focus color
                              : isVerificationSuccess!
                                  ? const Color(
                                      0xFF1BD27A) // Green color for success
                                  : const Color(
                                      0xFFC80A0B), // Red color for failure
                          width: 2,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blackBase,
                      ),
                    ),
                    errorPinTheme: PinTheme(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFC80A0B),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      // Reset verification status when user starts typing new OTP
                      if (isVerificationSuccess != null) {
                        setState(() {
                          isVerificationSuccess = null;
                          message = "";
                        });
                      }
                    },
                  )),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Row(
                      children: [
                        if (message.isNotEmpty)
                          Icon(
                            messageColor
                                ? CupertinoIcons.checkmark_shield
                                : CupertinoIcons.xmark_shield,
                            color: messageColor ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: messageColor ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  Center(
                    child: SizedBox(
                      height: 53,
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isButtonEnabled ? primaryColor : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        if (_secondsRemaining > 0)
                          Text(
                            "We can send it again in $_secondsRemaining seconds",
                            style: const TextStyle(color: Colors.black),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(
                                    0xFFE5E5E5), // Neutrals200 color
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 15),
                                child: Text(
                                  "Resent OTP",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1D1929),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(), // Circular bar
                ),
              )
          ],
        ));
  }
}
