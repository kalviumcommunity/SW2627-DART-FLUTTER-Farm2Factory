import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmer.dart';

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _farmers => _firestore.collection('farmers');

  Future<void> createFarmer(Farmer farmer) async {
    await _farmers.doc(farmer.id).set({
      ...farmer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Farmer>> getFarmers() async {
    final snapshot = await _farmers.get();
    return snapshot.docs
        .map(
          (doc) => Farmer.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Farmer?> getFarmerById(String id) async {
    final doc = await _farmers.doc(id).get();
    if (!doc.exists) return null;
    return Farmer.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }

  Future<void> updateFarmer(
    Farmer farmer,
  ) async {
    await _farmers.doc(farmer.id).update(
      farmer.toMap(),
    );
  }
}

