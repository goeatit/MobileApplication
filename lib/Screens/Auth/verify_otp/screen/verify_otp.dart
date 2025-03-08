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
      _isButtonEnabled = _otpController.text.length == 4;
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
    user = Provider.of<UserModelProvider>(context, listen: false).userModel;
    if (isVerified) {
      if(user?.useremail==null||user?.name==null){
        Navigator.pushReplacementNamed(context, CreateAccountScreen.routeName);
      }else {
        Navigator.pushReplacementNamed(context, LocationScreen.routeName);
      }
    } else {
      setState(() {
        messageColor = false;
        message = "Invalid OTP. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Back",
            style:
                textTheme.labelMedium?.copyWith(fontSize: 20, color: blackBase),
          ),
          centerTitle: false,
          leading: const Icon(Icons.arrow_back_ios_new, color: blackBase),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the 4 digit code that has been sent to your registered number.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      length: 4,
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
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor),
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
                          border: Border.all(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: messageColor ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isButtonEnabled ? primaryColor : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Continue"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (_secondsRemaining == 0) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        _secondsRemaining > 0
                            ? "We can send it again in $_secondsRemaining seconds"
                            : "Resend Code",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
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
