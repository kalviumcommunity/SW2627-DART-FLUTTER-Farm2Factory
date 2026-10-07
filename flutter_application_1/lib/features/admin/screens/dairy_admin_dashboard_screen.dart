import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/data/auth_repository.dart';
import '../data/vehicle_repository.dart';
import '../models/vehicle.dart';

class DairyAdminDashboardScreen extends StatefulWidget {
  const DairyAdminDashboardScreen({super.key});

  @override
  State<DairyAdminDashboardScreen> createState() =>
      _DairyAdminDashboardScreenState();
}

class _DairyAdminDashboardScreenState extends State<DairyAdminDashboardScreen> {
  final _vehicleRepo = VehicleRepository.instance;

  void _showDispatchVehicleDialog(BuildContext context) {
    final vehicleNoCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final capacityCtrl = TextEditingController(text: '5000');
    final containersCtrl = TextEditingController(text: '120');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Dispatch Milk Container Vehicle',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleNoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Vehicle / Tanker Number',
                  hintText: 'e.g. RJ-14-GA-1022',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: driverCtrl,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                  hintText: 'e.g. Vikram Singh',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity (Litres)',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: containersCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Containers Count',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (vehicleNoCtrl.text.isNotEmpty && driverCtrl.text.isNotEmpty) {
                _vehicleRepo.addVehicle(
                  Vehicle(
                    id: 'VH-${DateTime.now().millisecondsSinceEpoch % 1000}',
                    vehicleNo: vehicleNoCtrl.text.trim(),
                    driverName: driverCtrl.text.trim(),
                    driverPhone: '9829000000',
                    capacityLitres: int.tryParse(capacityCtrl.text) ?? 5000,
                    containersCount: int.tryParse(containersCtrl.text) ?? 120,
                    status: 'Dispatched',
                    route: 'Central Collection Route',
                    dispatchedAt: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vehicle dispatched successfully!'),
                    backgroundColor: AppTheme.brandGreen,
                  ),
                );
              }
            },
            child: const Text('Dispatch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            AppLogo(size: 32),
            SizedBox(width: 8),
            Text(
              'Dairy Operations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 20),
            onPressed: () {
              AuthRepository.instance.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dairy Plant Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3E4D), Color(0xFF132B37)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jaipur Cooperative Dairy Plant',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Plant Admin',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daily Container Dispatches & Collector Network Monitoring',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlantStatItem(
                          label: 'Dispatched Tankers', value: '3 Active'),
                      _PlantStatItem(
                          label: 'Connected Centers', value: '4 Centers'),
                      _PlantStatItem(
                          label: 'Total Received Today', value: '14,200 L'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Vehicle & Container Logistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_shipping,
                        color: AppTheme.brandTeal, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Vehicle & Container Logistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Dispatch'),
                  onPressed: () => _showDispatchVehicleDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: _vehicleRepo,
              builder: (context, _) {
                return Column(
                  children: _vehicleRepo.vehicles.map((vh) {
                    return _VehicleCard(vehicle: vh);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 2: Collectors Overview (Hierarchical separation - No direct farmers)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        color: AppTheme.brandGreen, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Active Collectors Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.cardMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Aggregates Only',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandGreenDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Individual farmers data is managed strictly by their assigned collectors.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Collector Cards
            _buildCollectorTile(
              id: 'C-BHN-001',
              name: 'Ramesh Kumar',
              center: 'Behror Center',
              todayMilk: '3,200 L',
              containers: '32 Cans',
              status: 'Handover Completed',
              statusColor: Colors.green,
            ),
            _buildCollectorTile(
              id: 'C-AJM-002',
              name: 'Suresh Verma',
              center: 'Ajmer South Center',
              todayMilk: '4,100 L',
              containers: '40 Cans',
              status: 'In Transit',
              statusColor: Colors.orange,
            ),
            _buildCollectorTile(
              id: 'C-KOT-003',
              name: 'Mukesh Sharma',
              center: 'Kotputli Center',
              todayMilk: '2,800 L',
              containers: '28 Cans',
              status: 'Collection Active',
              statusColor: Colors.blue,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectorTile({
    required String id,
    required String name,
    required String center,
    required String todayMilk,
    required String containers,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.brandTeal.withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.brandTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'ID: $id • $center',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Today: $todayMilk ($containers)',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _PlantStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.blue;
    if (vehicle.status == 'Dispatched') badgeColor = Colors.orange;
    if (vehicle.status == 'Received') badgeColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: AppTheme.brandTeal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    vehicle.vehicleNo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vehicle.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver: ${vehicle.driverName}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Route: ${vehicle.route}',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${vehicle.capacityLitres} L Capacity',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandTeal)),
                  Text('${vehicle.containersCount} Containers',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
