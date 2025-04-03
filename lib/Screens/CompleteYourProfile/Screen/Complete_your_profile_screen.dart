import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eatit/Screens/CompleteYourProfile/Service/Complete_your_profile_service.dart';
import 'package:eatit/Screens/location/screen/location_screen.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/models/user_model.dart';
import 'package:eatit/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController verifyOtpController = TextEditingController();
  final ValueNotifier<bool> isCheckedNotifier = ValueNotifier<bool>(false);
  final CompleteYourProfileService completeYourProfileService =
      CompleteYourProfileService();

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

  UserResponse? _userModel;

  final List<Map<String, String>> countryList = [
    {"flag": "🇮🇳", "name": "India", "code": "+91"},
    {"flag": "🇺🇸", "name": "USA", "code": "+1"},
    {"flag": "🇬🇧", "name": "UK", "code": "+44"},
    {"flag": "🇦🇺", "name": "Australia", "code": "+61"},
    {
      "flag": "🇸🇦",
      "name": "Saudi Arabia",
      "code": "+966"
    }, // Added Saudi Arabia
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2000), // Default selected date
        firstDate: DateTime(1900), // Earliest date selectable
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
    var res = await completeYourProfileService.sendEmailOtp(
        emailController.text, context);
    if (res) {
      setState(() {
        showSendOtpEmail = false;
        isSendOtpPressed = true;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Verify OTP: ${res}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void _sendOtpPhone() {
    FocusScope.of(context).unfocus();
    print("mobile");
    setState(() {
      showSendOtpPhone = false;
      isSendOtpPressed = true;
    });
  }

  void _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (isPhonePresent) {
      // email verify
      var res = await completeYourProfileService.verifyEmailOtp(
          emailController.text, context, verifyOtpController.text);
      if (res) {
        setState(() {
          verifyEmail = true;
        });
      }
    }
    if (isEmailPresent) {
      //phone verify
      verifyPhone = true;
    }
  }

  @override
  void dispose() {
    isCheckedNotifier.dispose();
    super.dispose();
  }

  void _submitForm() async {
    try {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState!.validate()) {
        // ✅ Form is valid, proceed with the action
        print("Form submitted successfully!");

        var res = await completeYourProfileService.completeYourProfile(
            nameController.text,
            emailController.text,
            dobController.text == "" ? null : dobController.text,
            _selectedGender,
            selectedCountry!,
            phoneController.text);
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
    return Scaffold(
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
                    const Text(
                      "Complete your\n profile!",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 125,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          // isExpanded: true,
                          value: selectedCountry,
                          onChanged: (value) {
                            setState(() {
                              selectedCountry = value as String;
                              _validateForm();
                            });
                          },
                          items: countryList.map((country) {
                            return DropdownMenuItem<String>(
                              value: country["code"],
                              child: Row(
                                children: [
                                  Text(
                                    country["flag"]!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text("${country['code']}"),
                                ],
                              ),
                            );
                          }).toList(),
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 250,
                            width: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            elevation: 2,
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor:
                                  WidgetStateProperty.all(Colors.grey.shade400),
                            ),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            iconSize: 24,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Fill your details to continue"),
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
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
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
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
                            borderSide:
                                const BorderSide(width: 2, color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.red),
                          ),
                        ),
                        validator: (value) {
                          if (!isNameTouched && !isFormSubmitted) return null;
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
                            bool isDropdownOpen = false;
                            return DropdownButtonFormField<String>(
                              value: _selectedGender,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Gender',
                                        style:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                      Icon(
                                        isDropdownOpen
                                            // ignore: dead_code
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up,
                                      ),
                                    ],
                                  ),
                                ),
                                ...['Male', 'Female'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              onTap: () {
                                setStateDropdown(() {
                                  isDropdownOpen = !isDropdownOpen;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Gender",
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: false,
                              ),
                              dropdownColor: Colors.grey[200],
                              menuMaxHeight: 300,
                              borderRadius: BorderRadius.circular(30),
                              icon: const SizedBox
                                  .shrink(), // Hide the default dropdown icon
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              validator: (value) {
                                return null;
                              },
                              isDense: true,
                              isExpanded: true,
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
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          hintText: "Date of birth",
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
                            borderSide:
                                const BorderSide(width: 2, color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.red),
                          ),
                        ),
                        readOnly: true, // Prevent manual input
                        onTap: () {
                          setState(() {
                            isDobTouched = true;
                          });
                          _selectDate(context);
                        }, // Open calendar picker
                        validator: (value) {
                          if (!isDobTouched && !isFormSubmitted) return null;
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        enabled: !isEmailPresent && !verifyEmail,
                        decoration: InputDecoration(
                          filled: true,
                          suffix: (showSendOtpEmail && !isEmailPresent)
                              ? InkWell(
                                  onTap: () => _sendOtpEmail(),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      "send otp",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              : null,
                          fillColor: Colors.grey[200],
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          hintText: "Email",
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
                            borderSide:
                                const BorderSide(width: 2, color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (!isEmailTouched && !isFormSubmitted) return null;
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
                                    onTap: () => _verifyOtp(),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        "Verify Otp",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  )
                                : null,
                            fillColor: Colors.grey[200],
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
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
                              borderSide:
                                  const BorderSide(width: 2, color: Colors.red),
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          suffix: (showSendOtpPhone && !isPhonePresent)
                              ? InkWell(
                                  onTap: () => _sendOtpPhone(),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      "send otp",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              : null,
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          hintText: "Mobile number",
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
                            borderSide:
                                const BorderSide(width: 2, color: Colors.blue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(width: 2, color: Colors.red),
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
                          if (!isPhoneTouched && !isFormSubmitted) return null;
                          if (value == null || value.trim().isEmpty) {
                            return "Mobile number is required";
                          } else if (value.length != 10) {
                            return "Enter a valid mobile number";
                          }
                          return null; // ✅ No error
                        },
                        onChanged: (value) {
                          setState(() {
                            showSendOtpPhone =
                                value.isNotEmpty && value.length == 10;
                            isSendOtpPressed = false;
                            verifyOtpController.clear();
                            isVerifyOtpTouched = false;
                            showVerifyOtp = false;
                          });
                          _validateForm();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                                    onTap: () => _verifyOtp(),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        "Verify Otp",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  )
                                : null,
                            fillColor: Colors.grey[200],
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
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
                              borderSide:
                                  const BorderSide(width: 2, color: Colors.red),
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
                          Radio(
                            value: true,
                            groupValue: isChecked,
                            onChanged: (value) {
                              setState(() => isChecked = value as bool);
                              _validateForm();
                            },
                          ),
                          const Expanded(
                              child: Text(
                                  "I agree with the Terms Condition & Privacy Policy")),
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
                          onPressed: isFormValid ? () => _submitForm() : null,
                          child: const Text("Continue",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
