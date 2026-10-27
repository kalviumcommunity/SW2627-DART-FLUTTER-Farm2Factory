import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/batch.dart';
import '../widgets/primary_button.dart';

/// Screen 3 in the navigation flow: Displays in-depth telemetry and metrics for a milk batch.
///
/// Demonstrates backward stack navigation using both the automatic Scaffold
/// AppBar back arrow and programmatic Navigator.pop(context).
class BatchDetailScreen extends StatelessWidget {
  final Batch batch;

  const BatchDetailScreen({
    super.key,
    required this.batch,
  });

  Color _getStatusColor() {
    switch (batch.status.toUpperCase()) {
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
    final statusColor = _getStatusColor();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        title: Text(
          batch.id,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        // Automatic back arrow provided by Flutter Navigator stack
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: statusColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'STATUS: ${batch.status}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: statusColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    batch.shift,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Telemetry grid
            const Text(
              'Batch Telemetry',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _MetricRow(label: 'Total Volume', value: '${batch.totalLitres.toStringAsFixed(1)} Litres'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Milk Variety', value: batch.milkType.toUpperCase()),
                  const Divider(height: 20),
                  _MetricRow(label: 'Average Fat', value: '${batch.averageFat.toStringAsFixed(2)}%'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Average SNF', value: '${batch.averageSnf.toStringAsFixed(2)}%'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Temperature', value: '${batch.averageTemperature.toStringAsFixed(1)} °C'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Collection Center', value: batch.centerName),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logistics info
            const Text(
              'Logistics & Transit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _MetricRow(label: 'Tanker Registration', value: batch.tankerNumber ?? 'RJ-14-TC-8891'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Designated Driver', value: batch.driverName ?? 'Vikram Gurjar'),
                  const Divider(height: 20),
                  _MetricRow(label: 'Contributing Farmers', value: '${batch.farmerIds.length} Farmers'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Programmatic backward navigation button (Navigator.pop)
            PrimaryButton(
              label: 'Done (Back to Batch List)',
              icon: Icons.arrow_back,
              outlined: true,
              onPressed: () {
                // Pop the current route off the stack to reveal the previous list screen
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Tapping the button above or the AppBar back arrow pops this screen off the stack.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
