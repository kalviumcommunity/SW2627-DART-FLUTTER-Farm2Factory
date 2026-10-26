import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../widgets/dairy_portal_scaffold.dart';

class CenterManagerDashboardScreen extends StatefulWidget {
  const CenterManagerDashboardScreen({super.key});

  @override
  State<CenterManagerDashboardScreen> createState() =>
      _CenterManagerDashboardScreenState();
}

class _CenterManagerDashboardScreenState
    extends State<CenterManagerDashboardScreen> {
  String _selectedShift = 'All Shifts (Today)';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final user = AuthRepository.instance.currentUser;
    final centerName = (user != null && user.center.isNotEmpty && !user.center.contains('(HQ)'))
        ? user.center
        : 'Tonk Chilling Center #3';

    return DairyPortalScaffold(
      activeRoute: AppRoutes.managerDashboard,
      title: isDesktop ? 'Center Operations Portal' : 'Center Dashboard',
      portalType: DairyPortalType.manager,
      actions: [
        IconButton(
          tooltip: 'Rate Charts',
          icon: const Icon(Icons.currency_rupee, color: AppTheme.brandGreen),
          onPressed: () => context.push(AppRoutes.managerRates),
        ),
        IconButton(
          tooltip: 'Dispatch Logistics',
          icon: const Icon(Icons.local_shipping_outlined, color: AppTheme.brandTeal),
          onPressed: () => context.push(AppRoutes.managerDispatch),
        ),
      ],
      body: isDesktop
          ? _buildDesktopView(context, centerName)
          : _buildMobileView(context, centerName),
    );
  }

  // =========================================================================
  // 1. DESKTOP VIEW (Widescreen >= 960px)
  // =========================================================================
  Widget _buildDesktopView(BuildContext context, String centerName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Center Badge & Shift Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront, color: AppTheme.brandGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        centerName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'Single Center Record • Active Procurement Station',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              // Shift Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedShift,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    items: const [
                      DropdownMenuItem(value: 'All Shifts (Today)', child: Text('All Shifts (Today)')),
                      DropdownMenuItem(value: 'Morning Shift (AM)', child: Text('Morning Shift (AM)')),
                      DropdownMenuItem(value: 'Evening Shift (PM)', child: Text('Evening Shift (PM)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedShift = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Center Key Metrics Strip
          _buildCenterKpiStrip(),
          const SizedBox(height: 24),

          // Main Center Operations Grid: Batches & Tanker Loading
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Morning & Evening Shift Batches
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildShiftBatchCard(
                      shiftTitle: 'Morning Collection Batch (AM)',
                      volume: '4,650 L',
                      cans: '142 Cans',
                      avgFat: '4.12%',
                      avgSnf: '8.65%',
                      rateAvg: '₹38.40/L',
                      isCompleted: true,
                    ),
                    const SizedBox(height: 16),
                    _buildShiftBatchCard(
                      shiftTitle: 'Evening Collection Batch (PM)',
                      volume: '3,800 L',
                      cans: '98 Cans',
                      avgFat: '4.10%',
                      avgSnf: '8.64%',
                      rateAvg: '₹38.25/L',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Right: Tanker Dispatch & Logistics Loading Status
              Expanded(
                flex: 5,
                child: _buildTankerLoadingCard(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Center Lab Quality & Farmers/Collectors Strip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildLabQualityCard(context)),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: _buildCenterPersonnelCard(context)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. MOBILE VIEW (Viewport < 960px)
  // =========================================================================
  Widget _buildMobileView(BuildContext context, String centerName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center Live Pill Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardMint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.brandGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: AppTheme.brandGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        centerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandGreenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Live Single Center Record • Today',
                        style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.brandGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hero Total Intake Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.greenGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandGreen.withOpacity(0.25),
                  blurRadius: 12,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Today's Center Intake",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.water_drop, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '8,450 Litres',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Morning: 4,650 L  |  Evening: 3,800 L',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3-Metric Quick Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniMetricCard(
                  title: 'Active Farmers',
                  value: '142',
                  icon: Icons.people_outline,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniMetricCard(
                  title: 'Avg FAT %',
                  value: '4.12%',
                  icon: Icons.science_outlined,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniMetricCard(
                  title: 'Avg SNF %',
                  value: '8.65%',
                  icon: Icons.opacity,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mobile Tanker Dispatch Prep Card
          _buildTankerLoadingCard(context),
          const SizedBox(height: 16),

          // Morning & Evening shift cards
          _buildShiftBatchCard(
            shiftTitle: 'Morning Batch (AM)',
            volume: '4,650 L',
            cans: '142 Cans',
            avgFat: '4.12%',
            avgSnf: '8.65%',
            rateAvg: '₹38.40/L',
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _buildShiftBatchCard(
            shiftTitle: 'Evening Batch (PM)',
            volume: '3,800 L',
            cans: '98 Cans',
            avgFat: '4.10%',
            avgSnf: '8.64%',
            rateAvg: '₹38.25/L',
            isCompleted: false,
          ),
          const SizedBox(height: 16),

          // Mobile Quick Nav Action Grid
          _buildMobileQuickNavGrid(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildCenterKpiStrip() {
    return Row(
      children: [
        Expanded(
          child: _buildDesktopKpiCard(
            label: "Today's Intake",
            value: '8,450 L',
            subtext: 'AM: 4,650 L | PM: 3,800 L',
            icon: Icons.water_drop,
            color: AppTheme.brandGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopKpiCard(
            label: 'Active Farmers',
            value: '142 Poured',
            subtext: 'Out of 160 Enrolled',
            icon: Icons.agriculture,
            color: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopKpiCard(
            label: 'Average FAT',
            value: '4.12%',
            subtext: 'Benchmark: ≥ 3.80%',
            icon: Icons.science,
            color: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopKpiCard(
            label: 'Average SNF',
            value: '8.65%',
            subtext: 'Benchmark: ≥ 8.20%',
            icon: Icons.analytics,
            color: const Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopKpiCard({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtext, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildShiftBatchCard({
    required String shiftTitle,
    required String volume,
    required String cans,
    required String avgFat,
    required String avgSnf,
    required String rateAvg,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shiftTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.cardMint : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? 'Received & Sealed' : 'Intake In Progress',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppTheme.brandGreenDark : const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _metricColumn('Intake Volume', volume, const Color(0xFF0F172A))),
              Expanded(child: _metricColumn('Milk Cans', cans, const Color(0xFF475569))),
              Expanded(child: _metricColumn('Avg FAT', avgFat, const Color(0xFFD97706))),
              Expanded(child: _metricColumn('Avg SNF', avgSnf, const Color(0xFF7C3AED))),
              Expanded(child: _metricColumn('Avg Rate', rateAvg, AppTheme.brandGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: valueColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTankerLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tanker Dispatch Preparation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Icon(Icons.local_shipping, color: AppTheme.brandTeal, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Assigned Tanker', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('RJ-14-GA-8890', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Driver Contact', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('Sanjay Sharma (9829001122)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filled Capacity', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('3,200 L / 5,000 L (64%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.64,
              minHeight: 8,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brandTeal),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Manage Tanker Loading & Chits'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => context.push(AppRoutes.managerDispatch),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabQualityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Center Quality & Lab Acceptance',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.managerQuality),
                child: const Text('View All Tests', style: TextStyle(fontSize: 12, color: AppTheme.brandGreen)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _labTestRow('Batch #TNK-401 (Morning Can 1-40)', 'FAT 4.15%', 'SNF 8.68%', 'PASS - Grade A'),
          const Divider(height: 16),
          _labTestRow('Batch #TNK-402 (Morning Can 41-90)', 'FAT 4.10%', 'SNF 8.62%', 'PASS - Grade A'),
          const Divider(height: 16),
          _labTestRow('Batch #TNK-403 (Evening Initial)', 'FAT 4.08%', 'SNF 8.60%', 'PASS - Grade A'),
        ],
      ),
    );
  }

  Widget _labTestRow(String title, String fat, String snf, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            Text('$fat | $snf | MBRT 4.5 hrs', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.cardMint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterPersonnelCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farmers & Field Route Operations',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 14),
          _personnelRow(
            icon: Icons.agriculture_outlined,
            title: '142 Farmers Registered',
            subtitle: '142 poured today (100% active morning turnout)',
            onTap: () => context.push(AppRoutes.managerFarmers),
          ),
          const Divider(height: 16),
          _personnelRow(
            icon: Icons.badge_outlined,
            title: '4 Route Collectors Active',
            subtitle: 'Village collection agents assigned to this center',
            onTap: () => context.push(AppRoutes.managerCollectors),
          ),
          const Divider(height: 16),
          _personnelRow(
            icon: Icons.currency_rupee_outlined,
            title: 'Center Rate Matrix Active',
            subtitle: 'FAT ₹7.20 / SNF ₹4.80 slab schedule',
            onTap: () => context.push(AppRoutes.managerRates),
          ),
        ],
      ),
    );
  }

  Widget _personnelRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF334155), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileQuickNavGrid(BuildContext context) {
    final actions = [
      {'title': 'Tanker Dispatch', 'icon': Icons.local_shipping_outlined, 'route': AppRoutes.managerDispatch, 'color': AppTheme.brandTeal},
      {'title': 'Lab Quality', 'icon': Icons.science_outlined, 'route': AppRoutes.managerQuality, 'color': const Color(0xFF7C3AED)},
      {'title': 'Farmers', 'icon': Icons.agriculture_outlined, 'route': AppRoutes.managerFarmers, 'color': AppTheme.brandGreen},
      {'title': 'Collectors', 'icon': Icons.badge_outlined, 'route': AppRoutes.managerCollectors, 'color': const Color(0xFF0284C7)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Center Operations Quick Access',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemCount: actions.length,
          itemBuilder: (ctx, i) {
            final a = actions[i];
            final color = a['color'] as Color;
            return InkWell(
              onTap: () => context.push(a['route'] as String),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a['icon'] as IconData, color: color, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['title'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
