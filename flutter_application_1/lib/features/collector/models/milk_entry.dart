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
}
