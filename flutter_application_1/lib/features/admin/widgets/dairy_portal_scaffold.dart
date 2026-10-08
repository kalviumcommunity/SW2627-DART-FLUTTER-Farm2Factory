import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/data/auth_repository.dart';

class DairyPortalScaffold extends StatelessWidget {
  final String activeRoute;
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const DairyPortalScaffold({
    super.key,
    required this.activeRoute,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(title: 'Dashboard', route: AppRoutes.adminDashboard, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
    _NavItem(title: 'Collectors', route: '/dairy/collectors', icon: Icons.badge_outlined, activeIcon: Icons.badge),
    _NavItem(title: 'Dispatch & Logistics', route: '/dairy/dispatch', icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping),
    _NavItem(title: 'Sellers & Farms', route: '/dairy/sellers', icon: Icons.agriculture_outlined, activeIcon: Icons.agriculture),
    _NavItem(title: 'Quality & Lab', route: '/dairy/quality', icon: Icons.science_outlined, activeIcon: Icons.science),
    _NavItem(title: 'Payments & Payouts', route: '/dairy/payments', icon: Icons.payments_outlined, activeIcon: Icons.payments),
    _NavItem(title: 'Reports & Export', route: '/dairy/reports', icon: Icons.assessment_outlined, activeIcon: Icons.assessment),
    _NavItem(title: 'Locations & Fleet', route: '/dairy/locations', icon: Icons.map_outlined, activeIcon: Icons.map),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            // Left Navigation Sidebar
            _buildDesktopSidebar(context),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(context),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet layout
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 20),
            onPressed: () {
              AuthRepository.instance.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildMobileBottomBar(context),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Dairy Plant Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              children: [
                const AppLogo(size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm2Factory',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.brandGreenDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Dairy Operations',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Plant Status Pill
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardMint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.brandGreen.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.factory_outlined, color: AppTheme.brandGreen, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jaipur Central Plant',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandGreenDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children: _navItems.map((item) {
                final isSelected = activeRoute == item.route;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.brandGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 20,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    onTap: () {
                      if (!isSelected) {
                        context.go(item.route);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // User info and logout footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.brandTeal,
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Admin',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Plant Controller',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                  onPressed: () {
                    AuthRepository.instance.logout();
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Row(
            children: [
              ...?actions,
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.brandGreen, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Live Intake: 42,850 L',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brandGreenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const AppLogo(size: 34),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm2Factory',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                      ),
                      Text('Dairy Operations Portal', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: _navItems.map((item) {
                  final isSelected = activeRoute == item.route;
                  return ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: isSelected ? AppTheme.cardMint : null,
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppTheme.brandGreenDark : Colors.grey.shade700,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.brandGreenDark : const Color(0xFF1E293B),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        context.go(item.route);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                AuthRepository.instance.logout();
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    // 4 quick access items on mobile bottom bar
    final quickItems = [
      _navItems[0], // Dashboard
      _navItems[1], // Collectors
      _navItems[2], // Dispatch
      _navItems[5], // Payments
    ];

    int currentIndex = quickItems.indexWhere((it) => it.route == activeRoute);
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.scaffoldBg,
        border: Border(top: BorderSide(color: AppTheme.creamBorder)),
      ),
      child: NavigationBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        selectedIndex: currentIndex,
        height: 60,
        indicatorColor: AppTheme.brandGreen.withOpacity(0.15),
        onDestinationSelected: (idx) {
          final target = quickItems[idx].route;
          if (target != activeRoute) {
            context.go(target);
          }
        },
        destinations: quickItems.map((it) {
          return NavigationDestination(
            icon: Icon(it.icon, size: 20),
            selectedIcon: Icon(it.activeIcon, color: AppTheme.brandGreen, size: 20),
            label: it.title.split(' ').first,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final String route;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.title,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });
}
