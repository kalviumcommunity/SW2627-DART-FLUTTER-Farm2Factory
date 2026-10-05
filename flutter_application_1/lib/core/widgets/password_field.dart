import 'package:flutter/material.dart';

import 'custom_text_field.dart';

/// Password box with a show / hide (eye) button.
class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.validator,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      prefixIcon: Icons.lock_outline,
      obscureText: _hidden,
      validator: widget.validator,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}
