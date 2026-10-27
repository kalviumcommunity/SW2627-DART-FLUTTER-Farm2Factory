import 'package:flutter/material.dart';

/// Reusable, configurable button component extracted to eliminate duplicated UI.
///
/// Encapsulates consistent branding, border radius, elevation, and loading states.
/// Customisable through constructor parameters (color, icon, fullWidth, outlined, isLoading).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool fullWidth;
  final bool outlined;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.fullWidth = true,
    this.outlined = false,
    this.isLoading = false,
    this.icon,
    this.height = 48.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF16A34A);
    final effectiveTextColor = textColor ?? (outlined ? effectiveColor : Colors.white);
    final VoidCallback? action = isLoading ? null : onPressed;

    final childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: effectiveTextColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    final Widget button = outlined
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: effectiveColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: action,
            child: childWidget,
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: effectiveTextColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: action,
            child: childWidget,
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}
