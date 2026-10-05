import 'package:flutter/material.dart';

/// Full-width button with an optional loading spinner.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // While loading, the button is disabled so it cannot be tapped twice.
    final VoidCallback? action = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: outlined
          ? OutlinedButton(onPressed: action, child: child)
          : FilledButton(onPressed: action, child: child),
    );
  }
}
