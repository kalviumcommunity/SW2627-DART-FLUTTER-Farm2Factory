import 'package:flutter/foundation.dart';

import '../models/farmer.dart';

/// DEMO data store (in memory). Later this class will talk to Cloud Firestore;
/// the screens will not need to change because they only call these methods.
class FarmerRepository extends ChangeNotifier {
  FarmerRepository._();
  static final FarmerRepository instance = FarmerRepository._();

  static const List<String> centers = [
    'Jaipur Center',
    'Ajmer Center',
    'Sikar Center',
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
  ];

  List<Farmer> get farmers => List.unmodifiable(_farmers);

  /// Matches name, id or village (case-insensitive).
  List<Farmer> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return farmers;
    return _farmers.where((f) {
      return f.name.toLowerCase().contains(q) ||
          f.id.toLowerCase().contains(q) ||
          f.village.toLowerCase().contains(q);
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
  }) {
    final id = 'F${(_farmers.length + 1).toString().padLeft(3, '0')}';
    final farmer = Farmer(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      village: village.trim(),
      center: center,
    );
    _farmers.add(farmer);
    notifyListeners(); // tells the list screen to redraw
    return farmer;
  }
}
