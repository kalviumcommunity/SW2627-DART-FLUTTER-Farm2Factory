import 'package:flutter/material.dart';

import '../models/farmer.dart';

/// Reusable farmer card used in the farmer list.
class FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback onTap;

  const FarmerCard({
    super.key,
    required this.farmer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          child: Text(
            farmer.name.isNotEmpty
                ? farmer.name[0].toUpperCase()
                : '?',
          ),
        ),

        title: Text(farmer.name),

        subtitle: Text(
          'ID: ${farmer.id}\n'
          'Village: ${farmer.village}',
        ),

        isThreeLine: true,

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              farmer.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: farmer.status.toLowerCase() == 'active'
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}