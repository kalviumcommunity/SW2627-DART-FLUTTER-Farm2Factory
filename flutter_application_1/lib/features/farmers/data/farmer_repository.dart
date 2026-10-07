import 'package:flutter/foundation.dart';

import '../models/farmer.dart';

/// Data store for registered farmers.
class FarmerRepository extends ChangeNotifier {
  FarmerRepository._();
  static final FarmerRepository instance = FarmerRepository._();

  static const List<String> centerTabs = [
    'All',
    'Jaipur',
    'Ajmer',
    'Sikar',
    'Tonk',
  ];

  static const List<String> centers = [
    'Jaipur Center',
    'Ajmer Center',
    'Sikar Center',
    'Tonk Center',
  ];

  final List<Farmer> _farmers = [
    const Farmer(
      id: 'F001',
      name: 'John Doe',
      phone: '9876543210',
      village: 'Jaipur',
      center: 'Jaipur Center',
    ),
    const Farmer(
      id: 'F002',
      name: 'Rahul Kumar',
      phone: '9123456780',
      village: 'Ajmer',
      center: 'Ajmer Center',
    ),
    const Farmer(
      id: 'F003',
      name: 'Sita Devi',
      phone: '9988776655',
      village: 'Sikar',
      center: 'Sikar Center',
    ),
    const Farmer(
      id: 'F004',
      name: 'Mohan Singh',
      phone: '9812345678',
      village: 'Jaipur',
      center: 'Jaipur Center',
    ),
    const Farmer(
      id: 'F005',
      name: 'Priya Sharma',
      phone: '9765432109',
      village: 'Ajmer',
      center: 'Ajmer Center',
    ),
    const Farmer(
      id: 'F006',
      name: 'Anil Meena',
      phone: '9654321098',
      village: 'Sikar',
      center: 'Sikar Center',
    ),
    const Farmer(
      id: 'F007',
      name: 'Kavita Yadav',
      phone: '9543210987',
      village: 'Jaipur',
      center: 'Jaipur Center',
    ),
  ];

  List<Farmer> get farmers => List.unmodifiable(_farmers);

  /// Filters by center and search query.
  List<Farmer> filterAndSearch({String query = '', String selectedCenter = 'All'}) {
    final q = query.trim().toLowerCase();
    return _farmers.where((f) {
      final matchesQuery = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.id.toLowerCase().contains(q) ||
          f.village.toLowerCase().contains(q);

      final matchesCenter = selectedCenter == 'All' ||
          f.center.toLowerCase().contains(selectedCenter.toLowerCase()) ||
          f.village.toLowerCase().contains(selectedCenter.toLowerCase());

      return matchesQuery && matchesCenter;
    }).toList();
  }

  Farmer? getById(String id) {
    for (final f in _farmers) {
      if (f.id == id) return f;
    }
    return null;
  }

  Farmer add({
    required String name,
    required String phone,
    required String village,
    required String center,
    String? aadhaarNumber,
    String collectorId = 'C-BHN-001',
  }) {
    final id = 'F${(_farmers.length + 1).toString().padLeft(3, '0')}';
    final farmer = Farmer(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      village: village.trim(),
      center: center,
      aadhaarNumber: aadhaarNumber?.trim(),
      collectorId: collectorId,
    );
    _farmers.add(farmer);
    notifyListeners();
    return farmer;
  }
}

