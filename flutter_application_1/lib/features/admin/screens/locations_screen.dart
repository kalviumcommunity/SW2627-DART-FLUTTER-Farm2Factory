import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../data/dairy_location_repository.dart';
import '../models/dairy_location.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/status_badge.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _repo = DairyLocationRepository.instance;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DairyPortalScaffold(
      activeRoute: '/dairy/locations',
      title: 'Locations & Fleet Telemetry',
      actions: [
        IconButton(
          tooltip: 'Refresh Telemetry',
          icon: const Icon(Icons.refresh, color: AppTheme.brandGreen),
          onPressed: () {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('GPS & Silo telemetry refreshed'),
                duration: Duration(seconds: 1),
                backgroundColor: AppTheme.brandGreen,
              ),
            );
          },
        ),
      ],
      body: AnimatedBuilder(
        animation: _repo,
        builder: (context, _) {
          final allLocations = _repo.locations;
          final filtered = allLocations.where((loc) {
            final matchesFilter = switch (_selectedFilter) {
              'Plants' => loc.type == DairyLocationType.plant,
              'Centers' => loc.type == DairyLocationType.center,
              'Farms' => loc.type == DairyLocationType.sellerFarm,
              'Vehicles' => loc.type == DairyLocationType.vehicle,
              _ => true,
            };
            final query = _searchQuery.toLowerCase();
            final matchesQuery = query.isEmpty ||
                loc.name.toLowerCase().contains(query) ||
                loc.city.toLowerCase().contains(query) ||
                loc.address.toLowerCase().contains(query) ||
                loc.contactPerson.toLowerCase().contains(query);
            return matchesFilter && matchesQuery;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderStats(allLocations),
                const SizedBox(height: 20),
                _buildGisSchematicMap(),
                const SizedBox(height: 24),
                _buildFilterAndSearchBar(),
                const SizedBox(height: 16),
                _buildLocationsGrid(filtered),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(List<DairyLocation> locations) {
    final plants = locations.where((l) => l.type == DairyLocationType.plant).length;
    final centers = locations.where((l) => l.type == DairyLocationType.center).length;
    final farms = locations.where((l) => l.type == DairyLocationType.sellerFarm).length;
    final vehicles = locations.where((l) => l.type == DairyLocationType.vehicle).length;

    return Row(
      children: [
        _buildStatChip(
          label: 'Processing Plant',
          value: '$plants Facility',
          icon: Icons.factory_outlined,
          color: AppTheme.brandGreen,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          label: 'Collection Centers',
          value: '$centers Active',
          icon: Icons.store_mall_directory_outlined,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          label: 'Seller Mega Farms',
          value: '$farms Connected',
          icon: Icons.agriculture_outlined,
          color: const Color(0xFFD97706),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          label: 'In-Transit Tankers',
          value: '$vehicles Tracked',
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGisSchematicMap() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF065F46).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.satellite_alt_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Regional Dairy Supply Network (Rajasthan Grid)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Jaipur Hub • Alwar • Sikar • Ajmer • Tonk Logistics Corridor',
                        style: TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, color: Color(0xFF6EE7B7), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Cellular Telemetry Active',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Schematic Map Nodes Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildMapNodeChip(
                  title: 'Jaipur Central Plant',
                  subtitle: 'Head Processing • 26.85°N, 75.76°E',
                  icon: Icons.factory,
                  color: const Color(0xFFFBBF24),
                  badge: '42,850 L/day',
                ),
                _buildMapNodeChip(
                  title: 'Behror Chilling Center',
                  subtitle: 'Alwar Corridor • 1000 L today',
                  icon: Icons.ac_unit,
                  color: const Color(0xFF67E8F9),
                  badge: '4.1°C Silo',
                ),
                _buildMapNodeChip(
                  title: 'Tanker RJ-14-GA-1022',
                  subtitle: 'NH-48 Kotputli • 46 km/h',
                  icon: Icons.local_shipping,
                  color: const Color(0xFFA78BFA),
                  badge: 'En Route',
                ),
                _buildMapNodeChip(
                  title: 'Green Valley Farm',
                  subtitle: 'Amer Rural • 2,000 L today',
                  icon: Icons.grass,
                  color: const Color(0xFF86EFAC),
                  badge: 'Direct Bulk',
                ),
                _buildMapNodeChip(
                  title: 'Shekhawati Chilling Station',
                  subtitle: 'Sikar Zone • 1,180 L today',
                  icon: Icons.storefront,
                  color: const Color(0xFFF472B6),
                  badge: '4.0°C Silo',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapNodeChip({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar() {
    final filters = ['All', 'Plants', 'Centers', 'Farms', 'Vehicles'];

    return Row(
      children: [
        // Filter tabs
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppTheme.brandGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.brandGreen : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Search box
        SizedBox(
          width: 260,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search city, facility, contact...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.brandGreen),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsGrid(List<DairyLocation> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'No locations or vehicles match your query',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 2 ? 1.75 : 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildLocationCard(list[index]);
          },
        );
      },
    );
  }

  Widget _buildLocationCard(DairyLocation loc) {
    final typeIcon = switch (loc.type) {
      DairyLocationType.plant => Icons.factory_outlined,
      DairyLocationType.center => Icons.store_mall_directory_outlined,
      DairyLocationType.sellerFarm => Icons.agriculture_outlined,
      DairyLocationType.vehicle => Icons.local_shipping_outlined,
    };

    final typeColor = switch (loc.type) {
      DairyLocationType.plant => AppTheme.brandGreen,
      DairyLocationType.center => const Color(0xFF2563EB),
      DairyLocationType.sellerFarm => const Color(0xFFD97706),
      DairyLocationType.vehicle => const Color(0xFF7C3AED),
    };

    final typeLabel = switch (loc.type) {
      DairyLocationType.plant => 'Processing Plant',
      DairyLocationType.center => 'Chilling Center',
      DairyLocationType.sellerFarm => 'Seller Dairy Farm',
      DairyLocationType.vehicle => 'Fleet Vehicle (En Route)',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type badge & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                status: loc.status.startsWith('Active') || loc.status.startsWith('Operating')
                    ? 'Active'
                    : loc.status.startsWith('En Route')
                        ? 'En Route'
                        : 'Completed',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name and ID
          Text(
            loc.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${loc.address}, ${loc.city}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          // Telemetry and Volume Info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DAILY THROUGHPUT', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${loc.todayVolumeLitres.toStringAsFixed(0)} Litres',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandGreen),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CONTACT / IN-CHARGE', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      loc.contactPerson,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Footer: GPS coordinates & telemetry timestamp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, size: 13, color: Color(0xFF059669)),
                const SizedBox(width: 5),
                Text(
                  '${loc.latitude.toStringAsFixed(4)}° N, ${loc.longitude.toStringAsFixed(4)}° E',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  loc.lastUpdated,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: '${loc.latitude}, ${loc.longitude}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('GPS coordinates copied: ${loc.latitude}, ${loc.longitude}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy, size: 14, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
