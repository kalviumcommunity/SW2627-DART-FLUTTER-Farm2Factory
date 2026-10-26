import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milk_entry.dart';

class MilkEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _entries => _firestore.collection('milk_entries');

  Future<void> createEntry(MilkEntry entry) async {
    await _entries.doc(entry.id).set({
      ...entry.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MilkEntry>> getEntriesForFarmer(String farmerId) async {
    final snapshot = await _entries
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<MilkEntry>> getEntriesForCenter(String centerId) async {
    final snapshot = await _entries
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Get accepted collections that are ready to be packaged into a batch.
  Future<List<MilkEntry>> getUnbatchedEntries(String centerId) async {
    final snapshot = await _entries
        .where('qualityStatus', isEqualTo: 'ACCEPTED')
        .get();

    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .where((e) => e.batchId == null || e.batchId!.isEmpty)
        .toList();
  }

  /// Assign a list of milk collections to a batch.
  Future<void> assignEntriesToBatch(String batchId, List<String> entryIds) async {
    final batch = _firestore.batch();
    for (final entryId in entryIds) {
      batch.update(_entries.doc(entryId), {'batchId': batchId});
    }
    await batch.commit();
  }

  /// Traceability: Retrieve all collections that contributed to a specific batch.
  Future<List<MilkEntry>> getEntriesByBatchId(String batchId) async {
    final snapshot = await _entries
        .where('batchId', isEqualTo: batchId)
        .get();

    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Get daily collections filtered by date and optional shift.
  Future<List<MilkEntry>> getDailyCollections({
    required DateTime date,
    String? shift,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    Query query = _entries
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay);

    if (shift != null) {
      query = query.where('shift', isEqualTo: shift);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Dashboard Aggregations for today
  Future<Map<String, dynamic>> getTodayDashboardStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _entries
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .get();

    double totalLitres = 0;
    double todayPayout = 0;
    final Set<String> activeFarmers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final entry = MilkEntry.fromMap(doc.id, data);

      totalLitres += entry.quantityLitres;
      todayPayout += entry.totalAmount;
      activeFarmers.add(entry.farmerId);
    }

    return {
      'todayTotalLitres': totalLitres,
      'activeFarmersCount': activeFarmers.length,
      'todayPayout': todayPayout,
      'totalEntriesCount': snapshot.docs.length,
    };
  }
}
