import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Reusable interactive filter bar with date, center, and shift chips.
class DairyFilterBar extends StatelessWidget {
  final String selectedDateFilter;
  final String selectedCenter;
  final String? selectedShift;
  final ValueChanged<String> onDateFilterChanged;
  final ValueChanged<String> onCenterChanged;
  final ValueChanged<String?>? onShiftChanged;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;

  const DairyFilterBar({
    super.key,
    required this.selectedDateFilter,
    required this.selectedCenter,
    this.selectedShift,
    required this.onDateFilterChanged,
    required this.onCenterChanged,
    this.onShiftChanged,
    this.onSearchChanged,
    this.searchHint = 'Search records...',
  });

  static const List<String> dateOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Last Month',
  ];

  static const List<String> centerOptions = [
    'All Centers',
    'Behror Center',
    'Jaipur Center',
    'Ajmer Center',
    'Sikar Center',
    'Tonk Center',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onSearchChanged != null) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.brandGreen, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Horizontally scrollable filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Center Selector Dropdown Chip
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.brandGreen.withValues(alpha: 0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCenter,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.brandGreen, size: 18),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandGreenDark,
                    ),
                    items: centerOptions.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onCenterChanged(val);
                    },
                  ),
                ),
              ),

              // Date Pills
              ...dateOptions.map((opt) {
                final isSelected = selectedDateFilter == opt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(opt),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.brandGreen,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.brandGreen : AppTheme.creamBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => onDateFilterChanged(opt),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
