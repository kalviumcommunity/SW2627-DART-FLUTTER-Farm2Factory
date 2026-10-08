import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Standard status pill badge for collector, dispatch, payment, and quality states.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  Color _getBgColor() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'delivered':
      case 'completed':
      case 'grade a':
      case 'operating 24/7':
        return AppTheme.cardMint;
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return AppTheme.cardSky;
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return AppTheme.cardPeach;
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'delivered':
      case 'completed':
      case 'grade a':
      case 'operating 24/7':
        return AppTheme.brandGreenDark;
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return const Color(0xFF0277BD);
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return const Color(0xFFE65100);
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return const Color(0xFFC62828);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _getBgColor();
    final fg = _getTextColor();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
