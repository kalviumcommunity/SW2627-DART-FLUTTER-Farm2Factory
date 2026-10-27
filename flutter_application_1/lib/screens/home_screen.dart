import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_card.dart';

/// Full page screen representing the primary home dashboard of the Farm2Factory app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        title: const Row(
          children: [
            AppLogo(size: 28),
            SizedBox(width: 10),
            Text(
              'Farm2Factory Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1E293B)),
            onPressed: () => context.go(AppRoutes.farmerDashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User summary card using reusable UserCard widget
            const UserCard(
              name: 'Shyam Sharma',
              role: 'Field Supervisor',
              email: 'shyam@farm2factory.com',
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Milk Collection Entries',
              icon: Icons.water_drop_outlined,
              onPressed: () => context.go(AppRoutes.milkEntries),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Farmers Directory',
              icon: Icons.people_outline,
              outlined: true,
              onPressed: () => context.go(AppRoutes.farmers),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Reports & Export',
              icon: Icons.bar_chart_outlined,
              outlined: true,
              onPressed: () => context.go(AppRoutes.reports),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF16A34A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Clean Architecture Notice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This project is organized into screens/, widgets/, models/, services/, and utils/ for optimal maintainability and clean concern separation.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
