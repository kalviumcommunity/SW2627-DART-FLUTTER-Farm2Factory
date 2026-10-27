import 'package:flutter/material.dart';

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
        return const Color(0xFFDCFCE7); // Emerald-100
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return const Color(0xFFE0F2FE); // Sky-100
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return const Color(0xFFFEF3C7); // Amber-100
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return const Color(0xFFFEE2E2); // Rose-100
      default:
        return const Color(0xFFF1F5F9); // Slate-100
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
        return const Color(0xFF166534); // Emerald-800
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return const Color(0xFF0369A1); // Sky-700
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return const Color(0xFFB45309); // Amber-700
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return const Color(0xFF991B1B); // Rose-800
      default:
        return const Color(0xFF475569); // Slate-600
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
        return const Color(0xFF86EFAC);
      case 'collecting':
      case 'en route':
      case 'dispatched':
      case 'processing':
        return const Color(0xFF7DD3FC);
      case 'on duty':
      case 'loading':
      case 'warning':
      case 'grade b':
        return const Color(0xFFFCD34D);
      case 'pending':
      case 'delayed':
      case 'offline':
      case 'inactive':
      case 'high':
      case 'grade c':
      case 'rejected':
        return const Color(0xFFFCA5A5);
      default:
        return const Color(0xFFCBD5E1);
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
