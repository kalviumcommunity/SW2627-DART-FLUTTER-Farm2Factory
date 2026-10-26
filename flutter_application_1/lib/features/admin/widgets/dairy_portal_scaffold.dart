import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/data/auth_repository.dart';

enum DairyPortalType { admin, manager }

class DairyPortalScaffold extends StatelessWidget {
  final String activeRoute;
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final DairyPortalType? portalType;

  const DairyPortalScaffold({
    super.key,
    required this.activeRoute,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.portalType,
  });

  DairyPortalType get _resolvedPortalType {
    if (portalType != null) return portalType!;
    // Auto-detect Admin routes
    if (activeRoute.startsWith('/admin') ||
        activeRoute == AppRoutes.adminDashboard ||
        activeRoute == AppRoutes.adminPayments ||
        activeRoute == AppRoutes.adminReports ||
        activeRoute == AppRoutes.adminLocations ||
        activeRoute == '/dairy/payments' ||
        activeRoute == '/dairy/reports' ||
        activeRoute == '/dairy/locations') {
      return DairyPortalType.admin;
    }
    return DairyPortalType.manager;
  }

  // =========================================================================
  // 1. ADMIN EXECUTIVE NAVIGATION (Strictly 4 Items - Desktop Only)
  // =========================================================================
  static const List<_NavItem> _adminNavItems = [
    _NavItem(
      title: 'Payments & Payouts',
      route: AppRoutes.adminPayments,
      aliases: ['/dairy/payments'],
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
    ),
    _NavItem(
      title: 'Intake & Graphs',
      route: AppRoutes.adminDashboard,
      aliases: ['/admin/dashboard'],
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
    ),
    _NavItem(
      title: 'Reports & Export',
      route: AppRoutes.adminReports,
      aliases: ['/dairy/reports'],
      icon: Icons.assessment_outlined,
      activeIcon: Icons.assessment,
    ),
    _NavItem(
      title: 'Locations & Fleet',
      route: AppRoutes.adminLocations,
      aliases: ['/dairy/locations'],
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
    ),
  ];

  // =========================================================================
  // 2. CENTER MANAGER NAVIGATION (Strictly 6 Items - Mobile & Desktop)
  // =========================================================================
  static const List<_NavItem> _managerNavItems = [
    _NavItem(
      title: 'Center Dashboard',
      route: AppRoutes.managerDashboard,
      aliases: ['/manager/dashboard', '/dairy/center-dashboard'],
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    _NavItem(
      title: 'Dispatch & Logistics',
      route: AppRoutes.managerDispatch,
      aliases: ['/dairy/dispatch'],
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
    ),
    _NavItem(
      title: 'Quality & Lab',
      route: AppRoutes.managerQuality,
      aliases: ['/dairy/quality'],
      icon: Icons.science_outlined,
      activeIcon: Icons.science,
    ),
    _NavItem(
      title: 'Farmers & Sellers',
      route: AppRoutes.managerFarmers,
      aliases: ['/dairy/sellers'],
      icon: Icons.agriculture_outlined,
      activeIcon: Icons.agriculture,
    ),
    _NavItem(
      title: 'Collectors',
      route: AppRoutes.managerCollectors,
      aliases: ['/dairy/collectors'],
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge,
    ),
    _NavItem(
      title: 'Rate Charts & Pricing',
      route: AppRoutes.managerRates,
      aliases: ['/dairy/rates'],
      icon: Icons.currency_rupee_outlined,
      activeIcon: Icons.currency_rupee,
    ),
  ];

  bool _isItemActive(_NavItem item) {
    if (activeRoute == item.route) return true;
    return item.aliases.contains(activeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final type = _resolvedPortalType;

    // 1. Enterprise Admin Console is restricted to Desktop Only
    if (type == DairyPortalType.admin) {
      if (!isDesktop) {
        return _buildAdminMobileRestricted(context);
      }
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            _buildDesktopSidebar(context, type),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(context, type),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Center Manager Portal is accessible on BOTH Desktop & Mobile
    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            _buildDesktopSidebar(context, type),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(context, type),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Manager Mobile Layout
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        titleSpacing: 8,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: screenWidth < 380 ? 15 : 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
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
      drawer: _buildManagerDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildManagerMobileBottomBar(context),
    );
  }

  // =========================================================================
  // ADMIN MOBILE RESTRICTION VIEW
  // =========================================================================
  Widget _buildAdminMobileRestricted(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            AppLogo(size: 28),
            SizedBox(width: 8),
            Text(
              'Enterprise Admin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
            onPressed: () {
              AuthRepository.instance.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.desktop_windows_outlined,
                    size: 32,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DESKTOP ONLY ACCESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Executive Admin Console',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The Enterprise Admin Console (Payments & Payouts, Multi-Center Graphs, Audit Reports & Fleet Telemetry) is designed exclusively for desktop widescreen workstations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                    label: const Text('Open Center Manager Portal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.go(AppRoutes.managerDashboard),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Log In with Another Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      AuthRepository.instance.logout();
                      context.go(AppRoutes.login);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // DESKTOP SIDEBAR (Admin vs Manager) - Executive Midnight Obsidian Slate
  // =========================================================================
  Widget _buildDesktopSidebar(BuildContext context, DairyPortalType type) {
    final isAdmin = type == DairyPortalType.admin;
    final navItems = isAdmin ? _adminNavItems : _managerNavItems;
    final user = AuthRepository.instance.currentUser;
    final plantOrCenter = isAdmin
        ? 'Jaipur Central Plant • All 5 Centers'
        : (user?.center.isNotEmpty == true && !user!.center.contains('(HQ)')
            ? user.center
            : 'Tonk Chilling Center #3');

    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate-900: High-end B2B Executive Obsidian
        border: Border(right: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          // Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                const AppLogo(size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm2Factory',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isAdmin ? 'Enterprise Admin' : 'Center Manager Portal',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8), // Slate-400
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),

          // Plant / Center Status Pill (Dark Glass Style)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAdmin ? Icons.corporate_fare : Icons.storefront,
                    color: const Color(0xFF10B981), // Modern Emerald
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plantOrCenter,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE2E8F0),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Portal Switcher Button (Allows easy toggle between Admin & Manager views)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: InkWell(
              onTap: () {
                if (isAdmin) {
                  context.go(AppRoutes.managerDashboard);
                } else {
                  if (!AuthRepository.instance.isAdmin2FAVerified) {
                    context.go(AppRoutes.admin2FA);
                  } else {
                    context.go(AppRoutes.adminDashboard);
                  }
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.storefront_outlined : Icons.admin_panel_settings_outlined,
                      size: 15,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAdmin ? 'Switch to Center Manager' : 'Switch to Admin Console',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFCBD5E1),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children: navItems.map((item) {
                final isSelected = _isItemActive(item);
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F5132) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF10B981).withOpacity(0.3))
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                      size: 19,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
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

          const Divider(height: 1, color: Color(0xFF1E293B)),

          // User info and 2FA credential status footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isAdmin ? const Color(0xFF0F5132) : const Color(0xFF0284C7),
                        child: Text(
                          isAdmin ? 'A' : 'M',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin ? (user?.name ?? 'Plant Admin') : (user?.name ?? 'Vikram Patel'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isAdmin ? 'Enterprise Admin' : 'Center Manager',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                          tooltip: 'Lock Admin Console (2FA)',
                          icon: const Icon(Icons.lock_outline, size: 16, color: Color(0xFFFB7185)),
                          onPressed: () {
                            AuthRepository.instance.lockAdminSession();
                            context.go(AppRoutes.admin2FA);
                          },
                        ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        tooltip: 'Logout',
                        icon: const Icon(Icons.logout, size: 16, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          AuthRepository.instance.logout();
                          context.go(AppRoutes.login);
                        },
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_android, size: 11, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 5),
                        Text(
                          user?.phone.isNotEmpty == true ? user!.phone : '9999999999',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.alternate_email, size: 11, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            user?.email.isNotEmpty == true ? user!.email : 'admin.controller@farm2factory.in',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B), // Dark Emerald
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, size: 10, color: Color(0xFF34D399)),
                          SizedBox(width: 4),
                          Text(
                            '2FA Authenticated',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF6EE7B7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // DESKTOP TOP BAR (Crisp White & Precision Typography)
  // =========================================================================
  Widget _buildDesktopTopBar(BuildContext context, DairyPortalType type) {
    final isAdmin = type == DairyPortalType.admin;
    final user = AuthRepository.instance.currentUser;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAdmin ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAdmin ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  isAdmin ? 'Enterprise Admin Only' : 'Single Center Manager',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? const Color(0xFF1D4ED8) : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (isAdmin) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        'Admin: ${user?.phone.isNotEmpty == true ? user!.phone : "9999999999"} • ${user?.email.isNotEmpty == true ? user!.email : "admin.controller@farm2factory.in"}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.lock_outline, size: 13, color: Color(0xFFE11D48)),
                  label: const Text('Lock Console', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE11D48),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    AuthRepository.instance.lockAdminSession();
                    context.go(AppRoutes.admin2FA);
                  },
                ),
                const SizedBox(width: 8),
              ],
              ...?actions,
              const SizedBox(width: 12),
              // Live Plant Status Badge with Live Pulsing Dot
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAdmin ? 'Live Plant Intake: 42,850 L' : 'Center Intake: 8,450 L',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
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

  // =========================================================================
  // MANAGER MOBILE DRAWER
  // =========================================================================
  Widget _buildManagerDrawer(BuildContext context) {
    final user = AuthRepository.instance.currentUser;
    final centerName = (user != null && user.center.isNotEmpty && !user.center.contains('(HQ)'))
        ? user.center
        : 'Tonk Chilling Center #3';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farm2Factory',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                        ),
                        Text(
                          centerName,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: _managerNavItems.map((item) {
                  final isSelected = _isItemActive(item);
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

  // =========================================================================
  // MANAGER MOBILE BOTTOM BAR (5 Core Touch Items)
  // =========================================================================
  Widget _buildManagerMobileBottomBar(BuildContext context) {
    final quickItems = [
      _managerNavItems[0], // Center Dashboard
      _managerNavItems[1], // Dispatch
      _managerNavItems[2], // Quality
      _managerNavItems[3], // Farmers
      _managerNavItems[5], // Rate Charts
    ];

    int currentIndex = quickItems.indexWhere((it) => _isItemActive(it));
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
          if (!_isItemActive(quickItems[idx])) {
            context.go(target);
          }
        },
        destinations: quickItems.map((it) {
          final label = it.route == AppRoutes.managerRates
              ? 'Rates'
              : it.title.split(' ').first;
          return NavigationDestination(
            icon: Icon(it.icon, size: 20),
            selectedIcon: Icon(it.activeIcon, color: AppTheme.brandGreen, size: 20),
            label: label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final String route;
  final List<String> aliases;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.title,
    required this.route,
    this.aliases = const [],
    required this.icon,
    required this.activeIcon,
  });
}
