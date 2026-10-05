import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmer_model.dart';

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'farmers';

  // Create Farmer
  Future<void> createFarmer(FarmerModel farmer) async {
    try {
      // If the ID is empty, let Firestore generate one, else use the provided one
      if (farmer.id.isEmpty) {
        await _firestore.collection(_collection).add(farmer.toMap());
      } else {
        await _firestore.collection(_collection).doc(farmer.id).set(farmer.toMap());
      }
    } catch (e) {
      print('Error creating farmer: $e');
      rethrow;
    }
  }

  // Get all Farmers
  Stream<List<FarmerModel>> getFarmers() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FarmerModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Get Farmer by ID
  Future<FarmerModel?> getFarmerById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return FarmerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting farmer: $e');
      rethrow;
    }
  }

  // Update Farmer
  Future<void> updateFarmer(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      print('Error updating farmer: $e');
      rethrow;
    }
  }
}
