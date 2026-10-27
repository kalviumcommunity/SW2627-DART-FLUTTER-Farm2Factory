import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_card.dart';
import '../widgets/milk_counter_widget.dart';

/// Full page screen representing the primary home dashboard of the Farm2Factory app.
///
/// Demonstrates composition using reusable Stateless Widgets such as [UserCard] and [CustomButton].
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
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active logged-in user summary card
            const Text(
              'Active Supervisor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const UserCard(
              name: 'Shyam Sharma',
              role: 'Field Supervisor',
              email: 'shyam@farm2factory.com',
              phone: '+91 98765 00000',
            ),
            const SizedBox(height: 20),

            // Quick navigation actions
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

            // Interactive Stateful Counter (Lesson 3.12)
            const Text(
              'Interactive Collection Calculator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            const MilkCounterWidget(initialLitres: 15.0),
            const SizedBox(height: 24),

            // Team & Duty Roster demonstrating UserCard reuse with different inputs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'On-Duty Team Roster',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '3 Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Reusable UserCard stateless widgets configured with distinct member data:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),

            // Reusing UserCard instance 1: Dispatcher
            UserCard(
              name: 'Meera',
              role: 'Dispatcher',
              email: 'meera@farm2factory.com',
              phone: '+91 98765 11111',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected Dispatcher: Meera')),
                );
              },
            ),

            // Reusing UserCard instance 2: Delivery Executive
            UserCard(
              name: 'Arjun',
              role: 'Delivery Executive',
              email: 'arjun@farm2factory.com',
              phone: '+91 98765 22222',
              avatarColor: const Color(0xFF0284C7),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected Delivery Executive: Arjun')),
                );
              },
            ),

            // Reusing UserCard instance 3: Admin
            UserCard(
              name: 'Karthik',
              role: 'Admin',
              email: 'karthik@farm2factory.com',
              phone: '+91 98765 33333',
              avatarColor: const Color(0xFFDC2626),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected Admin: Karthik')),
                );
              },
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Stateless UI Pattern: The UserCard layout is declared once in lib/widgets/user_card.dart and reused across screens with different constructor parameters.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.35),
                    ),
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
