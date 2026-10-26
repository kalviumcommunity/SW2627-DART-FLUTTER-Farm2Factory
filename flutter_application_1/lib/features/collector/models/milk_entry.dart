/// Milk collection record for Morning / Evening shift with Quality & Batch Traceability.
class MilkEntry {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerCode;
  final String collectorId;
  final String centerId;
  final String shift; // 'Morning (AM)' or 'Evening (PM)'
  final DateTime date;
  final String milkType; // 'cow' or 'buffalo'
  final double quantityLitres;
  final double fatPercentage;
  final double snfPercentage;
  final double temperature; // e.g. 4.2 °C
  final String qualityStatus; // 'ACCEPTED' or 'REJECTED'
  final String qualityGrade; // 'Premium', 'Good', 'Fair', 'Substandard'
  final String? rejectionReason;
  final double ratePerLitre;
  final double totalAmount;
  final String? batchId; // assigned when collection is grouped into a batch
  final bool isSynced;

  const MilkEntry({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerCode,
    required this.collectorId,
    this.centerId = 'Jaipur Center',
    required this.shift,
    required this.date,
    this.milkType = 'cow',
    required this.quantityLitres,
    required this.fatPercentage,
    required this.snfPercentage,
    this.temperature = 4.0,
    this.qualityStatus = 'ACCEPTED',
    this.qualityGrade = 'Good',
    this.rejectionReason,
    required this.ratePerLitre,
    required this.totalAmount,
    this.batchId,
    this.isSynced = true,
  });

  bool get isAccepted => qualityStatus == 'ACCEPTED';
  bool get isBatched => batchId != null && batchId!.isNotEmpty;

  MilkEntry copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerCode,
    String? collectorId,
    String? centerId,
    String? shift,
    DateTime? date,
    String? milkType,
    double? quantityLitres,
    double? fatPercentage,
    double? snfPercentage,
    double? temperature,
    String? qualityStatus,
    String? qualityGrade,
    String? rejectionReason,
    double? ratePerLitre,
    double? totalAmount,
    String? batchId,
    bool? isSynced,
  }) {
    return MilkEntry(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerCode: farmerCode ?? this.farmerCode,
      collectorId: collectorId ?? this.collectorId,
      centerId: centerId ?? this.centerId,
      shift: shift ?? this.shift,
      date: date ?? this.date,
      milkType: milkType ?? this.milkType,
      quantityLitres: quantityLitres ?? this.quantityLitres,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      snfPercentage: snfPercentage ?? this.snfPercentage,
      temperature: temperature ?? this.temperature,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      ratePerLitre: ratePerLitre ?? this.ratePerLitre,
      totalAmount: totalAmount ?? this.totalAmount,
      batchId: batchId ?? this.batchId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerCode': farmerCode,
      'collectorId': collectorId,
      'centerId': centerId,
      'shift': shift,
      'date': date,
      'milkType': milkType,
      'quantityLitres': quantityLitres,
      'fatPercentage': fatPercentage,
      'snfPercentage': snfPercentage,
      'temperature': temperature,
      'qualityStatus': qualityStatus,
      'qualityGrade': qualityGrade,
      'rejectionReason': ?rejectionReason,
      'ratePerLitre': ratePerLitre,
      'totalAmount': totalAmount,
      'batchId': ?batchId,
      'isSynced': isSynced,
    };
  }

  factory MilkEntry.fromMap(String documentId, Map<String, dynamic> map) {
    return MilkEntry(
      id: documentId,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      farmerCode: map['farmerCode'] ?? '',
      collectorId: map['collectorId'] ?? '',
      centerId: map['centerId'] ?? 'Jaipur Center',
      shift: map['shift'] ?? '',
      date: map['date'] != null
          ? (map['date'] as dynamic).toDate()
          : DateTime.now(),
      milkType: map['milkType'] ?? 'cow',
      quantityLitres: (map['quantityLitres'] ?? 0).toDouble(),
      fatPercentage: (map['fatPercentage'] ?? 0).toDouble(),
      snfPercentage: (map['snfPercentage'] ?? 0).toDouble(),
      temperature: (map['temperature'] ?? 4.0).toDouble(),
      qualityStatus: map['qualityStatus'] ?? 'ACCEPTED',
      qualityGrade: map['qualityGrade'] ?? 'Good',
      rejectionReason: map['rejectionReason'] as String?,
      ratePerLitre: (map['ratePerLitre'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      batchId: map['batchId'] as String?,
      isSynced: map['isSynced'] ?? true,
    );
  }
}
