import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../features/admin/models/rate_chart.dart';
import '../features/collector/models/milk_entry.dart';
import '../features/farmers/models/farmer.dart';
import '../models/batch.dart';
import '../models/dispute.dart';
import '../models/notification_item.dart';

/// Database seeding and fixture initialization utility for Farm2Factory backend.
/// Automatically provisions collections in Cloud Firestore or Emulator for rapid testing.
class DatabaseSeeder {
  final FirebaseFirestore _firestore;

  DatabaseSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Executes complete database seeding across all 8 collections.
  Future<Map<String, int>> seedAll() async {
    debugPrint('=== Starting Farm2Factory Full Database Seeding ===');

    final seededCounts = <String, int>{};

    try {
      seededCounts['rate_charts'] = await seedRateCharts();
      seededCounts['users'] = await seedUsers();
      seededCounts['farmers'] = await seedFarmers();
      seededCounts['milk_entries'] = await seedMilkEntries();
      seededCounts['batches'] = await seedBatches();
      seededCounts['disputes'] = await seedDisputes();
      seededCounts['payouts'] = await seedPayouts();
      seededCounts['notifications'] = await seedNotifications();

      debugPrint('=== Seeding Complete: $seededCounts ===');
    } catch (e) {
      debugPrint('Seeding error encountered: $e');
    }

    return seededCounts;
  }

  /// 1. Rate Charts
  Future<int> seedRateCharts() async {
    final charts = [
      RateChart(
        id: 'RC-COW-2026-OCT',
        title: 'Standard Cow Milk Chart (Autumn 2026)',
        milkType: MilkType.cow,
        fatRate: 6.80,
        snfRate: 2.20,
        baseRate: 0.0,
        minFat: 3.2,
        minSnf: 8.3,
        effectiveFrom: DateTime(2026, 10, 1),
        isActive: true,
      ),
      RateChart(
        id: 'RC-BUF-2026-OCT',
        title: 'High-Fat Buffalo Milk Chart (Autumn 2026)',
        milkType: MilkType.buffalo,
        fatRate: 7.40,
        snfRate: 2.50,
        baseRate: 0.0,
        minFat: 5.5,
        minSnf: 8.8,
        effectiveFrom: DateTime(2026, 10, 1),
        isActive: true,
      ),
    ];

    for (final c in charts) {
      await _firestore.collection('rate_charts').doc(c.id).set(c.toMap());
    }
    return charts.length;
  }

  /// 2. Users Profiles
  Future<int> seedUsers() async {
    final users = [
      {
        'uid': 'ADM-001',
        'name': 'Dairy Plant Admin',
        'email': 'dairyadmin@dairycoop.in',
        'role': 'admin',
        'phone': '9999999999',
        'center': 'Jaipur Cooperative Dairy Plant',
        'dairyId': 'dairy1',
      },
      {
        'uid': 'C-BHN-001',
        'name': 'Ramesh Kumar',
        'email': 'ramesh.collector@dairycoop.in',
        'role': 'collector',
        'phone': '8888888888',
        'center': 'Jaipur Center',
        'customId': 'C-BHN-001',
        'dairyId': 'dairy1',
      },
      {
        'uid': 'F001',
        'name': 'Ram Singh',
        'email': 'ramsingh@dairycoop.in',
        'role': 'farmer',
        'phone': '9876543210',
        'center': 'Jaipur Center',
        'customId': 'F001',
        'dairyId': 'dairy1',
      },
      {
        'uid': 'F002',
        'name': 'Rahul Kumar',
        'email': 'rahulkumar@dairycoop.in',
        'role': 'farmer',
        'phone': '9123456780',
        'center': 'Ajmer Center',
        'customId': 'F002',
        'dairyId': 'dairy1',
      },
    ];

    for (final u in users) {
      final docId = u['uid'] as String;
      await _firestore.collection('users').doc(docId).set({
        ...u,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return users.length;
  }

  /// 3. Farmers
  Future<int> seedFarmers() async {
    final farmers = [
      const Farmer(
        id: 'F001',
        name: 'Ram Singh',
        phone: '9876543210',
        village: 'Jaipur Rural',
        center: 'Jaipur Center',
        collectorId: 'C-BHN-001',
      ),
      const Farmer(
        id: 'F002',
        name: 'Rahul Kumar',
        phone: '9123456780',
        village: 'Ajmer Village',
        center: 'Ajmer Center',
        collectorId: 'C-BHN-001',
      ),
      const Farmer(
        id: 'F003',
        name: 'Sita Devi',
        phone: '9988776655',
        village: 'Sikar Center',
        center: 'Sikar Center',
        collectorId: 'C-BHN-001',
      ),
    ];

    for (final f in farmers) {
      await _firestore.collection('farmers').doc(f.id).set({
        ...f.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return farmers.length;
  }

  /// 4. Milk Entries & Edits
  Future<int> seedMilkEntries() async {
    final now = DateTime.now();
    final entries = [
      MilkEntry(
        id: 'ENT-001',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerCode: 'F001',
        collectorId: 'C-BHN-001',
        centerId: 'Jaipur Center',
        shift: 'Morning (AM)',
        date: now.subtract(const Duration(days: 1)),
        milkType: 'cow',
        quantityLitres: 12.5,
        fatPercentage: 4.2,
        snfPercentage: 8.5,
        temperature: 4.0,
        qualityStatus: 'ACCEPTED',
        qualityGrade: 'Premium',
        ratePerLitre: 42.0,
        totalAmount: 525.0,
        batchId: 'BATCH-JaipurCenter-20261025-AM',
      ),
      MilkEntry(
        id: 'ENT-002',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerCode: 'F001',
        collectorId: 'C-BHN-001',
        centerId: 'Jaipur Center',
        shift: 'Evening (PM)',
        date: now.subtract(const Duration(days: 1)),
        milkType: 'cow',
        quantityLitres: 11.0,
        fatPercentage: 4.0,
        snfPercentage: 8.4,
        temperature: 4.2,
        qualityStatus: 'ACCEPTED',
        qualityGrade: 'Good',
        ratePerLitre: 40.5,
        totalAmount: 445.5,
        batchId: 'BATCH-JaipurCenter-20261025-AM',
      ),
      MilkEntry(
        id: 'ENT-003',
        farmerId: 'F002',
        farmerName: 'Rahul Kumar',
        farmerCode: 'F002',
        collectorId: 'C-BHN-001',
        centerId: 'Ajmer Center',
        shift: 'Morning (AM)',
        date: now.subtract(const Duration(days: 1)),
        milkType: 'buffalo',
        quantityLitres: 18.0,
        fatPercentage: 6.5,
        snfPercentage: 9.0,
        temperature: 4.1,
        qualityStatus: 'ACCEPTED',
        qualityGrade: 'Premium',
        ratePerLitre: 52.0,
        totalAmount: 936.0,
        batchId: 'BATCH-JaipurCenter-20261025-AM',
      ),
      MilkEntry(
        id: 'ENT-004',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerCode: 'F001',
        collectorId: 'C-BHN-001',
        centerId: 'Jaipur Center',
        shift: 'Morning (AM)',
        date: now,
        milkType: 'cow',
        quantityLitres: 13.0,
        fatPercentage: 4.3,
        snfPercentage: 8.5,
        temperature: 3.9,
        qualityStatus: 'ACCEPTED',
        qualityGrade: 'Premium',
        ratePerLitre: 42.5,
        totalAmount: 552.5,
      ),
    ];

    for (final e in entries) {
      await _firestore.collection('milk_entries').doc(e.id).set({
        ...e.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Seed an audit edit on ENT-001 to demonstrate immutable history subcollection
    await _firestore
        .collection('milk_entries')
        .doc('ENT-001')
        .collection('edits')
        .doc('2')
        .set({
      'versionFrom': 1,
      'versionTo': 2,
      'old': {'quantityLitres': 12.0, 'fatPercentage': 4.1, 'totalAmount': 492.0},
      'new': {'quantityLitres': 12.5, 'fatPercentage': 4.2, 'totalAmount': 525.0},
      'reason': 'Lactometer recalibration after shift start check',
      'editedBy': 'C-BHN-001',
      'editedAt': FieldValue.serverTimestamp(),
    });

    return entries.length;
  }

  /// 5. Batches
  Future<int> seedBatches() async {
    final now = DateTime.now();
    final batches = [
      Batch(
        id: 'BATCH-JaipurCenter-20261025-AM',
        centerId: 'Jaipur Center',
        centerName: 'Jaipur Rural Center',
        shift: 'Morning (AM)',
        milkType: 'cow',
        date: now.subtract(const Duration(days: 1)),
        totalLitres: 1248.0,
        averageFat: 4.25,
        averageSnf: 8.52,
        averageTemperature: 4.1,
        status: 'IN_TRANSIT',
        tankerNumber: 'RJ-14-GA-4501',
        driverName: 'Suresh Yadav',
        entryIds: ['ENT-001', 'ENT-002', 'ENT-003'],
        farmerIds: ['F001', 'F002'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Batch(
        id: 'BATCH-JaipurCenter-20261024-PM',
        centerId: 'Jaipur Center',
        centerName: 'Jaipur Rural Center',
        shift: 'Evening (PM)',
        milkType: 'cow',
        date: now.subtract(const Duration(days: 2)),
        totalLitres: 1180.0,
        averageFat: 4.18,
        averageSnf: 8.48,
        averageTemperature: 4.0,
        status: 'ACCEPTED',
        tankerNumber: 'RJ-14-GA-3320',
        driverName: 'Mohit Verma',
        entryIds: [],
        farmerIds: ['F001'],
        createdAt: now.subtract(const Duration(days: 2)),
        testedAt: now.subtract(const Duration(days: 2)),
        testedBy: 'QC Lab Inspector Verma',
      ),
    ];

    for (final b in batches) {
      await _firestore.collection('batches').doc(b.id).set({
        ...b.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return batches.length;
  }

  /// 6. Disputes
  Future<int> seedDisputes() async {
    final now = DateTime.now();
    final disputes = [
      Dispute(
        id: 'DSP-20261023-001',
        entryId: 'ENT-OLD-01',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerPhone: '9876543210',
        centerId: 'Jaipur Center',
        collectorId: 'C-BHN-001',
        collectionDate: now.subtract(const Duration(days: 3)),
        shift: 'Morning (AM)',
        disputeType: 'Fat Percentage Discrepancy',
        reason: 'Milk analyzer showed 4.5% during sample reading but slip showed 4.1%',
        recordedQuantity: 15.0,
        claimedQuantity: 15.0,
        recordedFat: 4.1,
        claimedFat: 4.5,
        recordedSnf: 8.5,
        claimedSnf: 8.5,
        recordedAmount: 615.0,
        status: 'RESOLVED',
        resolutionNote: 'Sample re-test verified 4.45% Fat. Difference of ₹126.00 credited to payout.',
        adjustedAmount: 126.0,
        resolvedBy: 'Dairy QC Manager Sharma',
        createdAt: now.subtract(const Duration(days: 3)),
        resolvedAt: now.subtract(const Duration(days: 2)),
      ),
      Dispute(
        id: 'DSP-20261025-002',
        entryId: 'ENT-004',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerPhone: '9876543210',
        centerId: 'Jaipur Center',
        collectorId: 'C-BHN-001',
        collectionDate: now,
        shift: 'Morning (AM)',
        disputeType: 'Quantity Discrepancy',
        reason: 'Poured 15 litres measured at home can, recorded 13 litres at center',
        recordedQuantity: 13.0,
        claimedQuantity: 15.0,
        recordedFat: 4.3,
        claimedFat: 4.3,
        recordedSnf: 8.5,
        claimedSnf: 8.5,
        recordedAmount: 552.5,
        status: 'OPEN',
        createdAt: now,
      ),
    ];

    for (final d in disputes) {
      await _firestore.collection('disputes').doc(d.id).set({
        ...d.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return disputes.length;
  }

  /// 7. Payout Statements
  Future<int> seedPayouts() async {
    final payouts = [
      {
        'statementId': 'REC-202610-C1-F001',
        'farmerId': 'F001',
        'farmerName': 'Ram Singh',
        'billingCycle': '01-10 Oct 2026',
        'totalLitres': 245.5,
        'averageFat': 4.22,
        'averageSnf': 8.51,
        'grossAmount': 10311.0,
        'qualityIncentive': 250.0,
        'disputeAdjustment': 0.0,
        'netPayable': 10561.0,
        'status': 'PAID',
        'paidAt': '2026-10-12',
        'paymentMethod': 'Bank NEFT/RTGS',
        'transactionReference': 'NEFT-SBI-98421045',
      },
      {
        'statementId': 'REC-202610-C2-F001',
        'farmerId': 'F001',
        'farmerName': 'Ram Singh',
        'billingCycle': '11-20 Oct 2026',
        'totalLitres': 210.0,
        'averageFat': 4.15,
        'averageSnf': 8.48,
        'grossAmount': 8550.0,
        'qualityIncentive': 0.0,
        'disputeAdjustment': 126.0,
        'netPayable': 8676.0,
        'status': 'PAID',
        'paidAt': '2026-10-22',
        'paymentMethod': 'Bank NEFT/RTGS',
        'transactionReference': 'NEFT-SBI-99120488',
      },
    ];

    for (final p in payouts) {
      final docId = p['statementId'] as String;
      await _firestore.collection('payouts').doc(docId).set({
        ...p,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return payouts.length;
  }

  /// 8. In-App Notifications
  Future<int> seedNotifications() async {
    final notifications = [
      NotificationItem(
        id: 'NOTIF-001',
        userId: 'F001',
        type: NotificationType.disputeUpdate,
        title: 'Dispute Approved & Adjusted',
        body: 'Your contest on 22 Oct reading was resolved. Credit adjustment of ₹126.00 added.',
        referenceId: 'DSP-20261023-001',
        createdAt: DateTime(2026, 10, 24, 16, 45),
        isRead: false,
      ),
      NotificationItem(
        id: 'NOTIF-002',
        userId: 'F001',
        type: NotificationType.payoutReady,
        title: 'Payment Statement Ready',
        body: 'Reconciliation statement for 11-20 Oct (₹8,676.00) has been paid via NEFT.',
        referenceId: 'REC-202610-C2-F001',
        createdAt: DateTime(2026, 10, 22, 11, 0),
        isRead: true,
      ),
    ];

    for (final n in notifications) {
      await _firestore
          .collection('users')
          .doc(n.userId)
          .collection('notifications')
          .doc(n.id)
          .set({
        ...n.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return notifications.length;
  }
}
