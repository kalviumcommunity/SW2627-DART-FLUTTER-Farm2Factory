import 'package:flutter/material.dart';
import 'primary_button.dart';

export 'primary_button.dart';

/// Legacy alias for [PrimaryButton] ensuring backward compatibility.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      outlined: outlined,
      icon: icon,
      color: color,
      fullWidth: true,
    );
  }
}
