import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/dispatch_repository.dart';
import '../models/dispatch_record.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/status_badge.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  final _dispatchRepo = DispatchRepository.instance;
  String _selectedStatusFilter = 'All';

  List<DispatchRecord> get _filteredDispatches {
    if (_selectedStatusFilter == 'All') return _dispatchRepo.dispatches;
    return _dispatchRepo.dispatches
        .where((d) => d.status.toLowerCase() == _selectedStatusFilter.toLowerCase())
        .toList();
  }

  void _showDriverTimelineModal(BuildContext context, DispatchRecord d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.vehicleNo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        'Driver: ${d.driverName} (+91 ${d.driverPhone})',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: d.status, fontSize: 13),
              ],
            ),
            const Divider(height: 24),

            const Text('Logistics 6-Stage Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...List.generate(d.timeline.length, (idx) {
              final step = d.timeline[idx];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: step.isCompleted ? AppTheme.brandGreen : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: step.isCompleted
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                      if (idx != d.timeline.length - 1)
                        Container(
                          width: 2,
                          height: 42,
                          color: step.isCompleted ? AppTheme.brandGreen : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                step.stageName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: step.isCompleted ? const Color(0xFF0F172A) : Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(step.time, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                        Text(step.note, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ],
              );
            }),

            const Divider(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last GPS Ping', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        d.lastKnownLocation,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dispatches = _filteredDispatches;

    return DairyPortalScaffold(
      activeRoute: '/dairy/dispatch',
      title: 'Dispatch & Fleet Logistics',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Pills Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'En Route', 'Dispatched', 'Delivered', 'Loading'].map((st) {
                  final isSelected = _selectedStatusFilter == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(st),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.brandTeal,
                      onSelected: (_) => setState(() => _selectedStatusFilter = st),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Tankers & Fleet (${dispatches.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loaded: ${dispatches.fold(0, (sum, d) => sum + d.loadedLitres)} L',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dispatches.length,
              itemBuilder: (context, idx) {
                final d = dispatches[idx];
                return _buildDispatchCard(context, d);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(BuildContext context, DispatchRecord d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.brandTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping, color: AppTheme.brandTeal, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.vehicleNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${d.vehicleType} • ${d.capacityLitres}L Cap', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: d.status),
              ],
            ),
            const Divider(height: 20),

            // Driver, Location, and Containers Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver: ${d.driverName}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('From: ${d.fromLocation}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('To: ${d.toDestination}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${d.loadedLitres} L', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
                    Text('${d.containersCount} Containers', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                    Text('Temp: ${d.temperature}°C', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0288D1))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Location Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, size: 14, color: AppTheme.brandTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      d.lastKnownLocation,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Actions & Timeline Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Amount: ₹ ${d.dispatchAmount.toInt()}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.timeline, size: 14),
                  label: const Text('Track', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showDriverTimelineModal(context, d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
