import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/call_helper.dart';
import '../../../core/widgets/error_message.dart';
import '../../collector/data/milk_entry_repository.dart';
import '../data/farmer_repository.dart';

class FarmerDetailsScreen extends StatelessWidget {
  final String farmerId;

  const FarmerDetailsScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    final farmer = FarmerRepository.instance.getById(farmerId);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.farmers),
        ),
        title: const Text(
          'Farmer Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Details',
            icon: const Icon(Icons.share_outlined, color: Color(0xFF64748B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Farmer profile link copied for ${farmer?.name ?? ""}'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: farmer == null
          ? ErrorMessage(
              message: 'Farmer not found',
              retryLabel: 'Back to farmers',
              onRetry: () => context.go(AppRoutes.farmers),
            )
          : ListenableBuilder(
              listenable: MilkEntryRepository.instance,
              builder: (context, _) {
                final entries =
                    MilkEntryRepository.instance.getEntriesForFarmer(farmer.id);
                final totalLitres =
                    entries.fold(0.0, (sum, e) => sum + e.quantityLitres);
                final totalEarnings =
                    entries.fold(0.0, (sum, e) => sum + e.totalAmount);
                final avgFat = entries.isEmpty
                    ? 4.2
                    : (entries.fold(0.0, (sum, e) => sum + e.fatPercentage) /
                        entries.length);

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.brandGreen.withOpacity(0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandGreen.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppTheme.brandGreen,
                            child: Text(
                              farmer.name.isNotEmpty
                                  ? farmer.name[0].toUpperCase()
                                  : 'F',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  farmer.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.brandGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        farmer.id,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      farmer.phone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${farmer.village} • ${farmer.center}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.brandGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text(
                              'Record Milk Pour',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => context.push(
                              AppRoutes.milkEntries,
                              extra: farmer.id,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.call, size: 18, color: AppTheme.brandTeal),
                            label: const Text('Call'),
                            onPressed: () {
                              CallHelper.showCallChooser(
                                context,
                                name: farmer.name,
                                phone: farmer.phone,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Summary Stats Grid
                    Row(
                      children: [
                        _buildStatBox(
                          title: 'Total Milk',
                          value: entries.isEmpty
                              ? '23.5 L'
                              : '${totalLitres.toStringAsFixed(1)} L',
                          icon: Icons.water_drop,
                          iconColor: const Color(0xFF0288D1),
                          bgColor: const Color(0xFFE1F5FE),
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          title: 'Avg Fat %',
                          value: '${avgFat.toStringAsFixed(1)}%',
                          icon: Icons.science,
                          iconColor: const Color(0xFFE65100),
                          bgColor: const Color(0xFFFFF3E0),
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          title: 'Earnings',
                          value: entries.isEmpty
                              ? '₹ 970'
                              : '₹ ${totalEarnings.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee,
                          iconColor: AppTheme.brandGreen,
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Official Profile Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Farmer & Center Details',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Divider(height: 18),
                          _detailRow(Icons.person_outline, 'Farmer Name', farmer.name),
                          _detailRow(Icons.badge_outlined, 'Farmer Code', farmer.id),
                          _detailRow(
                            Icons.phone_outlined,
                            'Mobile Number',
                            farmer.phone,
                            onTap: () => CallHelper.showCallChooser(
                              context,
                              name: farmer.name,
                              phone: farmer.phone,
                            ),
                          ),
                          _detailRow(Icons.holiday_village_outlined, 'Village / Area', farmer.village),
                          _detailRow(Icons.business_outlined, 'Collection Center', farmer.center),
                          _detailRow(Icons.support_agent_outlined, 'Connected Collector', farmer.collectorId),
                          if (farmer.aadhaarNumber != null)
                            _detailRow(Icons.credit_card_outlined, 'Aadhaar (Verified)', farmer.aadhaarNumber!),
                          _detailRow(Icons.verified_outlined, 'Account Status', farmer.status,
                              highlight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent Milk Pours Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Milk Entries',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${entries.length} Entries',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (entries.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.water_drop_outlined,
                                size: 36, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text(
                              'No milk entries recorded today for this farmer',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Record First Entry'),
                              onPressed: () => context.push(
                                AppRoutes.milkEntries,
                                extra: farmer.id,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...entries.map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: e.shift.contains('Morning')
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  e.shift.contains('Morning')
                                      ? Icons.wb_sunny_outlined
                                      : Icons.nightlight_outlined,
                                  color: e.shift.contains('Morning')
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF5E35B1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${e.shift} • ${e.quantityLitres} L',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Fat: ${e.fatPercentage}%  |  SNF: ${e.snfPercentage}%  |  ₹${e.ratePerLitre.toStringAsFixed(1)}/L',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹ ${e.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.brandGreenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
    VoidCallback? onTap,
  }) {
    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: onTap != null ? AppTheme.brandGreen : Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? AppTheme.brandGreen
                  : (onTap != null ? AppTheme.brandTeal : const Color(0xFF1E293B)),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.call_outlined, size: 14, color: AppTheme.brandTeal),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: rowContent,
      );
    }
    return rowContent;
  }
}
