import 'package:flutter/material.dart';

/// The Farm2Factory logo (assets/images/logo.png).
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      semanticLabel: 'Farm2Factory logo',
    );
  }
}
