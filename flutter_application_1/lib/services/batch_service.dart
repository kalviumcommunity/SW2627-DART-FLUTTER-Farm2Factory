import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/collector/data/milk_entry_service.dart';
import '../features/collector/models/milk_entry.dart';
import '../models/batch.dart';

class BatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MilkEntryService _milkEntryService = MilkEntryService();

  CollectionReference get _batches => _firestore.collection('batches');

  /// Creates a new batch by aggregating a list of milk collections.
  /// Computes total litres, weighted average Fat %, weighted average SNF %,
  /// and average temperature. Also links the collections to this batchId.
  Future<Batch> createBatch({
    required String centerId,
    required String centerName,
    required String shift,
    String milkType = 'cow',
    String? tankerNumber,
    String? driverName,
    required List<MilkEntry> entries,
  }) async {
    if (entries.isEmpty) {
      throw ArgumentError('Cannot create a batch with 0 milk entries.');
    }

    final now = DateTime.now();
    final cleanCenter = centerId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final shiftStr = shift.toLowerCase().contains('morning') || shift.contains('AM')
        ? 'AM'
        : 'PM';
    final batchCode =
        'BATCH-$cleanCenter-$dateStr-$shiftStr-${now.millisecondsSinceEpoch % 1000}';

    double totalLitres = 0;
    double weightedFatSum = 0;
    double weightedSnfSum = 0;
    double tempSum = 0;
    final Set<String> uniqueFarmers = {};
    final List<String> entryIds = [];

    for (final e in entries) {
      totalLitres += e.quantityLitres;
      weightedFatSum += (e.fatPercentage * e.quantityLitres);
      weightedSnfSum += (e.snfPercentage * e.quantityLitres);
      tempSum += e.temperature;
      uniqueFarmers.add(e.farmerId);
      entryIds.add(e.id);
    }

    final avgFat = totalLitres > 0 ? (weightedFatSum / totalLitres) : 0.0;
    final avgSnf = totalLitres > 0 ? (weightedSnfSum / totalLitres) : 0.0;
    final avgTemp = entries.isNotEmpty ? (tempSum / entries.length) : 4.0;

    final batch = Batch(
      id: batchCode,
      centerId: centerId,
      centerName: centerName,
      shift: shift,
      milkType: milkType,
      date: now,
      totalLitres: double.parse(totalLitres.toStringAsFixed(2)),
      averageFat: double.parse(avgFat.toStringAsFixed(2)),
      averageSnf: double.parse(avgSnf.toStringAsFixed(2)),
      averageTemperature: double.parse(avgTemp.toStringAsFixed(1)),
      status: 'IN_TRANSIT',
      tankerNumber: tankerNumber ?? 'RJ-14-GA-4501',
      driverName: driverName ?? 'Suresh Yadav',
      entryIds: entryIds,
      farmerIds: uniqueFarmers.toList(),
      createdAt: now,
    );

    // Save batch document to Firestore
    await _batches.doc(batch.id).set({
      ...batch.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Link member milk collections in Firestore with this batchId
    await _milkEntryService.assignEntriesToBatch(batch.id, entryIds);

    return batch;
  }

  /// Get all batches, optionally filtered by centerId or status.
  Future<List<Batch>> getBatches({String? centerId, String? status}) async {
    Query query = _batches.orderBy('createdAt', descending: true);

    if (centerId != null && centerId.isNotEmpty) {
      query = query.where('centerId', isEqualTo: centerId);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Batch.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get a single batch by ID.
  Future<Batch?> getBatchById(String batchId) async {
    final doc = await _batches.doc(batchId).get();
    if (!doc.exists) return null;
    return Batch.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Update batch status (e.g. ACCEPTED or REJECTED) with tested metrics & reason.
  Future<void> updateBatchStatus({
    required String batchId,
    required String status,
    String? rejectionReason,
    String? testedBy,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': status,
      'testedAt': FieldValue.serverTimestamp(),
    };
    if (rejectionReason != null) {
      updateData['rejectionReason'] = rejectionReason;
    }
    if (testedBy != null) {
      updateData['testedBy'] = testedBy;
    }
    await _batches.doc(batchId).update(updateData);
  }

  /// Core Problem Statement Solver:
  /// Trace a batch back to all its contributing milk collections and farmers.
  /// If the batch was rejected, identify suspect milk collections that triggered
  /// or contributed to the quality shortfall.
  Future<BatchTraceabilityReport> traceBatchSources(String batchId) async {
    final batch = await getBatchById(batchId);
    if (batch == null) {
      throw Exception('Batch $batchId not found.');
    }

    final entries = await _milkEntryService.getEntriesByBatchId(batchId);
    final Set<String> farmerNames = {};
    final List<MilkEntry> flagged = [];

    for (final e in entries) {
      farmerNames.add(e.farmerName);

      // Flag collections that had substandard quality (low fat < 3.5%, low snf < 8.2%, or high temp > 6°C)
      if (e.fatPercentage < 3.5 ||
          e.snfPercentage < 8.2 ||
          e.temperature > 6.0 ||
          !e.isAccepted) {
        flagged.add(e);
      }
    }

    final suspectText = flagged.isNotEmpty
        ? ' Found ${flagged.length} suspect collection(s) contributing to quality shortfall.'
        : ' All contributing collections meet standard thresholds.';
    final summary =
        'Batch ${batch.id} contains ${entries.length} collections (${batch.totalLitres} L) from ${farmerNames.length} farmers.$suspectText';

    return BatchTraceabilityReport(
      batch: batch,
      sourceEntries: entries,
      totalFarmers: farmerNames.length,
      farmerNames: farmerNames,
      flaggedEntries: flagged,
      traceabilitySummary: summary,
    );
  }
}
