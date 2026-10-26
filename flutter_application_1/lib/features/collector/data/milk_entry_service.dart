import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/notification_item.dart';
import '../../../services/notification_service.dart';
import '../models/milk_entry.dart';
import 'milk_entry_repository.dart';

class MilkEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _entries => _firestore.collection('milk_entries');

  /// Creates a milk collection entry and notifies in-memory reactive state.
  Future<void> createEntry(MilkEntry entry) async {
    MilkEntryRepository.instance.addEntry(entry);
    try {
      await _entries.doc(entry.id).set({
        ...entry.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore createEntry cache/notice: $e');
    }
  }

  /// Performs a versioned, audited correction of a milk entry (PRD F5, LLD Section 2.1).
  /// Generates an immutable record in `milk_entries/{id}/edits/{version}` and
  /// dispatches an in-app alert to the affected farmer.
  Future<void> editEntry({
    required String entryId,
    required MilkEntry updatedEntry,
    required String reason,
    required String editorId,
  }) async {
    int currentVersion = 1;
    Map<String, dynamic> oldValues = {};

    try {
      final snap = await _entries.doc(entryId).get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        currentVersion = (data['version'] as int?) ?? 1;
        oldValues = {
          'quantityLitres': data['quantityLitres'],
          'fatPercentage': data['fatPercentage'],
          'snfPercentage': data['snfPercentage'],
          'ratePerLitre': data['ratePerLitre'],
          'totalAmount': data['totalAmount'],
        };
      }
    } catch (e) {
      debugPrint('Fetch entry for edit warning: $e');
    }

    final nextVersion = currentVersion + 1;
    final batch = _firestore.batch();
    final docRef = _entries.doc(entryId);

    // Update main entry document
    batch.update(docRef, {
      ...updatedEntry.toMap(),
      'version': nextVersion,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': editorId,
    });

    // Write immutable edit audit log subcollection
    final editLogRef = docRef.collection('edits').doc('$nextVersion');
    batch.set(editLogRef, {
      'versionFrom': currentVersion,
      'versionTo': nextVersion,
      'old': oldValues,
      'new': {
        'quantityLitres': updatedEntry.quantityLitres,
        'fatPercentage': updatedEntry.fatPercentage,
        'snfPercentage': updatedEntry.snfPercentage,
        'ratePerLitre': updatedEntry.ratePerLitre,
        'totalAmount': updatedEntry.totalAmount,
      },
      'reason': reason.trim(),
      'editedBy': editorId,
      'editedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore editEntry batch notice: $e');
    }

    // Update in-memory reactive state
    MilkEntryRepository.instance.updateEntry(updatedEntry);

    // Send in-app notification to the farmer (PRD F5, F9)
    await NotificationService.instance.sendNotification(
      userId: updatedEntry.farmerId,
      type: NotificationType.entryCorrected,
      title: 'Collection Reading Audited',
      body: 'Entry of ${updatedEntry.shift} was audited: $reason. '
          'Updated to ${updatedEntry.quantityLitres} L @ ${updatedEntry.fatPercentage}% Fat.',
      referenceId: entryId,
    );
  }

  /// Retrieve the audit edit history for a specific collection entry.
  Future<List<Map<String, dynamic>>> getEntryAuditEdits(String entryId) async {
    try {
      final snap = await _entries
          .doc(entryId)
          .collection('edits')
          .orderBy('versionTo', descending: true)
          .get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Fetch audit edits notice: $e');
      return [];
    }
  }

  Future<List<MilkEntry>> getEntriesForFarmer(String farmerId) async {
    try {
      final snapshot = await _entries
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map(
              (doc) => MilkEntry.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Firestore getEntriesForFarmer notice: $e');
    }
    return MilkEntryRepository.instance.getEntriesForFarmer(farmerId);
  }

  Future<List<MilkEntry>> getEntriesForCenter(String centerId) async {
    try {
      final snapshot = await _entries
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map(
              (doc) => MilkEntry.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Firestore getEntriesForCenter notice: $e');
    }
    return MilkEntryRepository.instance.entries;
  }

  /// Get accepted collections that are ready to be packaged into a batch.
  Future<List<MilkEntry>> getUnbatchedEntries(String centerId) async {
    try {
      final snapshot = await _entries
          .where('qualityStatus', isEqualTo: 'ACCEPTED')
          .get();

      if (snapshot.docs.isNotEmpty) {
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
    } catch (e) {
      debugPrint('Firestore getUnbatchedEntries notice: $e');
    }
    return MilkEntryRepository.instance.entries
        .where((e) => e.qualityStatus == 'ACCEPTED' && (e.batchId == null || e.batchId!.isEmpty))
        .toList();
  }

  /// Assign a list of milk collections to a batch.
  Future<void> assignEntriesToBatch(String batchId, List<String> entryIds) async {
    try {
      final batch = _firestore.batch();
      for (final entryId in entryIds) {
        batch.update(_entries.doc(entryId), {'batchId': batchId});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore assignEntriesToBatch notice: $e');
    }
  }

  /// Traceability: Retrieve all collections that contributed to a specific batch.
  Future<List<MilkEntry>> getEntriesByBatchId(String batchId) async {
    try {
      final snapshot = await _entries
          .where('batchId', isEqualTo: batchId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map(
              (doc) => MilkEntry.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Firestore getEntriesByBatchId notice: $e');
    }
    return MilkEntryRepository.instance.entries
        .where((e) => e.batchId == batchId)
        .toList();
  }

  /// Get daily collections filtered by date and optional shift.
  Future<List<MilkEntry>> getDailyCollections({
    required DateTime date,
    String? shift,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      Query query = _entries
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay);

      if (shift != null) {
        query = query.where('shift', isEqualTo: shift);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map(
              (doc) => MilkEntry.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Firestore getDailyCollections notice: $e');
    }

    return MilkEntryRepository.instance.entries.where((e) {
      final isSameDay = e.date.year == date.year && e.date.month == date.month && e.date.day == date.day;
      if (!isSameDay) return false;
      if (shift == null) return true;
      return e.shift.toLowerCase().contains(shift.toLowerCase());
    }).toList();
  }

  // Dashboard Aggregations for today
  Future<Map<String, dynamic>> getTodayDashboardStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snapshot = await _entries
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .get();

      if (snapshot.docs.isNotEmpty) {
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
    } catch (e) {
      debugPrint('Firestore getTodayDashboardStats notice: $e');
    }

    return {
      'todayTotalLitres': MilkEntryRepository.instance.todayTotalLitres,
      'activeFarmersCount': MilkEntryRepository.instance.activeFarmersCount,
      'todayPayout': MilkEntryRepository.instance.todayPayout,
      'totalEntriesCount': MilkEntryRepository.instance.totalEntriesCount,
    };
  }
}
