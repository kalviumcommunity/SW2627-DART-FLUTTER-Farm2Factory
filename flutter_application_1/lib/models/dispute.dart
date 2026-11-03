/// Represents a formal dispute raised by a farmer or collection center
/// contesting milk quantity, fat/snf quality readings, or rate calculations.
class Dispute {
  final String id; // e.g. DSP-20261026-001
  final String entryId; // Associated milk_entries document ID
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String centerId;
  final String collectorId;
  final DateTime collectionDate;
  final String shift; // 'Morning (AM)' or 'Evening (PM)'
  final String disputeType; // 'Quantity Mismatch', 'Fat/SNF Reading Dispute', 'Rate Calculation Error', 'Missing Entry'
  final String reason;
  final double recordedQuantity;
  final double? claimedQuantity;
  final double recordedFat;
  final double? claimedFat;
  final double recordedSnf;
  final double? claimedSnf;
  final double recordedAmount;
  final String status; // 'OPEN', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED'
  final String? resolutionNote;
  final double adjustedAmount; // Credit or debit adjustment to payout (e.g. ₹150.0)
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Dispute({
    required this.id,
    required this.entryId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.centerId,
    required this.collectorId,
    required this.collectionDate,
    required this.shift,
    required this.disputeType,
    required this.reason,
    required this.recordedQuantity,
    this.claimedQuantity,
    required this.recordedFat,
    this.claimedFat,
    required this.recordedSnf,
    this.claimedSnf,
    required this.recordedAmount,
    this.status = 'OPEN',
    this.resolutionNote,
    this.adjustedAmount = 0.0,
    this.resolvedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isOpen => status == 'OPEN';
  bool get isUnderReview => status == 'UNDER_REVIEW';
  bool get isResolved => status == 'RESOLVED';
  bool get isRejected => status == 'REJECTED';

  double get quantityDifference =>
      claimedQuantity != null ? (claimedQuantity! - recordedQuantity) : 0.0;

  double get fatDifference =>
      claimedFat != null ? (claimedFat! - recordedFat) : 0.0;

  double get snfDifference =>
      claimedSnf != null ? (claimedSnf! - recordedSnf) : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'centerId': centerId,
      'collectorId': collectorId,
      'collectionDate': collectionDate.toIso8601String(),
      'shift': shift,
      'disputeType': disputeType,
      'reason': reason,
      'recordedQuantity': recordedQuantity,
      'claimedQuantity': claimedQuantity,
      'recordedFat': recordedFat,
      'claimedFat': claimedFat,
      'recordedSnf': recordedSnf,
      'claimedSnf': claimedSnf,
      'recordedAmount': recordedAmount,
      'status': status,
      'resolutionNote': resolutionNote,
      'adjustedAmount': adjustedAmount,
      'resolvedBy': resolvedBy,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Dispute.fromMap(String docId, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return Dispute(
      id: docId,
      entryId: (map['entryId'] as String?) ?? '',
      farmerId: (map['farmerId'] as String?) ?? '',
      farmerName: (map['farmerName'] as String?) ?? 'Farmer',
      farmerPhone: (map['farmerPhone'] as String?) ?? '',
      centerId: (map['centerId'] as String?) ?? 'Central Hub',
      collectorId: (map['collectorId'] as String?) ?? 'Collector',
      collectionDate: parseDate(map['collectionDate']),
      shift: (map['shift'] as String?) ?? 'Morning (AM)',
      disputeType: (map['disputeType'] as String?) ?? 'Quantity Mismatch',
      reason: (map['reason'] as String?) ?? '',
      recordedQuantity: (map['recordedQuantity'] as num?)?.toDouble() ?? 0.0,
      claimedQuantity: (map['claimedQuantity'] as num?)?.toDouble(),
      recordedFat: (map['recordedFat'] as num?)?.toDouble() ?? 0.0,
      claimedFat: (map['claimedFat'] as num?)?.toDouble(),
      recordedSnf: (map['recordedSnf'] as num?)?.toDouble() ?? 0.0,
      claimedSnf: (map['claimedSnf'] as num?)?.toDouble(),
      recordedAmount: (map['recordedAmount'] as num?)?.toDouble() ?? 0.0,
      status: (map['status'] as String?) ?? 'OPEN',
      resolutionNote: map['resolutionNote'] as String?,
      adjustedAmount: (map['adjustedAmount'] as num?)?.toDouble() ?? 0.0,
      resolvedBy: map['resolvedBy'] as String?,
      createdAt: parseDate(map['createdAt']),
      resolvedAt: map['resolvedAt'] != null ? parseDate(map['resolvedAt']) : null,
    );
  }

  Dispute copyWith({
    String? id,
    String? entryId,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? centerId,
    String? collectorId,
    DateTime? collectionDate,
    String? shift,
    String? disputeType,
    String? reason,
    double? recordedQuantity,
    double? claimedQuantity,
    double? recordedFat,
    double? claimedFat,
    double? recordedSnf,
    double? claimedSnf,
    double? recordedAmount,
    String? status,
    String? resolutionNote,
    double? adjustedAmount,
    String? resolvedBy,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return Dispute(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      centerId: centerId ?? this.centerId,
      collectorId: collectorId ?? this.collectorId,
      collectionDate: collectionDate ?? this.collectionDate,
      shift: shift ?? this.shift,
      disputeType: disputeType ?? this.disputeType,
      reason: reason ?? this.reason,
      recordedQuantity: recordedQuantity ?? this.recordedQuantity,
      claimedQuantity: claimedQuantity ?? this.claimedQuantity,
      recordedFat: recordedFat ?? this.recordedFat,
      claimedFat: claimedFat ?? this.claimedFat,
      recordedSnf: recordedSnf ?? this.recordedSnf,
      claimedSnf: claimedSnf ?? this.claimedSnf,
      recordedAmount: recordedAmount ?? this.recordedAmount,
      status: status ?? this.status,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      adjustedAmount: adjustedAmount ?? this.adjustedAmount,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
