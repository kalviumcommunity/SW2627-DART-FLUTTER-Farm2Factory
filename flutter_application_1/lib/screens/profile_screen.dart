import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_card.dart';

/// Full page screen displaying the logged-in user's profile and account settings.
class ProfileScreen extends StatelessWidget {
  final AuthService? authService;

  const ProfileScreen({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    String email = 'operator@farm2factory.com';
    String name = 'Farm Operator';

    try {
      final service = authService ?? AuthService();
      final user = service.getCurrentUser();
      if (user?.email != null) email = user!.email!;
      if (user?.displayName != null) name = user!.displayName!;
    } catch (_) {
      // Safe fallback if Firebase is not initialized in testing environments
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserCard(
              name: name,
              role: 'Operator',
              email: email,
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Return to Home',
              icon: Icons.home_outlined,
              outlined: true,
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Log Out',
              icon: Icons.logout,
              outlined: false,
              onPressed: () async {
                try {
                  final service = authService ?? AuthService();
                  await service.logoutUser();
                } catch (_) {}
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
