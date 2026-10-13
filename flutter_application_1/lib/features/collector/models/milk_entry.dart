/// Milk collection record for Morning / Evening shift.
class MilkEntry {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerCode;
  final String collectorId;
  final String shift; // 'Morning (AM)' or 'Evening (PM)'
  final DateTime date;
  final double quantityLitres;
  final double fatPercentage;
  final double snfPercentage;
  final double ratePerLitre;
  final double totalAmount;
  final bool isSynced;

  const MilkEntry({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerCode,
    required this.collectorId,
    required this.shift,
    required this.date,
    required this.quantityLitres,
    required this.fatPercentage,
    required this.snfPercentage,
    required this.ratePerLitre,
    required this.totalAmount,
    this.isSynced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerCode': farmerCode,
      'collectorId': collectorId,
      'shift': shift,
      'date': date,
      'quantityLitres': quantityLitres,
      'fatPercentage': fatPercentage,
      'snfPercentage': snfPercentage,
      'ratePerLitre': ratePerLitre,
      'totalAmount': totalAmount,
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
      shift: map['shift'] ?? '',
      date: map['date'] != null 
          ? (map['date'] as dynamic).toDate() 
          : DateTime.now(),
      quantityLitres: (map['quantityLitres'] ?? 0).toDouble(),
      fatPercentage: (map['fatPercentage'] ?? 0).toDouble(),
      snfPercentage: (map['snfPercentage'] ?? 0).toDouble(),
      ratePerLitre: (map['ratePerLitre'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      isSynced: map['isSynced'] ?? true,
    );
  }
}
