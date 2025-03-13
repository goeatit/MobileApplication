import 'package:eatit/Screens/profile/service/edit_profile_service.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class ProfileInputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final Function(String) onSave;
  final bool isDropdown;
  final bool editIcon;
  final bool isPhone;
  final bool isDatePicker;
  final bool isEmail;
  final Function(bool)? editPressed; // Function returning bool
  final Function(bool)? isLoading;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onSave,
    this.isDropdown = false,
    required this.editIcon,
    this.isPhone = false,
    this.isDatePicker = false,
    this.isEmail = false,
    this.editPressed,
    this.isLoading,
  });

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  late TextEditingController _controller;
  late TextEditingController _otpController;
  bool _isEditing = false;
  bool _showOtp = false;
  bool _isOtpSent = false;
  bool _isVerifying = false;
  String _selectedCountryCode = '+91';
  String _newValue = '';
  String initValue ="";
  EditProfileSerevice editProfileSerevice = EditProfileSerevice();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _otpController = TextEditingController();
    initValue=widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (widget.editIcon) {
      if (_isEditing) {
        FocusScope.of(context).unfocus();
        // User is confirming the edit
        if (_controller.text != widget.value && _controller.text.isNotEmpty) {
          _newValue = _controller.text;
          if (widget.isEmail) {
            widget.isLoading?.call(true);
            _sendOtp();
          } else {
            // For non-email fields, just notify parent of change
            widget.onSave(_controller.text);
            setState(() {
              _isEditing = false;
            });
          }
        } else {
          // No change or empty value, just exit edit mode
          setState(() {
            _isEditing = false;
            _controller.text = widget.value;
          });
        }
      } else {
        // User is starting to edit
        widget.editPressed?.call(true);
        setState(() {
          _isEditing = true;
          _showOtp = false;
          _isOtpSent = false;
        });
      }
    }
  }

  void _sendOtp() async {
    try {
      if (widget.isEmail) {
        widget.isLoading?.call(true);
        bool success =
            await editProfileSerevice.sendEmailOtp(_newValue, context);
        if (success) {
          setState(() {
            _isEditing = false;
            _showOtp = true;
            _isOtpSent = true;
            initValue = _newValue;
            _controller.text = _newValue;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent to your email'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send OTP'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        widget.isLoading?.call(false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.isLoading?.call(false);
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      if (widget.isEmail) {
        bool isVerified = await editProfileSerevice.verifyEmailOtp(
          _newValue,
          context,
          _otpController.text,
        );

        if (isVerified) {
          widget.onSave(_newValue);
          widget.editPressed?.call(false);
          setState(() {
            _showOtp = false;
            _isVerifying = false;
            _controller.text = _newValue;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _isVerifying = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.isDatePicker ? () => widget.onSave('') : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  if (widget.isPhone) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ],
                  Expanded(
                    child: _isEditing && (widget.isPhone || widget.isEmail)
                        ? TextField(
                            controller: _controller,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.0,
                            ),
                          )
                        : Text(
                            _isOtpSent ? _newValue : initValue,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                  ),
                  if ((widget.isPhone || widget.isEmail) && widget.editIcon)
                    GestureDetector(
                      onTap: _toggleEdit,
                      child: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_showOtp && (widget.isPhone || widget.isEmail)) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Enter 6-digit OTP sent to your ${widget.isEmail ? 'email' : 'phone'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: _sendOtp,
                child: const Text('Resend OTP',
                    style: TextStyle(fontSize: 12, color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: primaryColor),
                  ),
                ),
                onCompleted: (pin) => _verifyOtp(),
                enabled: !_isVerifying,
              ),
              if (_isVerifying) ...[
                const SizedBox(height: 8),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
