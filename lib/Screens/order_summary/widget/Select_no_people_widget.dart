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
  late int selectedPeople = 0;
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
    final orderProvider = Provider.of<OrderProvider>(context);
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Calculate dynamic sizes
    final iconSize = screenSize.width * 0.05;
    final fontSize = screenSize.width * 0.035;
    final containerPadding = screenSize.width * 0.025;
    final spacing = screenSize.width * 0.02;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/select_people.svg',
                ),
                SizedBox(width: spacing),
                const Text(
                  "Select People",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: spacing * 2),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                int people = index + 1;

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
                      orderProvider
                          .setNumberOfPeople(selectedPeople.toString());
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: containerPadding,
                      horizontal: containerPadding,
                    ),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          getPersonIcon(people),
                          size: iconSize * 1.2,
                          color: selectedPeople == people
                              ? const Color(0xFF139456)
                              : Colors.black,
                        ),
                        SizedBox(width: spacing),
                        Flexible(
                          child: Text(
                            "$people ${people > 1 ? 'People' : 'Person'}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: fontSize,
                              color: selectedPeople == people
                                  ? const Color(0xFF139456)
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: spacing * 2),
            Text(
              "More than four people?",
              style: TextStyle(
                color: fontColor7979,
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing),
            TextField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              focusNode: _focusNode,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.nunitoSans(
                fontSize: fontSize,
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
                      selectedPeople = 0;
                    }
                    orderProvider.setNumberOfPeople(value);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: "Enter no. of People",
                hintStyle: GoogleFonts.nunitoSans(
                  color: fontColor7979,
                  fontSize: fontSize,
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: containerPadding,
                  horizontal: containerPadding * 1.5,
                ),
                errorText: errorMessage,
                errorStyle: GoogleFonts.nunitoSans(
                  fontSize: fontSize * 0.8,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
