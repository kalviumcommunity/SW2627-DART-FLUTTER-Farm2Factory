import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/theme_mode_button.dart';
import '../../auth/data/auth_repository.dart';
import '../../collector/data/milk_entry_repository.dart';
import '../../collector/models/milk_entry.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final user = AuthRepository.instance.currentUser;
        final farmerName = user?.name ?? 'Ram Singh';
        final farmerId = user?.id ?? 'F001';
        final collectorName = 'Ramesh Kumar (ID: C-BHN-001)';

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        title: Row(
          children: [
            const AppLogo(size: 30),
            const SizedBox(width: 8),
            Text(
              'Farmer Portal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeModeButton(),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
            onPressed: () {
              AuthRepository.instance.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: MilkEntryRepository.instance,
        builder: (context, _) =>
            _buildTabBody(farmerName, farmerId, collectorName),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.scaffoldBg,
          border: Border(top: BorderSide(color: AppTheme.creamBorder)),
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (idx) => setState(() => _currentTab = idx),
          backgroundColor: AppTheme.scaffoldBg,
          indicatorColor: AppTheme.brandGreen.withOpacity(0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today, color: AppTheme.brandGreen),
              label: 'Daily Records',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments, color: AppTheme.brandGreen),
              label: 'Payment',
            ),
            NavigationDestination(
              icon: Icon(Icons.science_outlined),
              selectedIcon: Icon(Icons.science, color: AppTheme.brandGreen),
              label: 'Quality',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.brandGreen),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildTabBody(String name, String id, String collector) {
    if (_currentTab == 1) return _buildPaymentTab();
    if (_currentTab == 2) return _buildQualityTab();
    if (_currentTab == 3) return _buildProfileTab(name, id, collector);

    final entries = MilkEntryRepository.instance.getEntriesForFarmer(id);
    MilkEntry? morningEntry;
    MilkEntry? eveningEntry;
    for (final e in entries) {
      if (morningEntry == null && e.shift.contains('Morning')) {
        morningEntry = e;
      } else if (eveningEntry == null && e.shift.contains('Evening')) {
        eveningEntry = e;
      }
    }

    // Default: Daily Records / Today's Sell View
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.isDark
                    ? [const Color(0xFF0F291E), const Color(0xFF1B3D2B)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.brandGreen.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.brandGreen,
                  child: Text(
                    name.isNotEmpty ? name[0] : 'R',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Farmer ID: $id',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected Collector: $collector',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/cow_mascot.png',
                    height: 56,
                    width: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Today's Sell Heading
          Text(
            "Today's Sell",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Morning (AM) & Evening (PM) Cards
          Row(
            children: [
              Expanded(
                child: _ShiftSellCard(
                  shiftTitle: 'Morning (AM)',
                  icon: Icons.wb_sunny_outlined,
                  headerColor: AppTheme.isDark ? const Color(0xFF2E1C0A) : const Color(0xFFFFF3E0),
                  accentColor: AppTheme.isDark ? const Color(0xFFFBBF24) : const Color(0xFFE65100),
                  litres: morningEntry != null
                      ? '${morningEntry.quantityLitres} L'
                      : '12.5 L',
                  fat: morningEntry != null
                      ? '${morningEntry.fatPercentage}%'
                      : '4.2%',
                  snf: morningEntry != null
                      ? '${morningEntry.snfPercentage}%'
                      : '8.5%',
                  rate: morningEntry != null
                      ? '₹ ${morningEntry.ratePerLitre.toStringAsFixed(2)}/L'
                      : '₹ 42.00/L',
                  total: morningEntry != null
                      ? '₹ ${morningEntry.totalAmount.toStringAsFixed(2)}'
                      : '₹ 525.00',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShiftSellCard(
                  shiftTitle: 'Evening (PM)',
                  icon: Icons.nightlight_outlined,
                  headerColor: AppTheme.isDark ? const Color(0xFF1E1736) : const Color(0xFFEDE7F6),
                  accentColor: AppTheme.isDark ? const Color(0xFFC084FC) : const Color(0xFF5E35B1),
                  litres: eveningEntry != null
                      ? '${eveningEntry.quantityLitres} L'
                      : '11.0 L',
                  fat: eveningEntry != null
                      ? '${eveningEntry.fatPercentage}%'
                      : '4.0%',
                  snf: eveningEntry != null
                      ? '${eveningEntry.snfPercentage}%'
                      : '8.4%',
                  rate: eveningEntry != null
                      ? '₹ ${eveningEntry.ratePerLitre.toStringAsFixed(2)}/L'
                      : '₹ 40.50/L',
                  total: eveningEntry != null
                      ? '₹ ${eveningEntry.totalAmount.toStringAsFixed(2)}'
                      : '₹ 445.50',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Monthly Earnings Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF01579B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month Earnings',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹ 14,850',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '520 Litres',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Pours & Records
          Text(
            'Recent Pours & Records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isNotEmpty)
            ...entries.take(4).map(
                  (e) => _buildDayRow(
                    '${e.shift} (${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')})',
                    '${e.quantityLitres} L',
                    '₹ ${e.totalAmount.toStringAsFixed(2)}',
                  ),
                )
          else ...[
            _buildDayRow('Yesterday (06 Oct)', '23.0 L', '₹ 958.00'),
            _buildDayRow('05 Oct 2026', '24.5 L', '₹ 1,029.00'),
            _buildDayRow('04 Oct 2026', '22.0 L', '₹ 924.00'),
            _buildDayRow('03 Oct 2026', '23.5 L', '₹ 970.00'),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDayRow(String date, String litres, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppTheme.brandGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                litres,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Payment Ledger',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          period: '21 Sep - 30 Sep 2026',
          litres: '235.0 L',
          amount: '₹ 9,870.00',
          status: 'PAID (Bank Transfer)',
          statusColor: Colors.green,
          date: '02 Oct 2026',
        ),
        _buildPaymentCard(
          period: '11 Sep - 20 Sep 2026',
          litres: '240.5 L',
          amount: '₹ 10,101.00',
          status: 'PAID (Cash Handover)',
          statusColor: Colors.green,
          date: '22 Sep 2026',
        ),
        _buildPaymentCard(
          period: '01 Oct - 10 Oct 2026',
          litres: '162.0 L',
          amount: '₹ 6,804.00',
          status: 'PROCESSING (Due 12 Oct)',
          statusColor: Colors.orange,
          date: 'Expected in 3 days',
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String period,
    required String litres,
    required String amount,
    required String status,
    required Color statusColor,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period,
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Supplied: $litres',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(date,
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          Divider(height: 18, color: AppTheme.creamBorder),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Milk Quality Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardMint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Quality Rating',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Grade A (Premium Buffalo Milk)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consistently meeting SNF > 8.5% and Fat > 4.0%',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildQualityMetricTile('Fat Percentage', '4.2 % avg', 'Target: 4.0%'),
        _buildQualityMetricTile('SNF Percentage', '8.5 % avg', 'Target: 8.5%'),
        _buildQualityMetricTile(
            'Water Adulteration Check', 'Zero (Pure)', 'Passed all 30 tests'),
      ],
    );
  }

  Widget _buildQualityMetricTile(String title, String value, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text(sub,
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(String name, String id, String collector) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.brandGreen,
            child: Text(
              name.isNotEmpty ? name[0] : 'R',
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Center(
          child: Text(
            'Farmer ID: $id',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _profileRow('Mobile Phone', '9876543210'),
                const Divider(),
                _profileRow('Village', 'Jaipur Rural'),
                const Divider(),
                _profileRow('Associated Collector', collector),
                const Divider(),
                _profileRow('Animal Type', 'Buffalo & Cow'),
                const Divider(),
                _profileRow('Status', 'Active Member'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, size: 20, color: AppTheme.brandGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Theme & Appearance',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const ThemeModeButton(showLabel: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Switch between Light (crisp day) and Dark (OLED midnight) mode.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Change Appearance (Light / Dark / Auto)'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.creamBorder),
                      foregroundColor: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen,
                    ),
                    onPressed: () => showThemeSelectionDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftSellCard extends StatelessWidget {
  final String shiftTitle;
  final IconData icon;
  final Color headerColor;
  final Color accentColor;
  final String litres;
  final String fat;
  final String snf;
  final String rate;
  final String total;

  const _ShiftSellCard({
    required this.shiftTitle,
    required this.icon,
    required this.headerColor,
    required this.accentColor,
    required this.litres,
    required this.fat,
    required this.snf,
    required this.rate,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    shiftTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  litres,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _statRow('Fat', fat),
                const SizedBox(height: 3),
                _statRow('SNF', snf),
                const SizedBox(height: 3),
                _statRow('Rate', rate),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          total,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.brandGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }
}
