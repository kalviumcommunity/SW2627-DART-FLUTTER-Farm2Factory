import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/farmer.dart';

class FarmerRepository extends ChangeNotifier {
  FarmerRepository._();

  static final FarmerRepository instance = FarmerRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _farmers =>
      _firestore.collection('farmers');

  static const List<String> centers = [
    'Jaipur Center',
    'Ajmer Center',
    'Sikar Center',
  ];

  // Local cache used by the existing UI.
  final List<Farmer> _farmersCache = [];

  List<Farmer> get farmers => List.unmodifiable(_farmersCache);

  /// Load all farmers from Firestore.
  Future<List<Farmer>> getFarmers() async {
    final snapshot = await _farmers.get();

    final farmers = snapshot.docs.map((doc) {
      final data = doc.data();

      return Farmer(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        village: data['village'] ?? '',
        center: data['center'] ?? '',
        status: data['status'] ?? 'Active',
      );
    }).toList();

    _farmersCache
      ..clear()
      ..addAll(farmers);

    notifyListeners();

    return farmers;
  }

  /// Create a new farmer in Firestore.
  Future<Farmer> createFarmer({
    required String name,
    required String phone,
    required String village,
    required String center,
    String status = 'Active',
  }) async {
    // Generate the next farmer ID.
    final snapshot = await _farmers.get();

    final id = 'F${(snapshot.docs.length + 1).toString().padLeft(3, '0')}';

    final farmer = Farmer(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      village: village.trim(),
      center: center,
      status: status,
    );

    await _farmers.doc(id).set({
      'id': farmer.id,
      'name': farmer.name,
      'phone': farmer.phone,
      'village': farmer.village,
      'center': farmer.center,
      'status': farmer.status,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Keep local cache updated.
    _farmersCache.add(farmer);

    notifyListeners();

    return farmer;
  }

  /// Get one farmer from Firestore by ID.
  Future<Farmer?> getFarmerById(String id) async {
    final doc = await _farmers.doc(id).get();

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
      status: data['status'] ?? 'Active',
    );

    // Update cache.
    final index = _farmersCache.indexWhere((f) => f.id == farmer.id);

    if (index >= 0) {
      _farmersCache[index] = farmer;
    } else {
      _farmersCache.add(farmer);
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

    return _farmersCache.where((farmer) {
      return farmer.name.toLowerCase().contains(q) ||
          farmer.id.toLowerCase().contains(q) ||
          farmer.village.toLowerCase().contains(q);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Compatibility methods for the existing screens.
  // ---------------------------------------------------------------------------

  /// Existing AddFarmerScreen calls this method.
  Future<Farmer> add({
    required String name,
    required String phone,
    required String village,
    required String center,
  }) {
    return createFarmer(
      name: name,
      phone: phone,
      village: village,
      center: center,
    );
  }

  /// Existing FarmerDetailsScreen expects a synchronous method.
  ///
  /// It reads from the local cache. The cache is populated by getFarmers()
  /// when the farmer list is loaded.
  Farmer? getById(String id) {
    for (final farmer in _farmersCache) {
      if (farmer.id == id) {
        return farmer;
      }
    }

    return null;
  }
}