import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/collector_repository.dart';
import '../data/dairy_analytics_repository.dart';
import '../data/dairy_payment_repository.dart';
import '../data/dispatch_repository.dart';
import '../data/seller_repository.dart';
import '../models/dispatch_record.dart';
import '../widgets/dairy_filter_bar.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/dairy_stat_card.dart';

class DairyAdminDashboardScreen extends StatefulWidget {
  const DairyAdminDashboardScreen({super.key});

  @override
  State<DairyAdminDashboardScreen> createState() =>
      _DairyAdminDashboardScreenState();
}

class _DairyAdminDashboardScreenState extends State<DairyAdminDashboardScreen> {
  String _selectedDateFilter = 'Today';
  String _selectedCenter = 'All Centers';

  final _analyticsRepo = DairyAnalyticsRepository.instance;
  final _collectorRepo = CollectorRepository.instance;
  final _dispatchRepo = DispatchRepository.instance;
  final _sellerRepo = SellerRepository.instance;
  final _paymentRepo = DairyPaymentRepository.instance;

  void _showDispatchDialog(BuildContext context) {
    final vehicleNoCtrl = TextEditingController(text: 'RJ-14-GA-8890');
    final driverCtrl = TextEditingController(text: 'Sanjay Sharma');
    final capacityCtrl = TextEditingController(text: '5000');
    final containersCtrl = TextEditingController(text: '120');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
                    driverPhone: '9829001122',
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
                Navigator.pop(context);
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
      title: 'Operations Dashboard',
      actions: [
        IconButton(
          tooltip: 'Dispatch Tanker',
          icon: const Icon(Icons.add_road, color: AppTheme.brandTeal),
          onPressed: () => _showDispatchDialog(context),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
            const SizedBox(height: 18),

            // Cow & Milk Theme Hero Banner
            _buildHeroOperationsBanner(context),
            const SizedBox(height: 20),

            // Live Operational Alerts Ticker
            _buildAlertsSection(),
            const SizedBox(height: 24),

            // SECTION A: Today's Milk Collection
            _buildSectionHeader(
              title: "Today's Milk Collection",
              subtitle: 'Real-time intake from collection centers and farm supplies',
              icon: Icons.water_drop,
              iconColor: const Color(0xFF0288D1),
              trailing: '840 Entries',
            ),
            const SizedBox(height: 12),
            _buildMilkCollectionGrid(),
            const SizedBox(height: 24),

            // SECTION B: Collector Summary & Performance
            _buildSectionHeader(
              title: 'Collector Network Summary',
              subtitle: 'Individual collection center operators and agents',
              icon: Icons.badge_outlined,
              iconColor: AppTheme.brandGreen,
              onViewAll: () => context.go('/dairy/collectors'),
            ),
            const SizedBox(height: 12),
            _buildCollectorsSummaryGrid(context),
            const SizedBox(height: 24),

            // SECTION C: Dispatch & Tanker Logistics
            _buildSectionHeader(
              title: 'Dispatch & Tanker Movement',
              subtitle: 'Active insulated road tankers and container trucks',
              icon: Icons.local_shipping_outlined,
              iconColor: AppTheme.brandTeal,
              onViewAll: () => context.go('/dairy/dispatch'),
            ),
            const SizedBox(height: 12),
            _buildDispatchSummaryGrid(context),
            const SizedBox(height: 24),

            // SECTION D: Sellers & Commercial Suppliers
            _buildSectionHeader(
              title: 'Sellers & Commercial Farms',
              subtitle: 'Direct high-volume suppliers and cattle farms',
              icon: Icons.agriculture_outlined,
              iconColor: const Color(0xFF558B2F),
              onViewAll: () => context.go('/dairy/sellers'),
            ),
            const SizedBox(height: 12),
            _buildSellersSummaryGrid(context),
            const SizedBox(height: 24),

            // SECTION E: Payments & Financial Payouts
            _buildSectionHeader(
              title: 'Payments & Settlement Summary',
              subtitle: '10-Day billing cycle and pending disbursals',
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFFE65100),
              onViewAll: () => context.go('/dairy/payments'),
            ),
            const SizedBox(height: 12),
            _buildPaymentsSummaryGrid(context),
            const SizedBox(height: 24),

            // SECTION F: Milk Quality & Lab Standards
            _buildSectionHeader(
              title: 'Quality & Lab Composition',
              subtitle: 'FAT, SNF, and Chilling temperature conformance',
              icon: Icons.science_outlined,
              iconColor: const Color(0xFF7B1FA2),
              onViewAll: () => context.go('/dairy/quality'),
            ),
            const SizedBox(height: 12),
            _buildQualitySummaryGrid(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroOperationsBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF269352), Color(0xFF136836)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F8A4C).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Cow Mascot Accent
          Positioned(
            right: -6,
            bottom: -4,
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(
                'assets/images/cow_mascot.png',
                height: 125,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text(
                            'Central Dairy Hub Live',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$_selectedCenter | $_selectedDateFilter',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '42,850 Litres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Total Milk Received Today (Morning: 23,400 L | Evening: 19,450 L)",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroChip(icon: Icons.grain, label: 'Avg FAT: 4.25%'),
                    _heroChip(icon: Icons.opacity, label: 'Avg SNF: 8.55%'),
                    _heroChip(icon: Icons.thermostat, label: 'Chilled at 4.1°C'),
                    _heroChip(icon: Icons.check_circle, label: '98.6% Grade A'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = _analyticsRepo.metric.activeAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alt) {
        final isHigh = alt.severity == 'High';
        final isWarning = alt.severity == 'Warning';
        final bgColor = isHigh
            ? const Color(0xFFFFEBEE)
            : isWarning
                ? const Color(0xFFFFF3E0)
                : const Color(0xFFE8F5E9);
        final textColor = isHigh
            ? const Color(0xFFC62828)
            : isWarning
                ? const Color(0xFFE65100)
                : AppTheme.brandGreenDark;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor.withValues(alpha: 0.2)),
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
                    Text(
                      alt.title,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      alt.message,
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.85)),
                    ),
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? trailing,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View Details', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
                Icon(Icons.chevron_right, size: 15, color: AppTheme.brandGreen),
              ],
            ),
          )
        else if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trailing,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
          ),
      ],
    );
  }

  Widget _buildMilkCollectionGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: const [
          DairyStatCard(
            icon: Icons.wb_sunny_outlined,
            iconColor: Color(0xFFF57C00),
            title: 'Morning Shift (AM)',
            value: '23,400 L',
            subtitle: '54.6% of day intake',
            cardBgColor: AppTheme.cardPeach,
          ),
          DairyStatCard(
            icon: Icons.nightlight_round_outlined,
            iconColor: Color(0xFF5C6BC0),
            title: 'Evening Shift (PM)',
            value: '19,450 L',
            subtitle: '45.4% of day intake',
            cardBgColor: AppTheme.cardLavender,
          ),
          DairyStatCard(
            icon: Icons.person_search_outlined,
            iconColor: AppTheme.brandGreen,
            title: 'Avg per Collector',
            value: '1,020 L',
            subtitle: 'Across 5 centers',
            cardBgColor: AppTheme.cardMint,
          ),
          DairyStatCard(
            icon: Icons.receipt_long_outlined,
            iconColor: Color(0xFF0288D1),
            title: 'Collection Entries',
            value: '840 entries',
            subtitle: '100% device synced',
            cardBgColor: AppTheme.cardSky,
          ),
        ],
      );
    });
  }

  Widget _buildCollectorsSummaryGrid(BuildContext context) {
    final collectors = _collectorRepo.collectors;
    final active = collectors.where((c) => c.status == 'Active' || c.status == 'Collecting').length;
    final collecting = collectors.where((c) => c.status == 'Collecting').length;
    final offline = collectors.where((c) => c.status == 'Offline').length;

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: [
          DairyStatCard(
            icon: Icons.group_outlined,
            iconColor: AppTheme.brandGreen,
            title: 'Total Collectors',
            value: '${collectors.length} Agents',
            subtitle: '$active currently active',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/collectors'),
          ),
          DairyStatCard(
            icon: Icons.sensors,
            iconColor: const Color(0xFF0288D1),
            title: 'Currently Collecting',
            value: '$collecting Center',
            subtitle: 'Live session open',
            badgeText: 'Live',
            badgeColor: AppTheme.brandGreen,
            cardBgColor: AppTheme.cardSky,
            onTap: () => context.go('/dairy/collectors'),
          ),
          DairyStatCard(
            icon: Icons.star_outline,
            iconColor: const Color(0xFFFFA000),
            title: 'Top Collector',
            value: 'Suresh Sharma',
            subtitle: '1,430 L (Jaipur Hub)',
            cardBgColor: AppTheme.cardPeach,
            onTap: () => context.go('/dairy/collectors/C-JAI-002'),
          ),
          DairyStatCard(
            icon: Icons.cloud_off_outlined,
            iconColor: Colors.grey.shade700,
            title: 'Offline / Inactive',
            value: '$offline Center',
            subtitle: 'Tonk Center offline',
            cardBgColor: Colors.white,
            onTap: () => context.go('/dairy/collectors'),
          ),
        ],
      );
    });
  }

  Widget _buildDispatchSummaryGrid(BuildContext context) {
    final dispatches = _dispatchRepo.dispatches;
    final enRoute = dispatches.where((d) => d.status == 'En Route').length;
    final delivered = dispatches.where((d) => d.status == 'Delivered').length;
    final totalContainers = dispatches.fold(0, (sum, d) => sum + d.containersCount);
    final totalDispatchedLitres = dispatches.fold(0, (sum, d) => sum + d.loadedLitres);

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: [
          DairyStatCard(
            icon: Icons.local_shipping,
            iconColor: AppTheme.brandTeal,
            title: 'Dispatched Fleet',
            value: '${dispatches.length} Tankers',
            subtitle: '$enRoute en route right now',
            cardBgColor: AppTheme.cardSky,
            onTap: () => context.go('/dairy/dispatch'),
          ),
          DairyStatCard(
            icon: Icons.route,
            iconColor: const Color(0xFF0288D1),
            title: 'En Route Litres',
            value: '$totalDispatchedLitres L',
            subtitle: 'Insulated milk transit',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/dispatch'),
          ),
          DairyStatCard(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF6A1B9A),
            title: 'Cans & Containers',
            value: '$totalContainers Cans',
            subtitle: 'Sealed & barcode scanned',
            cardBgColor: AppTheme.cardLavender,
            onTap: () => context.go('/dairy/dispatch'),
          ),
          DairyStatCard(
            icon: Icons.check_circle_outline,
            iconColor: AppTheme.brandGreen,
            title: 'Delivered to Silo',
            value: '$delivered Tankers',
            subtitle: 'Sikar tanker unloaded',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/dispatch'),
          ),
        ],
      );
    });
  }

  Widget _buildSellersSummaryGrid(BuildContext context) {
    final sellers = _sellerRepo.sellers;
    final active = sellers.where((s) => s.status == 'Active').length;
    final totalCattle = sellers.fold(0, (sum, s) => sum + s.cattleCount);
    final dailyBulk = sellers.fold(0.0, (sum, s) => sum + s.dailySupplyLitres);

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: [
          DairyStatCard(
            icon: Icons.domain,
            iconColor: const Color(0xFF558B2F),
            title: 'Commercial Farms',
            value: '${sellers.length} Farms',
            subtitle: '$active active contracts',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/sellers'),
          ),
          DairyStatCard(
            icon: Icons.pets_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Registered Cattle',
            value: '$totalCattle Heads',
            subtitle: 'HF & Desi dairy cows',
            cardBgColor: AppTheme.cardPeach,
            onTap: () => context.go('/dairy/sellers'),
          ),
          DairyStatCard(
            icon: Icons.water_drop,
            iconColor: const Color(0xFF0288D1),
            title: 'Direct Bulk Supply',
            value: '${dailyBulk.toInt()} L/day',
            subtitle: '23.8% of plant intake',
            cardBgColor: AppTheme.cardSky,
            onTap: () => context.go('/dairy/sellers'),
          ),
          DairyStatCard(
            icon: Icons.leaderboard,
            iconColor: const Color(0xFF2E7D32),
            title: 'Top Supplier',
            value: 'Raj. Gaushala',
            subtitle: '3,200 L/day (4.6% FAT)',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/sellers'),
          ),
        ],
      );
    });
  }

  Widget _buildPaymentsSummaryGrid(BuildContext context) {
    final pendingTotal = _paymentRepo.totalPendingPayout;
    final paidWeek = _paymentRepo.totalPaidThisWeek;
    final pendingCount = _paymentRepo.pendingCollectorsCount;

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: [
          DairyStatCard(
            icon: Icons.hourglass_top_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Pending Payout',
            value: '₹ ${(pendingTotal / 100000).toStringAsFixed(2)} Lakh',
            subtitle: '$pendingCount centers pending',
            badgeText: 'Due Soon',
            badgeColor: const Color(0xFFE65100),
            cardBgColor: AppTheme.cardPeach,
            onTap: () => context.go('/dairy/payments'),
          ),
          DairyStatCard(
            icon: Icons.check_circle_outline,
            iconColor: AppTheme.brandGreen,
            title: 'Paid This Week',
            value: '₹ ${(paidWeek / 100000).toStringAsFixed(2)} Lakh',
            subtitle: 'Processed via Bank RTGS',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/payments'),
          ),
          DairyStatCard(
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFF0288D1),
            title: 'Next Payout Date',
            value: '10th Oct 2026',
            subtitle: '10-Day Cycle #3',
            cardBgColor: AppTheme.cardSky,
            onTap: () => context.go('/dairy/payments'),
          ),
          DairyStatCard(
            icon: Icons.account_balance_outlined,
            iconColor: const Color(0xFF5C6BC0),
            title: 'Monthly Disbursal',
            value: '₹ 98.4 Lakh',
            subtitle: '100% on-time record',
            cardBgColor: AppTheme.cardLavender,
            onTap: () => context.go('/dairy/payments'),
          ),
        ],
      );
    });
  }

  Widget _buildQualitySummaryGrid(BuildContext context) {
    final m = _analyticsRepo.metric;

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
        children: [
          DairyStatCard(
            icon: Icons.star,
            iconColor: AppTheme.brandGreen,
            title: 'Grade A Purity',
            value: '${m.gradeAPercent}%',
            subtitle: 'Above 4.0 FAT & 8.5 SNF',
            badgeText: 'Target 80%+',
            cardBgColor: AppTheme.cardMint,
            onTap: () => context.go('/dairy/quality'),
          ),
          DairyStatCard(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFF57C00),
            title: 'Grade B (Warning)',
            value: '${m.gradeBPercent}%',
            subtitle: 'Slight fat fluctuation',
            cardBgColor: AppTheme.cardPeach,
            onTap: () => context.go('/dairy/quality'),
          ),
          DairyStatCard(
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFC62828),
            title: 'Rejected Volume',
            value: '${m.rejectedPercent}%',
            subtitle: 'Acidic or sour milk rejected',
            cardBgColor: const Color(0xFFFFEBEE),
            onTap: () => context.go('/dairy/quality'),
          ),
          DairyStatCard(
            icon: Icons.tune,
            iconColor: const Color(0xFF7B1FA2),
            title: 'Thresholds Config',
            value: 'Min ${m.minFatThreshold}% FAT',
            subtitle: 'SNF ≥ ${m.minSnfThreshold}% | ≤ ${m.maxTempThreshold}°C',
            cardBgColor: AppTheme.cardLavender,
            onTap: () => context.go('/dairy/quality'),
          ),
        ],
      );
    });
  }
}
