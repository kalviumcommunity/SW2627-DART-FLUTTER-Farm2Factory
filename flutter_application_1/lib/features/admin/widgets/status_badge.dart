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
        return AppTheme.badgeMintBg;
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return AppTheme.badgeSkyBg;
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return AppTheme.badgeAmberBg;
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return AppTheme.badgeRoseBg;
      default:
        return AppTheme.badgeNeutralBg;
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
        return AppTheme.badgeMintText;
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return AppTheme.badgeSkyText;
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return AppTheme.badgeAmberText;
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return AppTheme.badgeRoseText;
      default:
        return AppTheme.badgeNeutralText;
    }
  }

  Color _getBorderColor() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'delivered':
      case 'completed':
      case 'grade a':
      case 'operating 24/7':
        return AppTheme.badgeMintBorder;
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return AppTheme.badgeSkyBorder;
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return AppTheme.badgeAmberBorder;
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return AppTheme.badgeRoseBorder;
      default:
        return AppTheme.badgeNeutralBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _getBgColor();
    final fg = _getTextColor();
    final border = _getBorderColor();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
