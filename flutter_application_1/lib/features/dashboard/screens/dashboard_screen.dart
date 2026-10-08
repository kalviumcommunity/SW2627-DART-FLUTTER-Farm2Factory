import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/data/auth_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthRepository.instance.currentUser?.name ?? 'Admin';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        title: const Row(
          children: [
            AppLogo(size: 30),
            SizedBox(width: 10),
            Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthRepository.instance.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $name',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _DashboardTile(
                    icon: Icons.people,
                    label: 'Farmers',
                    color: AppTheme.cardMint,
                    iconColor: AppTheme.brandGreen,
                    onTap: () => context.push(AppRoutes.farmers),
                  ),
                  _DashboardTile(
                    icon: Icons.opacity,
                    label: 'Milk Entries',
                    color: AppTheme.cardSky,
                    iconColor: const Color(0xFF0288D1),
                    onTap: () => _comingSoon(context),
                  ),
                  _DashboardTile(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    color: AppTheme.cardLavender,
                    iconColor: const Color(0xFF7B1FA2),
                    onTap: () => _comingSoon(context),
                  ),
                  _DashboardTile(
                    icon: Icons.payments,
                    label: 'Payments',
                    color: AppTheme.cardPeach,
                    iconColor: const Color(0xFFE65100),
                    onTap: () => _comingSoon(context),
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

/// Private to this file: only the dashboard uses it.
class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}
