import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectPeopleScreen extends StatefulWidget {
  static const routeName = '/select-no-of-people';
  const SelectPeopleScreen({super.key});

  @override
  State<SelectPeopleScreen> createState() => _SelectPeopleScreenState();
}

class _SelectPeopleScreenState extends State<SelectPeopleScreen> {
  late int selectedPeople = 0; // Default selected option
  final TextEditingController _peopleController = TextEditingController();
  String? errorMessage;
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _peopleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back navigation
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.3, // Update this value to represent the current progress
              backgroundColor: Colors.grey.shade300,
              color: Colors.black,
              minHeight: 4,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Select People",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(4, (index) {
                      int people = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPeople = people;
                            _peopleController.clear();
                            errorMessage = null;
                            _focusNode.unfocus();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: selectedPeople == people
                                ? Colors.green.shade100
                                : Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                "$people ${people > 1 ? 'People' : 'Person'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  const Spacer(),
                  Text(
                    "More than five people?",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _peopleController,
                    keyboardType: TextInputType.number,
                    focusNode: _focusNode,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        int? numPeople = int.tryParse(value);
                        if (numPeople == null || numPeople <= 0) {
                          errorMessage = "Please enter a valid number!";
                          selectedPeople = 0;
                        } else if (numPeople > 20) {
                          errorMessage = "Number of people cannot exceed 20!";
                          selectedPeople = 0;
                        } else {
                          errorMessage = null;
                          if (numPeople >= 1 && numPeople <= 4) {
                            selectedPeople = numPeople;
                          } else {
                            selectedPeople = 0; // Deselect predefined buttons
                          }
                        }
                      });
                    },
                    decoration: InputDecoration(
                        hintText: "Enter no. of People",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        errorText: errorMessage),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: (errorMessage == null &&
                            (selectedPeople > 0 ||
                                _peopleController.text.isNotEmpty))
                        ? () {
                            // Handle reserve action
                            final people = _peopleController.text.isNotEmpty
                                ? _peopleController.text
                                : selectedPeople.toString();
                            Navigator.pushNamed(context, ReserveTime.routeName);
                            // print("Reserved for $people people");
                          }
                        : null,
                    child: const Text(
                      "Reserve Time",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
