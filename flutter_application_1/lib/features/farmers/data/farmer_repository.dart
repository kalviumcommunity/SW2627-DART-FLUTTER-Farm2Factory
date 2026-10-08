import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';

/// Data store for registered farmers.
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

  final List<Farmer> _farmers = [];

  List<Farmer> get farmers => List.unmodifiable(_farmers);

  /// Load all farmers from Firestore.
  Future<List<Farmer>> getFarmers() async {
    final snapshot = await _farmersCollection.get();

    final farmers = snapshot.docs.map((doc) {
      final data = doc.data();

      return Farmer(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        village: data['village'] ?? '',
        center: data['center'] ?? '',
        aadhaarNumber: data['aadhaarNumber'],
        collectorId: data['collectorId'] ?? 'C-BHN-001',
        status: data['status'] ?? 'Active',
      );
    }).toList();

    _farmers
      ..clear()
      ..addAll(farmers);

    notifyListeners();

    return farmers;
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

  /// Create a new farmer in Firestore.
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
    );

    await _farmersCollection.doc(id).set({
      'id': farmer.id,
      'name': farmer.name,
      'phone': farmer.phone,
      'village': farmer.village,
      'center': farmer.center,
      'aadhaarNumber': farmer.aadhaarNumber,
      'collectorId': farmer.collectorId,
      'status': farmer.status,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _farmers.add(farmer);
    notifyListeners();

    return farmer;
  }

  /// Get one farmer from Firestore by ID.
  Future<Farmer?> getFarmerById(String id) async {
    final doc = await _farmersCollection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    final farmer = Farmer(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      village: data['village'] ?? '',
      center: data['center'] ?? '',
      aadhaarNumber: data['aadhaarNumber'],
      collectorId: data['collectorId'] ?? 'C-BHN-001',
      status: data['status'] ?? 'Active',
    );

    final index = _farmers.indexWhere((f) => f.id == farmer.id);
    if (index >= 0) {
      _farmers[index] = farmer;
    } else {
      _farmers.add(farmer);
    }

    notifyListeners();

    return farmer;
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

  /// Existing FarmerDetailsScreen expects a synchronous method.
  Farmer? getById(String id) {
    for (final farmer in _farmers) {
      if (farmer.id == id) {
        return farmer;
      }
    }

    return null;
  }
}
