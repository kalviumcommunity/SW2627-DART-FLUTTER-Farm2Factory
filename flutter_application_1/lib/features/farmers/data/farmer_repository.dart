import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';

/// Single source of truth and data repository for registered farmers.
/// Provides reactive state (ChangeNotifier), memory caching, Firestore persistence,
/// and filtering/search across cooperative centers.
class FarmerRepository extends ChangeNotifier {
  FarmerRepository._();

  static final FarmerRepository instance = FarmerRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _farmersCollection =>
      _firestore.collection('farmers');

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
      name: 'Ram Singh',
      phone: '9876543210',
      village: 'Jaipur Rural',
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

  /// Load all farmers from Firestore.
  Future<List<Farmer>> getFarmers() async {
    final snapshot = await _farmersCollection.get();

    final loadedFarmers = snapshot.docs
        .map((doc) => Farmer.fromMap(doc.id, doc.data()))
        .toList();

    _farmers
      ..clear()
      ..addAll(loadedFarmers);

    notifyListeners();
    return loadedFarmers;
  }

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

  /// Create a new farmer in Firestore with an auto-generated sequential ID (F001, etc.).
  Future<Farmer> createFarmer({
    required String name,
    required String phone,
    required String village,
    required String center,
    String status = 'Active',
    String? aadhaarNumber,
    String collectorId = 'C-BHN-001',
  }) async {
    final snapshot = await _farmersCollection.get();
    final id = 'F${(snapshot.docs.length + 1).toString().padLeft(3, '0')}';

    final farmer = Farmer(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      village: village.trim(),
      center: center,
      status: status,
      aadhaarNumber: aadhaarNumber?.trim().isEmpty ?? true
          ? null
          : aadhaarNumber!.trim(),
      collectorId: collectorId,
      createdAt: DateTime.now(),
    );

    final map = farmer.toMap();
    map['createdAt'] = FieldValue.serverTimestamp();
    await _farmersCollection.doc(id).set(map);

    _farmers.add(farmer);
    notifyListeners();

    return farmer;
  }

  /// Save or update an existing Farmer object.
  Future<void> saveFarmer(Farmer farmer) async {
    final map = farmer.toMap();
    if (farmer.createdAt == null) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    await _farmersCollection.doc(farmer.id).set(map, SetOptions(merge: true));

    final index = _farmers.indexWhere((f) => f.id == farmer.id);
    if (index >= 0) {
      _farmers[index] = farmer;
    } else {
      _farmers.add(farmer);
    }
    notifyListeners();
  }

  /// Update an existing Farmer in Firestore and cache.
  Future<void> updateFarmer(Farmer farmer) async {
    await saveFarmer(farmer);
  }

  /// Get one farmer from Firestore by ID (updates cache).
  Future<Farmer?> getFarmerById(String id) async {
    final doc = await _farmersCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final farmer = Farmer.fromMap(doc.id, doc.data()!);

    final index = _farmers.indexWhere((f) => f.id == farmer.id);
    if (index >= 0) {
      _farmers[index] = farmer;
    } else {
      _farmers.add(farmer);
    }

    notifyListeners();
    return farmer;
  }

  /// Delete a farmer by ID from Firestore and cache.
  Future<void> deleteFarmer(String id) async {
    await _farmersCollection.doc(id).delete();
    _farmers.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  /// Search cached farmers by name, ID or village.
  List<Farmer> search(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return farmers;
    }

    return _farmers.where((farmer) {
      return farmer.name.toLowerCase().contains(q) ||
          farmer.id.toLowerCase().contains(q) ||
          farmer.village.toLowerCase().contains(q);
    }).toList();
  }

  /// Existing AddFarmerScreen calls this method.
  Future<Farmer> add({
    required String name,
    required String phone,
    required String village,
    required String center,
    String? aadhaarNumber,
    String collectorId = 'C-BHN-001',
  }) {
    return createFarmer(
      name: name,
      phone: phone,
      village: village,
      center: center,
      aadhaarNumber: aadhaarNumber,
      collectorId: collectorId,
    );
  }

  /// Existing FarmerDetailsScreen expects a synchronous cached method.
  Farmer? getById(String id) {
    for (final farmer in _farmers) {
      if (farmer.id == id) {
        return farmer;
      }
    }
    return null;
  }
}
