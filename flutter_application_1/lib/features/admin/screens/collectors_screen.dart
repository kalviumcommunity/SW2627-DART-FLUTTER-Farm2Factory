import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/collector_repository.dart';
import '../models/collector.dart';
import '../widgets/dairy_filter_bar.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/status_badge.dart';

class CollectorsScreen extends StatefulWidget {
  const CollectorsScreen({super.key});

  @override
  State<CollectorsScreen> createState() => _CollectorsScreenState();
}

class _CollectorsScreenState extends State<CollectorsScreen> {
  String _selectedCenter = 'All Centers';
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final _collectorRepo = CollectorRepository.instance;

  List<Collector> get _filteredCollectors {
    return _collectorRepo.collectors.where((c) {
      if (_selectedCenter != 'All Centers' && !c.center.toLowerCase().contains(_selectedCenter.toLowerCase().replaceAll(' center', ''))) {
        return false;
      }
      if (_selectedStatus != 'All' && c.status.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = c.name.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q) ||
            c.center.toLowerCase().contains(q) ||
            c.phone.contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCollectors;

    return DairyPortalScaffold(
      activeRoute: '/dairy/collectors',
      title: 'Collection Centers & Operators',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            DairyFilterBar(
              selectedDateFilter: 'Today',
              selectedCenter: _selectedCenter,
              searchHint: 'Search collector by name, ID or phone...',
              onDateFilterChanged: (_) {},
              onCenterChanged: (c) => setState(() => _selectedCenter = c),
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            ),
            const SizedBox(height: 14),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Collecting', 'On Duty', 'Offline'].map((st) {
                  final isSelected = _selectedStatus == st;
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
                      selectedColor: AppTheme.brandGreen,
                      onSelected: (_) => setState(() => _selectedStatus = st),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Total count bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Collectors (${list.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Total Volume: ${list.fold(0.0, (sum, c) => sum + c.todayTotalLitres).toInt()} L',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandGreenDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Collectors List
            if (list.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  final collector = list[idx];
                  return _buildCollectorCard(context, collector);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorCard(BuildContext context, Collector c) {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/dairy/collectors/${c.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, ID, Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.brandGreen.withValues(alpha: 0.12),
                      child: Text(
                        c.name[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.brandGreenDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(status: c.status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${c.id}  •  ${c.center}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 14),

                // Metrics Matrix in Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardMint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricCol('Morning', '${c.morningLitresToday.toInt()} L'),
                      _metricCol('Evening', '${c.eveningLitresToday.toInt()} L'),
                      _metricCol('Today Total', '${c.todayTotalLitres.toInt()} L', isBold: true),
                      _metricCol('Farmers', '${c.farmersHandled}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Footer Row: Location, Last Collection, Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          c.location,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Active ${c.lastActiveTime}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 10),
                        StatusBadge(
                          status: c.paymentStatus,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCol(String title, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: isBold ? AppTheme.brandGreenDark : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No collectors found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or center filter.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
