import 'package:eatit/Screens/order_summary/screen/order_summary.dart';
import 'package:eatit/provider/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eatit/common/constants/colors.dart'; // Assuming primaryColor is defined here
import 'package:provider/provider.dart';

class SelectTableBottomSheet extends StatefulWidget {
  const SelectTableBottomSheet({super.key});

  @override
  State<SelectTableBottomSheet> createState() => SelectTableBottomSheetState();
}

class SelectTableBottomSheetState extends State<SelectTableBottomSheet> {
  String _selectedFloor = 'Ground Floor';
  int _selectedPeople = 0;

  // Make this method public so it can be called from outside
  void updateTableAvailability() {
    setState(() {
      for (var table in _tables) {
        if (_selectedPeople <= 0) {
          // If no people selected, all tables are available
          table['status'] = 'available';
        } else if (_selectedPeople > 6) {
          // If more than 6 people, only show tables with 6 sheets
          table['status'] =
              table['sheets'] >= 6 ? 'available' : 'not_available';
        } else {
          // Show tables that can accommodate the selected number of people
          table['status'] = table['sheets'] >= _selectedPeople
              ? 'available'
              : 'not_available';
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Get the number of people from OrderProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.numberOfPeople != null &&
          orderProvider.numberOfPeople!.isNotEmpty) {
        setState(() {
          _selectedPeople = int.parse(orderProvider.numberOfPeople!);
          updateTableAvailability();
        });
      }
    });
  }

  // Dummy data for tables
  final List<Map<String, dynamic>> _tables = [
    {'id': 'A', 'status': 'available', 'isBestSeller': false, 'sheets': 6},
    {'id': 'B', 'status': 'available', 'isBestSeller': false, 'sheets': 6},
    {'id': 'C', 'status': 'available', 'isBestSeller': false, 'sheets': 6},
    {'id': 'D', 'status': 'available', 'isBestSeller': true, 'sheets': 6},
    {'id': 'E', 'status': 'available', 'isBestSeller': false, 'sheets': 2},
    {'id': 'F', 'status': 'available', 'isBestSeller': false, 'sheets': 2},
    {'id': 'G', 'status': 'available', 'isBestSeller': false, 'sheets': 2},
    {'id': 'H', 'status': 'available', 'isBestSeller': true, 'sheets': 2},
    {'id': 'I', 'status': 'available', 'isBestSeller': false, 'sheets': 4},
    {'id': 'J', 'status': 'available', 'isBestSeller': false, 'sheets': 4},
    {'id': 'K', 'status': 'available', 'isBestSeller': false, 'sheets': 4},
    {'id': 'L', 'status': 'available', 'isBestSeller': false, 'sheets': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // 90% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/graybackArrow.svg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: 0.4,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Table',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1C),
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Floor Selection Tabs - Left aligned with 5px gap
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildFloorTab('Ground Floor'),
                const SizedBox(width: 5),
                _buildFloorTab('First Floor'),
                const SizedBox(width: 5),
                _buildFloorTab('Rooftop'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Table Layout
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFD4D4D4)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          _buildTableRow(_tables.sublist(0, 4),
                              isFirstRow: true),
                          const SizedBox(height: 12),
                          _buildTableRow(_tables.sublist(4, 8),
                              isFirstRow: false),
                          const SizedBox(height: 12),
                          _buildTableRow(_tables.sublist(8, 12),
                              isFirstRow: false),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legend - All in one row
                  _buildLegend(),
                ],
              ),
            ),
          ),

          // Continue Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Close the bottom sheet
                  Navigator.pop(context);
                  // Navigate to OrderSummaryScreen
                  Navigator.pushNamed(context, OrderSummaryScreen.routeName);
                },
                child: Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorTab(String floorName) {
    final isSelected = _selectedFloor == floorName;
    final textColor = isSelected ? Colors.white : const Color(0xFF1D1929);
    final borderColor = const Color(0xFF1D1929);
    final backgroundColor = isSelected ? const Color(0xFF1D1929) : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFloor = floorName;
        });
      },
      child: Container(
        width: 107,
        height: 33,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          floorName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _buildTable(Map<String, dynamic> table, {bool isFirstRow = false}) {
    Color borderColor;
    Color backgroundColor = const Color(0xFFD9D9D9);
    Color textColor = const Color(0xFF838383);

    // Set border color based on status
    switch (table['status']) {
      case 'available':
        borderColor = const Color(0xFF1BD27A);
        break;
      case 'selected':
        borderColor = const Color(0xFF1BD27A);
        break;
      case 'sold':
        borderColor = const Color(0xFFE5E5E5);
        break;
      case 'not_available':
        borderColor = const Color(0xFFF5F5F5);
        break;
      default:
        borderColor = const Color(0xFFF5F5F5);
    }

    // Override border color for best seller
    if (table['isBestSeller']) {
      borderColor = const Color(0xFF9F6BFF);
    }

    // Container height based on row
    final containerHeight = isFirstRow ? 65.0 : 40.0;

    return GestureDetector(
      onTap: () {
        if (table['status'] == 'available') {
          setState(() {
            // Reset all tables to available
            for (var t in _tables) {
              if (t['status'] == 'selected') {
                t['status'] = 'available';
              }
            }
            // Set selected table
            table['status'] = 'selected';
          });
        }
      },
      child: Column(
        children: [
          if (isFirstRow) ...[
            // First row (A-D) with indicators
            _buildNumberIndicator(1, table['status'], table['sheets']), // Top
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildNumberIndicator(
                        2, table['status'], table['sheets']), // Left top
                    const SizedBox(height: 5),
                    _buildNumberIndicator(
                        3, table['status'], table['sheets']), // Left bottom
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    table['id'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _buildNumberIndicator(
                        6, table['status'], table['sheets']), // Right middle
                    const SizedBox(height: 5),
                    _buildNumberIndicator(
                        5, table['status'], table['sheets']), // Right bottom
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            _buildNumberIndicator(
                4, table['status'], table['sheets']), // Bottom indicator
          ] else if (_tables.indexOf(table) < 8) ...[
            // Second row (E-H) with spacing to match other rows
            _buildNumberIndicator(1, table['status'], table['sheets']), // Top
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 28),
                Container(
                  width: 50,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    table['id'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                SizedBox(width: 28),
              ],
            ),
            const SizedBox(height: 5),
            _buildNumberIndicator(
                2, table['status'], table['sheets']), // Bottom
          ] else ...[
            // Last row (I-L) with indicators
            _buildNumberIndicator(1, table['status'], table['sheets']), // Top
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberIndicator(
                    2, table['status'], table['sheets']), // Left
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    table['id'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildNumberIndicator(
                    4, table['status'], table['sheets']), // Right
              ],
            ),
            const SizedBox(height: 4),
            _buildNumberIndicator(
                3, table['status'], table['sheets']), // Bottom
          ],
        ],
      ),
    );
  }

  Widget _buildTableRow(List<Map<String, dynamic>> tables,
      {bool isFirstRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: tables.asMap().entries.map((entry) {
        final table = entry.value;
        final isLast = entry.key == tables.length - 1;
        return Row(
          children: [
            _buildTable(table, isFirstRow: isFirstRow),
            if (!isLast) const SizedBox(width: 10), // 10px gap between columns
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
                'Best Seller', const Color(0xFF9F6BFF), Colors.white),
            const SizedBox(width: 16),
            _buildLegendItem(
                'Available', const Color(0xFF1BD27A), Colors.white),
            const SizedBox(width: 16),
            _buildLegendItem(
                'Selected', const Color(0xFF1BD27A), const Color(0xFF1BD27A),
                textColor: Colors.white),
            const SizedBox(width: 16),
            _buildLegendItem(
                'Sold', const Color(0xFFE5E5E5), const Color(0xFFE5E5E5),
                textColor: Colors.white),
            const SizedBox(width: 16),
            _buildLegendItem(
                'Not Available', const Color(0xFFF5F5F5), Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color borderColor, Color bgColor,
      {Color textColor = Colors.black}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF838383),
              ),
        ),
      ],
    );
  }

  Widget _buildNumberIndicator(int number, String status, int sheets) {
    // Set color based on status for number indicators
    Color bgColor;
    Color borderColor;
    Color textColor = const Color(0xFF838383);

    // Only show indicators up to the number of sheets
    if (number > sheets) {
      return const SizedBox(width: 20, height: 20);
    }

    switch (status) {
      case 'available':
        bgColor = Colors.white;
        borderColor = const Color(0xFF1BD27A);
        break;
      case 'selected':
        bgColor = const Color(0xFF1BD27A);
        borderColor = const Color(0xFF1BD27A);
        textColor = Colors.white;
        break;
      case 'sold':
        bgColor = const Color(0xFFE5E5E5);
        borderColor = const Color(0xFFE5E5E5);
        textColor = Colors.white;
        break;
      case 'not_available':
        bgColor = Colors.white;
        borderColor = const Color(0xFFF5F5F5);
        break;
      default:
        bgColor = Colors.white;
        borderColor = const Color(0xFFF5F5F5);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
