import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified Farmer entity representing a dairy farmer registered in the cooperative.
/// Plain data model containing all cooperative profile fields, serialization, and deserialization.
class Farmer {
  final String id; // e.g. F001 or F-1024
  final String name;
  final String phone;
  final String village;
  final String center; // Collection center name
  final String? aadhaarNumber; // Optional Aadhaar ID
  final String collectorId; // Associated milk collector ID
  final String status; // 'Active' / 'Inactive'
  final DateTime? createdAt;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.center,
    this.aadhaarNumber,
    this.collectorId = 'C-BHN-001',
    this.status = 'Active',
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  /// Serialization to Firestore document map
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'phone': phone,
      'village': village,
      'center': center,
      'collectorId': collectorId,
      'status': status,
    };
    if (aadhaarNumber != null && aadhaarNumber!.trim().isNotEmpty) {
      data['aadhaarNumber'] = aadhaarNumber!.trim();
    }
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    return data;
  }

  /// Deserialization from Firestore document snapshot
  factory Farmer.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? created;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated);
    }

    final rawAadhaar = map['aadhaarNumber'];
    final String? aadhaar = (rawAadhaar != null && rawAadhaar.toString().trim().isNotEmpty)
        ? rawAadhaar.toString().trim()
        : null;

    return Farmer(
      id: (map['id'] as String?)?.isNotEmpty == true ? map['id'] : id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      village: map['village'] ?? '',
      center: map['center'] ?? '',
      aadhaarNumber: aadhaar,
      collectorId: map['collectorId'] ?? 'C-BHN-001',
      status: map['status'] ?? 'Active',
      createdAt: created,
    );
  }

  /// Create a copy with modified fields
  Farmer copyWith({
    String? id,
    String? name,
    String? phone,
    String? village,
    String? center,
    String? aadhaarNumber,
    String? collectorId,
    String? status,
    DateTime? createdAt,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      village: village ?? this.village,
      center: center ?? this.center,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      collectorId: collectorId ?? this.collectorId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Farmer(id: $id, name: $name, village: $village, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Farmer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
