import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? center,
    String? collectorId,
    String? customId,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (center != null) 'center': center,
      if (collectorId != null) 'collectorId': collectorId,
      if (customId != null) 'customId': customId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
