import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerModel {
  final String id;
  final String name;
  final String phone;
  final String village;
  final String centerId;
  final String status;
  final DateTime createdAt;

  FarmerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.centerId,
    required this.status,
    required this.createdAt,
  });

  factory FarmerModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FarmerModel(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      village: data['village'] ?? '',
      centerId: data['centerId'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'centerId': centerId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
