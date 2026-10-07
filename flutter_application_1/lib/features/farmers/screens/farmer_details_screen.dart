import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/widgets/error_message.dart';
import '../../../models/farmer.dart';
import '../../../services/farmer_service.dart';

class FarmerDetailsScreen extends StatelessWidget {
  final String farmerId;
  final FarmerService _farmerService = FarmerService();

  FarmerDetailsScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Details')),
      body: FutureBuilder<Farmer?>(
        future: _farmerService.getFarmerById(farmerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return ErrorMessage(
              message: 'Farmer not found',
              retryLabel: 'Back to farmers',
              onRetry: () => context.go(AppRoutes.farmers),
            );
          }

          final farmer = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    farmer.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
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
                      _InfoRow(label: 'Collection Center', value: farmer.center),
                      _InfoRow(label: 'Status', value: farmer.status),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
