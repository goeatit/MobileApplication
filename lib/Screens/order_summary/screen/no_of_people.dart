import 'package:eatit/Screens/order_summary/screen/reserve_time.dart';
import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:provider/provider.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _peopleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the OrderProvider
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/svg/graybackArrow.svg',
              width: 30,
              height: 30,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey.shade300,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
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

                      // Function to get appropriate icon based on number of people
                      IconData getPersonIcon(int count) {
                        switch (count) {
                          case 1:
                            return Icons.person_outline;
                          case 2:
                            return Icons.people_outline;
                          case 3:
                            return Icons.groups_3_outlined;
                          case 4:
                            return Icons.group_add_outlined;
                          default:
                            return Icons.person_outline;
                        }
                      }

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
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: selectedPeople == people
                                ? const Color(0xFF139456).withOpacity(0.3)
                                : Colors.white,
                            border: Border.all(
                              color: selectedPeople == people
                                  ? const Color(0xFF139456)
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getPersonIcon(people),
                                size: 20,
                                color: selectedPeople == people
                                    ? const Color(0xFF139456)
                                    : Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                // ignore: deprecated_member_use
                                textScaleFactor: 1.0,
                                "$people ${people > 1 ? 'People' : 'Person'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: selectedPeople == people
                                      ? const Color(0xFF139456)
                                      : Colors.black,
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
                      color: Colors.grey.shade500,
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
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8EA),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
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

                            // Update the order provider with number of people
                            orderProvider.setNumberOfPeople(people);

                            Navigator.pushNamed(
                              context,
                              ReserveTime.routeName,
                            );
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
