import 'package:eatit/Screens/Filter/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({super.key});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  bool isFilterOpen = false;
  bool _isAnyOptionSelected() {
    return selectedSortOption.isNotEmpty ||
        selectedRatingOption.isNotEmpty ||
        selectedOfferOption.isNotEmpty ||
        selectedPriceOption.isNotEmpty ||
        selectedFilters.values.any((value) => value);
  }

  Map<String, bool> selectedFilters = {
    'Sort': false,
    'Rating 4.0+': false,
    'Pure Veg': false,
    'Under ₹300': false,
    'Offers': false,
  };

  String selectedSection = 'Sort By'; // Default selected section

  String selectedSortOption = '';
  String selectedRatingOption = '';
  String selectedOfferOption = '';
  String selectedPriceOption = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterButton(),
                ...selectedFilters.keys
                    .where((key) => key != 'Sort')
                    .map((filter) => _buildFilterChip(filter))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          _showFilterBottomSheet();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(18),
            color: isFilterOpen
                ? const Color(0xFFF8951D).withOpacity(0.1)
                : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list,
                size: 18,
                color: isFilterOpen ? const Color(0xFFF8951D) : Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                'Filter',
                style: TextStyle(
                  color: isFilterOpen ? Colors.black : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        selectedSection: selectedSection,
        selectedSortOption: selectedSortOption,
        selectedRatingOption: selectedRatingOption,
        selectedOfferOption: selectedOfferOption,
        selectedPriceOption: selectedPriceOption,
        onApplyFilters: (sortOption, ratingOption, offerOption, priceOption) {
          setState(() {
            selectedSortOption = sortOption;
            selectedRatingOption = ratingOption;
            selectedOfferOption = offerOption;
            selectedPriceOption = priceOption;
            isFilterOpen = false;
          });
        },
        onClearFilters: () {
          setState(() {
            selectedSortOption = '';
            selectedRatingOption = '';
            selectedOfferOption = '';
            selectedPriceOption = '';
            selectedFilters.updateAll((key, value) => false);
          });
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E2E2)),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Filter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<String> options,
    String selectedOption,
    Function(String) onOptionSelected,
  ) {
    bool isSelected = selectedSection == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF8951D).withOpacity(0.1)
              : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color:
                          isSelected ? const Color(0xFFF8951D) : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? const Color(0xFFF8951D) : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isSelected)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: options.map((option) {
                      return GestureDetector(
                        onTap: () => onOptionSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                selectedOption == option
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: selectedOption == option
                                    ? const Color(0xFFF8951D)
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedOption == option
                                      ? const Color(0xFFF8951D)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E2E2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedSortOption = '';
                selectedRatingOption = '';
                selectedOfferOption = '';
                selectedPriceOption = '';
                selectedFilters.updateAll((key, value) => false);
              });
              //Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isFilterOpen = false;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8951D),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    // Helper function to get icon and color based on label
    Widget? getLeadingIcon(String label) {
      switch (label) {
        case 'Rating 4.0+':
          return const Icon(
            Icons.star,
            size: 16,
            color: Color(0xFF139456),
          );
        case 'Pure Veg':
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFF36F456),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.circle,
                size: 10,
                color: Color(0xFF36F456),
              ),
            ),
          );
        case 'Non-Veg':
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFFF44336),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.circle,
                size: 12,
                color: Color(0xFFF44336),
              ),
            ),
          );
        case 'Under ₹300':
          return const Icon(
            Icons.currency_rupee,
            size: 16,
            color: Colors.black,
          );
        case 'Offers':
          return const Icon(
            Icons.local_offer,
            size: 16,
            color: Colors.black,
          );
        default:
          return null;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilters[label] = !selectedFilters[label]!;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedFilters[label]!
                  ? const Color(0xFFF8951D)
                  : const Color(0xFFE2E2E2),
            ),
            borderRadius: BorderRadius.circular(18),
            color: selectedFilters[label]!
                ? const Color(0xFFF8951D).withOpacity(0.1)
                : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (getLeadingIcon(label) != null) ...[
                getLeadingIcon(label)!,
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selectedFilters[label]! ? Colors.black : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
