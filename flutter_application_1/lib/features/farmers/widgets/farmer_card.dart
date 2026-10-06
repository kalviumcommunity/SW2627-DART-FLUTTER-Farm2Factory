import 'package:flutter/material.dart';

import '../../../models/farmer.dart';

/// One row in the farmer list.
class FarmerCard extends StatelessWidget {
  final Farmer farmer;
  final VoidCallback onTap;

  const FarmerCard({super.key, required this.farmer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(farmer.name[0].toUpperCase())),
        title: Text(farmer.name),
        subtitle: Text('${farmer.farmerId}  -  ${farmer.village}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
