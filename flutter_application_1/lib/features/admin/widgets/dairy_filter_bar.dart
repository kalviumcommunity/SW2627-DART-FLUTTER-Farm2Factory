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
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCenter,
                    dropdownColor: AppTheme.cardSurface,
                    isDense: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary, size: 18),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
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
                final activeColor = AppTheme.isDark ? AppTheme.brandGreen : const Color(0xFF0F172A);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(opt),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    backgroundColor: AppTheme.cardSurface,
                    selectedColor: activeColor,
                    side: BorderSide(
                      color: isSelected ? activeColor : AppTheme.creamBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
