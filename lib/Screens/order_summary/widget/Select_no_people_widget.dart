import 'package:eatit/common/constants/colors.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectNoPeopleWidget extends StatefulWidget {
  const SelectNoPeopleWidget({super.key});

  @override
  State<SelectNoPeopleWidget> createState() => _SelectPeopleScreenState();
}

class _SelectPeopleScreenState extends State<SelectNoPeopleWidget> {
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

    // Initialize from provider if available
    if (orderProvider.numberOfPeople.isNotEmpty &&
        selectedPeople == 0 &&
        _peopleController.text.isEmpty) {
      int? storedPeople = int.tryParse(orderProvider.numberOfPeople);
      if (storedPeople != null) {
        if (storedPeople >= 1 && storedPeople <= 4) {
          selectedPeople = storedPeople;
        } else {
          _peopleController.text = orderProvider.numberOfPeople;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/select_people.svg',
            ),
            const SizedBox(width: 10),
            const Text(
              "Select People",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
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

                  // Update the order provider with number of people
                  orderProvider.setNumberOfPeople(selectedPeople.toString());
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                      "$people ${people > 1 ? 'People' : 'Person'}",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
        const SizedBox(height: 16),
        const Text(
          "More than four people?",
          style: TextStyle(
              color: fontColor7979, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _peopleController,
          keyboardType: TextInputType.number,
          focusNode: _focusNode,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: Colors.black,
          ),
          onChanged: (value) {
            setState(() {
              int? numPeople = int.tryParse(value);
              if (numPeople == null || numPeople <= 0) {
                errorMessage = "Please enter a valid number!";
                selectedPeople = 0;
                orderProvider.setNumberOfPeople("");
              } else if (numPeople > 20) {
                errorMessage = "Number of people cannot exceed 20!";
                selectedPeople = 0;
                orderProvider.setNumberOfPeople("");
              } else {
                errorMessage = null;
                if (numPeople >= 1 && numPeople <= 4) {
                  selectedPeople = numPeople;
                } else {
                  selectedPeople = 0; // Deselect predefined buttons
                }
                // Update the order provider with number of people
                orderProvider.setNumberOfPeople(value);
              }
            });
          },
          decoration: InputDecoration(
            hintText: "Enter no. of People",
            hintStyle: GoogleFonts.nunitoSans(
              color: fontColor7979,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE8E8EA),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE8E8EA),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE8E8EA),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 16,
            ),
            errorText: errorMessage,
            errorStyle: GoogleFonts.nunitoSans(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
