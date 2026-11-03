import '../features/collector/models/milk_entry.dart';

/// Represents a combined milk dispatch batch (e.g., milk tanker or collection batch)
/// aggregating multiple individual farmer milk entries from a collection center.
class Batch {
  final String id; // e.g. BATCH-20261015-AM-01
  final String centerId; // e.g. Jaipur Center
  final String centerName; // e.g. Central Valley Collection Center
  final String shift; // 'Morning (AM)' or 'Evening (PM)'
  final String milkType; // 'cow', 'buffalo', or 'mixed'
  final DateTime date;
  final double totalLitres;
  final double averageFat; // weighted average
  final double averageSnf; // weighted average
  final double averageTemperature;
  final String status; // 'PENDING', 'IN_TRANSIT', 'ACCEPTED', 'REJECTED'
  final String? rejectionReason;
  final String? tankerNumber;
  final String? driverName;
  final List<String> entryIds; // IDs of member milk_entries
  final List<String> farmerIds; // IDs of unique farmers contributing
  final DateTime createdAt;
  final DateTime? testedAt;
  final String? testedBy;

  const Batch({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.shift,
    this.milkType = 'cow',
    required this.date,
    required this.totalLitres,
    required this.averageFat,
    required this.averageSnf,
    required this.averageTemperature,
    this.status = 'PENDING',
    this.rejectionReason,
    this.tankerNumber,
    this.driverName,
    required this.entryIds,
    required this.farmerIds,
    required this.createdAt,
    this.testedAt,
    this.testedBy,
  });

  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isPending => status == 'PENDING';
  bool get isInTransit => status == 'IN_TRANSIT';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'centerId': centerId,
      'centerName': centerName,
      'shift': shift,
      'milkType': milkType,
      'date': date,
      'totalLitres': totalLitres,
      'averageFat': averageFat,
      'averageSnf': averageSnf,
      'averageTemperature': averageTemperature,
      'status': status,
      'rejectionReason': ?rejectionReason,
      'tankerNumber': ?tankerNumber,
      'driverName': ?driverName,
      'entryIds': entryIds,
      'farmerIds': farmerIds,
      'createdAt': createdAt,
      'testedAt': ?testedAt,
      'testedBy': ?testedBy,
    };
  }

  factory Batch.fromMap(String documentId, Map<String, dynamic> map) {
    return Batch(
      id: documentId,
      centerId: map['centerId'] ?? '',
      centerName: map['centerName'] ?? '',
      shift: map['shift'] ?? 'Morning (AM)',
      milkType: map['milkType'] ?? 'cow',
      date: map['date'] != null
          ? (map['date'] as dynamic).toDate()
          : DateTime.now(),
      totalLitres: (map['totalLitres'] ?? 0).toDouble(),
      averageFat: (map['averageFat'] ?? 0).toDouble(),
      averageSnf: (map['averageSnf'] ?? 0).toDouble(),
      averageTemperature: (map['averageTemperature'] ?? 4.0).toDouble(),
      status: map['status'] ?? 'PENDING',
      rejectionReason: map['rejectionReason'] as String?,
      tankerNumber: map['tankerNumber'] as String?,
      driverName: map['driverName'] as String?,
      entryIds: List<String>.from(map['entryIds'] ?? []),
      farmerIds: List<String>.from(map['farmerIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      testedAt: map['testedAt'] != null
          ? (map['testedAt'] as dynamic).toDate()
          : null,
      testedBy: map['testedBy'] as String?,
    );
  }
}

/// Traceability report for when a batch is inspected or rejected.
/// Connects a Batch back to its exact contributing milk collections and farmers.
class BatchTraceabilityReport {
  final Batch batch;
  final List<MilkEntry> sourceEntries;
  final int totalFarmers;
  final Set<String> farmerNames;
  final List<MilkEntry> flaggedEntries; // entries that had suspect quality (e.g. low fat/snf or high temp)
  final String traceabilitySummary;

  const BatchTraceabilityReport({
    required this.batch,
    required this.sourceEntries,
    required this.totalFarmers,
    required this.farmerNames,
    required this.flaggedEntries,
    required this.traceabilitySummary,
  });
}
