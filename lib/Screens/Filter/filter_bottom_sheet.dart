// lib/Screens/Filter/filter_bottom_sheet.dart

import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedSection;
  final String selectedSortOption;
  final String selectedRatingOption;
  final String selectedOfferOption;
  final String selectedPriceOption;
  final Function(String, String, String, String) onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterBottomSheet({
    super.key,
    required this.selectedSection,
    required this.selectedSortOption,
    required this.selectedRatingOption,
    required this.selectedOfferOption,
    required this.selectedPriceOption,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedSection;
  late String selectedSortOption;
  late String selectedRatingOption;
  late String selectedOfferOption;
  late String selectedPriceOption;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.selectedSection;
    selectedSortOption = widget.selectedSortOption;
    selectedRatingOption = widget.selectedRatingOption;
    selectedOfferOption = widget.selectedOfferOption;
    selectedPriceOption = widget.selectedPriceOption;
  }

  bool _isAnyOptionSelected() {
    return selectedSortOption.isNotEmpty ||
        selectedRatingOption.isNotEmpty ||
        selectedOfferOption.isNotEmpty ||
        selectedPriceOption.isNotEmpty;
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    bool isSelected = selectedSection == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = title;
        });
      },
      child: Container(
        color: isSelected ? const Color(0xFFFFF6EC) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF8951D) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFFF8951D) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionList() {
    List<String> options = [];
    String selectedOption = '';

    switch (selectedSection) {
      case 'Sort By':
        options = [
          'Price - low to high',
          'Price - high to low',
          'Rating - high to low',
          'Rating - low to high'
        ];
        selectedOption = selectedSortOption;
        break;
      case 'Rating':
        options = ['Rating 4.5+', 'Rating 4.0+', 'Rating 3.5+', 'Rating 3.0+'];
        selectedOption = selectedRatingOption;
        break;
      case 'Offers':
        options = ['Buy 1 Get 1 Free', 'Combo Offer'];
        selectedOption = selectedOfferOption;
        break;
      case 'Veg / Non-Veg':
        options = ['Pure Veg', 'Non-Veg'];
        selectedOption = selectedOfferOption;
        break;
      case 'Price':
        options = ['Less than ₹150', '₹150 - ₹300', 'More than ₹300'];
        selectedOption = selectedPriceOption;
        break;
    }

    return ListView(
      children: options.map((option) {
        return GestureDetector(
          onTap: () {
            setState(() {
              switch (selectedSection) {
                case 'Sort By':
                  selectedSortOption = option;
                  break;
                case 'Rating':
                  selectedRatingOption = option;
                  break;
                case 'Veg / Non-Veg':
                  selectedOfferOption = option;
                  break;
                case 'Offers':
                  selectedOfferOption = option;
                  break;
                case 'Price':
                  selectedPriceOption = option;
                  break;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  selectedOption == option
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selectedOption == option
                      ? const Color(0xFFF8951D)
                      : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    color: selectedOption == option
                        ? const Color(0xFFF8951D)
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          // Body
          Expanded(
            child: Row(
              children: [
                // Left Category List
                Container(
                  width: 110,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E2E2)),
                    ),
                  ),
                  child: ListView(
                    children: [
                      _buildCategoryItem('Sort By', Icons.sort),
                      _buildCategoryItem('Rating', Icons.star),
                      _buildCategoryItem('Veg / Non-Veg', Icons.restaurant),
                      _buildCategoryItem('Offers', Icons.local_offer),
                      _buildCategoryItem('Price', Icons.currency_rupee),
                    ],
                  ),
                ),
                // Right Options List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: _buildOptionList(),
                  ),
                )
              ],
            ),
          ),
          // Bottom buttons
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _isAnyOptionSelected()
                      ? () {
                          widget.onClearFilters();
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color:
                          _isAnyOptionSelected() ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isAnyOptionSelected()
                      ? () {
                          widget.onApplyFilters(
                            selectedSortOption,
                            selectedRatingOption,
                            selectedOfferOption,
                            selectedPriceOption,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8951D),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 90, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
