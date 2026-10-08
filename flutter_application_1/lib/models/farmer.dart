import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  final String id;
  final String name;
  final String phone;
  final String village;
  final String center;
  final String status;
  final DateTime? createdAt;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.center,
    this.status = 'Active',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'village': village,
      'center': center,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Farmer.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Farmer(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      village: map['village'] ?? '',
      center: map['center'] ?? '',
      status: map['status'] ?? 'Active',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}

