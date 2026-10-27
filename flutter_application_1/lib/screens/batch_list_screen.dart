import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/batch.dart';
import '../widgets/primary_button.dart';
import 'batch_detail_screen.dart';

/// Screen 2 in the navigation flow: Displays a list of milk dispatch batches.
///
/// Tapping a batch item triggers forward navigation via [Navigator.push]
/// to open the [BatchDetailScreen].
class BatchListScreen extends StatelessWidget {
  const BatchListScreen({super.key});

  static List<Batch> get sampleBatches => [
        Batch(
          id: 'BATCH-20261027-AM-01',
          centerId: 'CC-01',
          centerName: 'Jaipur North Cooperative Center',
          shift: 'Morning (AM)',
          milkType: 'cow',
          date: DateTime(2026, 10, 27),
          totalLitres: 1450.0,
          averageFat: 4.30,
          averageSnf: 8.60,
          averageTemperature: 4.0,
          status: 'IN_TRANSIT',
          tankerNumber: 'RJ-14-TC-8891',
          driverName: 'Vikram Gurjar',
          entryIds: const ['E1', 'E2', 'E3'],
          farmerIds: const ['F101', 'F102', 'F103', 'F104'],
          createdAt: DateTime(2026, 10, 27, 8, 30),
        ),
        Batch(
          id: 'BATCH-20261027-AM-02',
          centerId: 'CC-02',
          centerName: 'Alwar Valley Collection Hub',
          shift: 'Morning (AM)',
          milkType: 'buffalo',
          date: DateTime(2026, 10, 27),
          totalLitres: 980.0,
          averageFat: 6.85,
          averageSnf: 9.20,
          averageTemperature: 4.2,
          status: 'ACCEPTED',
          tankerNumber: 'RJ-02-TC-4412',
          driverName: 'Mohan Sharma',
          entryIds: const ['E4', 'E5'],
          farmerIds: const ['F201', 'F202', 'F203'],
          createdAt: DateTime(2026, 10, 27, 9, 15),
        ),
        Batch(
          id: 'BATCH-20261027-PM-01',
          centerId: 'CC-01',
          centerName: 'Jaipur North Cooperative Center',
          shift: 'Evening (PM)',
          milkType: 'cow',
          date: DateTime(2026, 10, 27),
          totalLitres: 1220.0,
          averageFat: 4.15,
          averageSnf: 8.50,
          averageTemperature: 4.1,
          status: 'PENDING',
          tankerNumber: 'RJ-14-TC-9910',
          driverName: 'Ramesh Meena',
          entryIds: const ['E6', 'E7'],
          farmerIds: const ['F105', 'F106'],
          createdAt: DateTime(2026, 10, 27, 16, 0),
        ),
      ];

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return const Color(0xFF16A34A);
      case 'IN_TRANSIT':
        return const Color(0xFF0284C7);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = sampleBatches;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        title: const Text(
          'Milk Dispatch Batches',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        // Automatic back arrow pop provided by Flutter Navigator
      ),
      body: Column(
        children: [
          // Breadcrumb indicator explaining the stack
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFEFF6FF),
            child: const Row(
              children: [
                Icon(Icons.layers_outlined, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Text(
                  'Navigation Stack: [Home] -> [Batches List]',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = batches[index];
                final statusColor = _getStatusColor(batch.status);

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Forward Navigation: Push BatchDetailScreen onto the stack
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchDetailScreen(batch: batch),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: statusColor.withOpacity(0.15),
                            child: Icon(Icons.inventory_2_outlined, color: statusColor, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        batch.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        batch.status,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${batch.totalLitres.toStringAsFixed(1)}L • ${batch.milkType.toUpperCase()} • Fat ${batch.averageFat}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  batch.centerName,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Return to Home Screen',
              icon: Icons.home_outlined,
              outlined: true,
              onPressed: () {
                // Programmatic backward navigation to pop back to HomeScreen
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
