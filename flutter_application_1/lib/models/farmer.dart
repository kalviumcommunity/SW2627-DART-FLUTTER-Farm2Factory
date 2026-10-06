import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String farmerId;
  final String name;
  final String phone;
  final String village;
  final String centerId;
  final String status;
  final DateTime? createdAt;

  Farmer({
    required this.farmerId,
    required this.name,
    required this.phone,
    required this.village,
    required this.centerId,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'name': name,
      'phone': phone,
      'village': village,
      'centerId': centerId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Farmer.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Farmer(
      farmerId: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      village: map['village'] ?? '',
      centerId: map['centerId'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
