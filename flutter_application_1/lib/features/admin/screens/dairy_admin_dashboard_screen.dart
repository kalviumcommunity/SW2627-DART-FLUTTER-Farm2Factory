import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
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
    return DairyPortalScaffold(
      activeRoute: AppRoutes.adminDashboard,
      title: 'Dairy Enterprise Console',
      portalType: DairyPortalType.admin,
      actions: [
        IconButton(
          tooltip: 'Reports & Export',
          icon: const Icon(Icons.assessment_outlined, color: AppTheme.brandGreen),
          onPressed: () => context.push(AppRoutes.adminReports),
        ),
        IconButton(
          tooltip: 'Dispatch Tanker',
          icon: const Icon(Icons.add_road, color: AppTheme.brandTeal),
          onPressed: () => _showDispatchDialog(context),
        ),
      ],
      body: _buildDesktopDashboard(context),
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
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleTab('Owner / CEO', Icons.workspace_premium, DashboardRoleView.owner),
          _roleTab('Logistics', Icons.local_shipping_outlined, DashboardRoleView.logistics),
          _roleTab('Quality (QC)', Icons.science_outlined, DashboardRoleView.quality),
          _roleTab('Accounts', Icons.account_balance_outlined, DashboardRoleView.accounts),
        ],
      ),
    );
  }

  Widget _roleTab(String label, IconData icon, DashboardRoleView role) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (AppTheme.isDark ? AppTheme.brandGreen : const Color(0xFF0F172A))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
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
            iconColor: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Dispatched in Tankers",
            value: "$totalDispatchedLitres L",
            subtitle: "${dispatches.length} active road tankers",
            icon: Icons.local_shipping,
            iconColor: const Color(0xFF0F766E),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Grade A Purity Rate",
            value: "${_analyticsRepo.metric.gradeAPercent}%",
            subtitle: "FAT: 4.25% | SNF: 8.55%",
            icon: Icons.verified,
            iconColor: const Color(0xFF15803D),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _desktopKpiCard(
            title: "Pending Settlement Payout",
            value: "₹ ${(pendingPayout / 100000).toStringAsFixed(2)} Lakh",
            subtitle: "Next 10-day cycle due soon",
            icon: Icons.payments_outlined,
            iconColor: const Color(0xFFB45309),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.creamSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
      {'name': 'Behror Chilling Center', 'litres': 12400, 'target': 14000, 'color': const Color(0xFF15803D)},
      {'name': 'Jaipur Central Hub', 'litres': 14200, 'target': 15000, 'color': const Color(0xFF0284C7)},
      {'name': 'Ajmer Reception Silo', 'litres': 7850, 'target': 9000, 'color': const Color(0xFF7E22CE)},
      {'name': 'Sikar Bulk Unit', 'litres': 5400, 'target': 6000, 'color': const Color(0xFFD97706)},
      {'name': 'Tonk Center', 'litres': 3000, 'target': 5000, 'color': const Color(0xFF0F766E)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.brandGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Center-wise Collection vs Target Capacity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              Text(
                '42,850 L / 49,000 L (87.4% Capacity Utilized)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${c['litres']} L / ${c['target']} L',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
  // SHARED: Operational Alerts
  // =========================================================================
  Widget _buildAlertsSection() {
    final alerts = _analyticsRepo.metric.activeAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alt) {
        final isHigh = alt.severity == 'High';
        final isWarning = alt.severity == 'Warning';
        final bgColor = isHigh
            ? const Color(0xFFFEF2F2)
            : (isWarning ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4));
        final borderColor = isHigh
            ? const Color(0xFFFECACA)
            : (isWarning ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0));
        final textColor = isHigh
            ? const Color(0xFF991B1B)
            : (isWarning ? const Color(0xFF92400E) : const Color(0xFF166534));

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                isHigh ? Icons.warning_rounded : (isWarning ? Icons.info_outline : Icons.check_circle_outline),
                color: textColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alt.title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor)),
                    Text(alt.message, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.9))),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                icon: Icon(Icons.close, size: 15, color: textColor),
                onPressed: () => setState(() => _analyticsRepo.dismissAlert(alt.id)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
