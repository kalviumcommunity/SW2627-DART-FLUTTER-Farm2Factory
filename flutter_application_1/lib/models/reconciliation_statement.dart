import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/collector/models/milk_entry.dart';

/// Represents a farmer's automated digital reconciliation statement for a billing cycle (10-day or monthly).
/// Directly addresses the core problem statement:
/// "Month-end reconciliation takes several days, disputes over readings are frequent..."
class FarmerReconciliationStatement {
  final String id;
  final String farmerId;
  final String farmerName;
  final String center;
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final double totalLitres;
  final int totalCollections;
  final double avgFat;
  final double avgSnf;
  final double grossPayable;
  final double deductions;
  final double netPayable;
  final int disputedCount;
  final String status; // 'PENDING', 'DISBURSED', 'DISPUTED'
  final DateTime? paidAt;
  final String? transactionRef;
  final List<MilkEntry> entries;

  const FarmerReconciliationStatement({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.center,
    required this.cycleStart,
    required this.cycleEnd,
    required this.totalLitres,
    required this.totalCollections,
    required this.avgFat,
    required this.avgSnf,
    required this.grossPayable,
    this.deductions = 0.0,
    required this.netPayable,
    this.disputedCount = 0,
    this.status = 'PENDING',
    this.paidAt,
    this.transactionRef,
    this.entries = const [],
  });

  bool get isDisbursed => status.toUpperCase() == 'DISBURSED';
  bool get hasDispute => disputedCount > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'center': center,
      'cycleStart': Timestamp.fromDate(cycleStart),
      'cycleEnd': Timestamp.fromDate(cycleEnd),
      'totalLitres': totalLitres,
      'totalCollections': totalCollections,
      'avgFat': avgFat,
      'avgSnf': avgSnf,
      'grossPayable': grossPayable,
      'deductions': deductions,
      'netPayable': netPayable,
      'disputedCount': disputedCount,
      'status': status,
      if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
      if (transactionRef != null) 'transactionRef': transactionRef,
    };
  }

  factory FarmerReconciliationStatement.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<MilkEntry> entries = const [],
  }) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return FarmerReconciliationStatement(
      id: id,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      center: map['center'] ?? 'Central Valley Collection Center',
      cycleStart: parseDate(map['cycleStart']),
      cycleEnd: parseDate(map['cycleEnd']),
      totalLitres: (map['totalLitres'] as num?)?.toDouble() ?? 0.0,
      totalCollections: (map['totalCollections'] as num?)?.toInt() ?? 0,
      avgFat: (map['avgFat'] as num?)?.toDouble() ?? 0.0,
      avgSnf: (map['avgSnf'] as num?)?.toDouble() ?? 0.0,
      grossPayable: (map['grossPayable'] as num?)?.toDouble() ?? 0.0,
      deductions: (map['deductions'] as num?)?.toDouble() ?? 0.0,
      netPayable: (map['netPayable'] as num?)?.toDouble() ?? 0.0,
      disputedCount: (map['disputedCount'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? 'PENDING',
      paidAt: map['paidAt'] != null ? parseDate(map['paidAt']) : null,
      transactionRef: map['transactionRef'],
      entries: entries,
    );
  }

  FarmerReconciliationStatement copyWith({
    String? status,
    DateTime? paidAt,
    String? transactionRef,
  }) {
    return FarmerReconciliationStatement(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      center: center,
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
      totalLitres: totalLitres,
      totalCollections: totalCollections,
      avgFat: avgFat,
      avgSnf: avgSnf,
      grossPayable: grossPayable,
      deductions: deductions,
      netPayable: netPayable,
      disputedCount: disputedCount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      transactionRef: transactionRef ?? this.transactionRef,
      entries: entries,
    );
  }
}

/// Aggregate summary of an entire 10-day or monthly reconciliation cycle.
class ReconciliationCycleSummary {
  final String cycleLabel;
  final DateTime startDate;
  final DateTime endDate;
  final double totalLitres;
  final double totalPayable;
  final int farmerCount;
  final int totalCollections;
  final int pendingPayouts;
  final List<FarmerReconciliationStatement> statements;

  const ReconciliationCycleSummary({
    required this.cycleLabel,
    required this.startDate,
    required this.endDate,
    required this.totalLitres,
    required this.totalPayable,
    required this.farmerCount,
    required this.totalCollections,
    required this.pendingPayouts,
    required this.statements,
  });
}
