import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/collector_repository.dart';
import '../data/dairy_analytics_repository.dart';
import '../data/dairy_payment_repository.dart';
import '../data/dispatch_repository.dart';
import '../models/dispatch_record.dart';
import '../widgets/dairy_filter_bar.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/desktop_dispatch_table.dart';
import '../widgets/intake_dispatch_chart.dart';
import '../widgets/quality_trend_chart.dart';

enum DashboardRoleView { owner, logistics, quality, accounts }

class DairyAdminDashboardScreen extends StatefulWidget {
  const DairyAdminDashboardScreen({super.key});

  @override
  State<DairyAdminDashboardScreen> createState() =>
      _DairyAdminDashboardScreenState();
}

class _DairyAdminDashboardScreenState extends State<DairyAdminDashboardScreen> {
  String _selectedDateFilter = 'Today';
  String _selectedCenter = 'All Centers';
  DashboardRoleView _selectedRole = DashboardRoleView.owner;

  final _analyticsRepo = DairyAnalyticsRepository.instance;
  final _collectorRepo = CollectorRepository.instance;
  final _dispatchRepo = DispatchRepository.instance;
  final _paymentRepo = DairyPaymentRepository.instance;

  void _showDispatchDialog(BuildContext context) {
    final vehicleNoCtrl = TextEditingController(text: 'RJ-14-GA-8890');
    final driverCtrl = TextEditingController(text: 'Sanjay Sharma');
    final phoneCtrl = TextEditingController(text: '9829001122');
    final capacityCtrl = TextEditingController(text: '5000');
    final containersCtrl = TextEditingController(text: '120');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.local_shipping, color: AppTheme.brandTeal),
            SizedBox(width: 8),
            Text('Dispatch Milk Tanker', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleNoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tanker / Vehicle Number',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: driverCtrl,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Driver Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacity (L)',
                        prefixIcon: Icon(Icons.water_drop_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: containersCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Containers',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (vehicleNoCtrl.text.isNotEmpty && driverCtrl.text.isNotEmpty) {
                _dispatchRepo.addDispatch(
                  DispatchRecord(
                    id: 'DSP-${DateTime.now().millisecondsSinceEpoch % 1000}',
                    vehicleNo: vehicleNoCtrl.text.trim(),
                    driverName: driverCtrl.text.trim(),
                    driverPhone: phoneCtrl.text.trim().isEmpty ? '9829001122' : phoneCtrl.text.trim(),
                    capacityLitres: int.tryParse(capacityCtrl.text) ?? 5000,
                    loadedLitres: int.tryParse(capacityCtrl.text) ?? 4800,
                    containersCount: int.tryParse(containersCtrl.text) ?? 120,
                    fromLocation: 'Behror Chilling Center',
                    dispatchedAt: DateTime.now(),
                    expectedArrival: DateTime.now().add(const Duration(hours: 2)),
                    status: 'Dispatched',
                    currentStageIndex: 1,
                    dispatchAmount: 240000.0,
                    lastLocationUpdate: DateTime.now(),
                  ),
                );
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tanker dispatched successfully!'),
                    backgroundColor: AppTheme.brandGreen,
                  ),
                );
              }
            },
            child: const Text('Confirm Dispatch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    return DairyPortalScaffold(
      activeRoute: AppRoutes.adminDashboard,
      title: isDesktop ? 'Dairy Enterprise Console' : 'Operations Dashboard',
      actions: [
        IconButton(
          tooltip: 'Rate Charts & Pricing',
          icon: const Icon(Icons.currency_rupee, color: AppTheme.brandGreen),
          onPressed: () => context.push(AppRoutes.dairyRates),
        ),
        IconButton(
          tooltip: 'Dispatch Tanker',
          icon: const Icon(Icons.add_road, color: AppTheme.brandTeal),
          onPressed: () => _showDispatchDialog(context),
        ),
      ],
      body: isDesktop
          ? _buildDesktopDashboard(context)
          : _buildMobileDashboard(context),
    );
  }

  // =========================================================================
  // 1. DESKTOP ENTERPRISE DASHBOARD (Wide Viewport >= 960px)
  // =========================================================================
  Widget _buildDesktopDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Period Selector Bar
          Row(
            children: [
              Expanded(
                child: DairyFilterBar(
                  selectedDateFilter: _selectedDateFilter,
                  selectedCenter: _selectedCenter,
                  onDateFilterChanged: (d) => setState(() => _selectedDateFilter = d),
                  onCenterChanged: (c) => setState(() => _selectedCenter = c),
                ),
              ),
              const SizedBox(width: 16),
              // Role Segment Switcher Tabs
              _buildRoleSwitcher(),
            ],
          ),
          const SizedBox(height: 20),

          // Desktop Hero Metric Strip
          _buildDesktopHeroStrip(),
          const SizedBox(height: 24),

          // Live Alerts Ticker
          _buildAlertsSection(),
          const SizedBox(height: 24),

          // Charts Row: Milk Intake vs Dispatch + Quality Composition
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: IntakeDispatchChart(period: _selectedDateFilter),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: QualityTrendChart(period: _selectedDateFilter),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Center-wise Procurement Progress Breakdown
          _buildCenterWiseProgressCard(),
          const SizedBox(height: 24),

          // Heavy Daily Tanker Logistics Table
          DesktopDispatchTable(
            onNewDispatch: () => _showDispatchDialog(context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoleSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleTab('Owner / CEO', Icons.workspace_premium, DashboardRoleView.owner),
          _roleTab('Logistics', Icons.local_shipping, DashboardRoleView.logistics),
          _roleTab('Quality (QC)', Icons.science, DashboardRoleView.quality),
          _roleTab('Accounts', Icons.account_balance, DashboardRoleView.accounts),
        ],
      ),
    );
  }

  Widget _roleTab(String label, IconData icon, DashboardRoleView role) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeroStrip() {
    final dispatches = _dispatchRepo.dispatches;
    final totalDispatchedLitres = dispatches.fold(0, (sum, d) => sum + d.loadedLitres);
    final pendingPayout = _paymentRepo.totalPendingPayout;

    return Row(
      children: [
        Expanded(
          child: _desktopKpiCard(
            title: "Total Milk Procurement",
            value: "42,850 L",
            subtitle: "Morning: 23,400 L | Evening: 19,450 L",
            icon: Icons.water_drop,
            iconColor: const Color(0xFF0288D1),
            bgColor: AppTheme.cardSky,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Dispatched in Tankers",
            value: "$totalDispatchedLitres L",
            subtitle: "${dispatches.length} active road tankers",
            icon: Icons.local_shipping,
            iconColor: AppTheme.brandTeal,
            bgColor: AppTheme.cardMint,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Grade A Purity Rate",
            value: "${_analyticsRepo.metric.gradeAPercent}%",
            subtitle: "FAT: 4.25% | SNF: 8.55%",
            icon: Icons.verified,
            iconColor: AppTheme.brandGreen,
            bgColor: AppTheme.cardMint,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Pending Settlement Payout",
            value: "₹ ${(pendingPayout / 100000).toStringAsFixed(2)} Lakh",
            subtitle: "Next 10-day cycle due soon",
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFFE65100),
            bgColor: AppTheme.cardPeach,
          ),
        ),
      ],
    );
  }

  Widget _desktopKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterWiseProgressCard() {
    final centers = [
      {'name': 'Behror Chilling Center', 'litres': 12400, 'target': 14000, 'color': AppTheme.brandGreen},
      {'name': 'Jaipur Central Hub', 'litres': 14200, 'target': 15000, 'color': const Color(0xFF0288D1)},
      {'name': 'Ajmer Reception Silo', 'litres': 7850, 'target': 9000, 'color': const Color(0xFF7B1FA2)},
      {'name': 'Sikar Bulk Unit', 'litres': 5400, 'target': 6000, 'color': const Color(0xFFE65100)},
      {'name': 'Tonk Center', 'litres': 3000, 'target': 5000, 'color': const Color(0xFF558B2F)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppTheme.brandGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Center-wise Collection vs Target Capacity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Text(
                '42,850 L / 49,000 L (87.4% Capacity Utilized)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: centers.map((c) {
              final pct = (c['litres'] as int) / (c['target'] as int);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c['litres']} L / ${c['target']} L',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(c['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. STREAMLINED MOBILE ADMIN DASHBOARD (Viewport < 960px)
  // =========================================================================
  Widget _buildMobileDashboard(BuildContext context) {
    final dispatches = _dispatchRepo.dispatches;
    final collectors = _collectorRepo.collectors;
    final activeCollectors = collectors.where((c) => c.status != 'Offline').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          DairyFilterBar(
            selectedDateFilter: _selectedDateFilter,
            selectedCenter: _selectedCenter,
            onDateFilterChanged: (d) => setState(() => _selectedDateFilter = d),
            onCenterChanged: (c) => setState(() => _selectedCenter = c),
          ),
          const SizedBox(height: 14),

          // Compact Hero Card for Mobile
          _buildCompactMobileHero(),
          const SizedBox(height: 16),

          // Live Alerts
          _buildAlertsSection(),
          const SizedBox(height: 18),

          // Quick 4-KPI Mobile Grid (No overflow, FittedBox hardened)
          const Text(
            "Today's Overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          _buildMobileKpiGrid(activeCollectors, dispatches.length),
          const SizedBox(height: 20),

          // Operations Quick Hub (Replaces heavy tables with clean tap cards)
          const Text(
            "Operations Hub",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          _buildMobileNavTile(
            icon: Icons.local_shipping_outlined,
            iconColor: AppTheme.brandTeal,
            title: 'Tanker Logistics & Dispatch',
            subtitle: '${dispatches.length} tankers scheduled or en route',
            badge: '${dispatches.where((d) => d.status == 'En Route').length} En Route',
            onTap: () => context.push('/dairy/dispatch'),
          ),
          const SizedBox(height: 8),
          _buildMobileNavTile(
            icon: Icons.badge_outlined,
            iconColor: AppTheme.brandGreen,
            title: 'Collectors Network',
            subtitle: '$activeCollectors of ${collectors.length} active collection centers',
            onTap: () => context.push('/dairy/collectors'),
          ),
          const SizedBox(height: 8),
          _buildMobileNavTile(
            icon: Icons.science_outlined,
            iconColor: const Color(0xFF7B1FA2),
            title: 'Milk Quality & Lab Tests',
            subtitle: 'FAT: 4.25% • SNF: 8.55% • 84.5% Grade A',
            onTap: () => context.push('/dairy/quality'),
          ),
          const SizedBox(height: 8),
          _buildMobileNavTile(
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Payments & Settlement',
            subtitle: '10-day payout cycle disbursals',
            badge: 'Pending',
            onTap: () => context.push('/dairy/payments'),
          ),
          const SizedBox(height: 18),

          // Desktop Web Notice Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.computer, color: AppTheme.brandGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Desktop Analytics Console',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'To view monthly/yearly dispatch graphs and download bulk Excel/CSV registers, open this portal on your PC or Desktop browser.',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactMobileHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF269352), Color(0xFF136836)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F8A4C).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Central Dairy Hub Live', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                '$_selectedCenter • $_selectedDateFilter',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '42,850 Litres',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Today\'s Received Milk (AM: 23,400 L | PM: 19,450 L)',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileKpiGrid(int activeCollectors, int dispatchCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _mobileKpiTile(
                title: 'Active Centers',
                value: '$activeCollectors Active',
                icon: Icons.badge_outlined,
                color: AppTheme.brandGreen,
                bgColor: AppTheme.cardMint,
                onTap: () => context.push('/dairy/collectors'),
              ),
              const SizedBox(height: 10),
              _mobileKpiTile(
                title: 'Dispatched Fleet',
                value: '$dispatchCount Tankers',
                icon: Icons.local_shipping_outlined,
                color: AppTheme.brandTeal,
                bgColor: AppTheme.cardSky,
                onTap: () => context.push('/dairy/dispatch'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _mobileKpiTile(
                title: 'Quality Grade A',
                value: '${_analyticsRepo.metric.gradeAPercent}% Purity',
                icon: Icons.science_outlined,
                color: const Color(0xFF7B1FA2),
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => context.push('/dairy/quality'),
              ),
              const SizedBox(height: 10),
              _mobileKpiTile(
                title: 'Pending Payout',
                value: '₹ 14.8 Lakh',
                icon: Icons.payments_outlined,
                color: const Color(0xFFE65100),
                bgColor: AppTheme.cardPeach,
                onTap: () => context.push('/dairy/payments'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileKpiTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.creamBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.creamBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.brandGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SHARED: Operational Alerts
  // =========================================================================
  Widget _buildAlertsSection() {
    final alerts = _analyticsRepo.metric.activeAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alt) {
        final isHigh = alt.severity == 'High';
        final isWarning = alt.severity == 'Warning';
        final bgColor = isHigh ? const Color(0xFFFFEBEE) : (isWarning ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9));
        final textColor = isHigh ? const Color(0xFFC62828) : (isWarning ? const Color(0xFFE65100) : AppTheme.brandGreenDark);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                isHigh ? Icons.warning_rounded : (isWarning ? Icons.info_outline : Icons.check_circle_outline),
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alt.title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                    Text(alt.message, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85))),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: textColor),
                onPressed: () => setState(() => _analyticsRepo.dismissAlert(alt.id)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
