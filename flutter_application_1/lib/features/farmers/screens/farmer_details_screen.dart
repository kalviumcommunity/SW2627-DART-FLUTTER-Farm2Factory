import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_message.dart';
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
        title: const Text('Farmer Details'),
      ),
      body: farmer == null
          ? ErrorMessage(
              message: 'Farmer not found',
              retryLabel: 'Back to farmers',
              onRetry: () => context.go(AppRoutes.farmers),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.brandGreen, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.cardMint,
                      child: Text(
                        farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Name', value: farmer.name),
                        _InfoRow(label: 'Farmer ID', value: farmer.id),
                        _InfoRow(label: 'Phone', value: farmer.phone),
                        _InfoRow(label: 'Village', value: farmer.village),
                        _InfoRow(
                            label: 'Collection Center', value: farmer.center),
                        _InfoRow(
                            label: 'Connected Collector',
                            value: farmer.collectorId),
                        if (farmer.aadhaarNumber != null)
                          _InfoRow(
                              label: 'Aadhaar Number',
                              value: farmer.aadhaarNumber!),
                        _InfoRow(label: 'Status', value: farmer.status),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// A "label: value" line used only on this screen.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
