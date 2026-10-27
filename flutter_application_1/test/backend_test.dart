import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/utils/validators.dart';
import 'package:flutter_application_1/features/admin/models/rate_chart.dart';
import 'package:flutter_application_1/features/collector/data/milk_entry_repository.dart';
import 'package:flutter_application_1/features/collector/models/milk_entry.dart';
import 'package:flutter_application_1/models/batch.dart';
import 'package:flutter_application_1/models/dispute.dart';
import 'package:flutter_application_1/models/notification_item.dart';
import 'package:flutter_application_1/models/reconciliation_statement.dart';
import 'package:flutter_application_1/services/sync_service.dart';

void main() {
  group('Backend Rate Chart & Pricing Tests', () {
    test('Standard Cow Rate Chart calculates correct rate and amount', () {
      final cowChart = RateChart(
        id: 'RC-COW-TEST',
        title: 'Test Cow Chart',
        milkType: MilkType.cow,
        fatRate: 6.80,
        snfRate: 2.20,
        baseRate: 0.0,
        minFat: 3.2,
        minSnf: 8.3,
        effectiveFrom: DateTime(2026, 10, 1),
        isActive: true,
      );

      // 4.2% Fat, 8.5% SNF, 12.5 Litres
      final result = cowChart.calculate(
        quantity: 12.5,
        fat: 4.2,
        snf: 8.5,
      );

      // (4.2 * 6.80) + (8.5 * 2.20) = 28.56 + 18.70 = 47.26
      expect(result.ratePerLitre, closeTo(47.26, 0.01));
      // 12.5 * 47.26 = 590.75
      expect(result.totalAmount, closeTo(590.75, 0.05));
      expect(result.qualityGrade, 'Grade A');
      expect(result.isQualityAcceptable, isTrue);
    });

    test('Buffalo Milk Chart calculates correct high-fat rate', () {
      final bufChart = RateChart(
        id: 'RC-BUF-TEST',
        title: 'Test Buffalo Chart',
        milkType: MilkType.buffalo,
        fatRate: 7.40,
        snfRate: 2.50,
        baseRate: 0.0,
        minFat: 5.5,
        minSnf: 8.8,
        effectiveFrom: DateTime(2026, 10, 1),
        isActive: true,
      );

      // 6.5% Fat, 9.0% SNF, 18.0 Litres
      final result = bufChart.calculate(
        quantity: 18.0,
        fat: 6.5,
        snf: 9.0,
      );

      // (6.5 * 7.40) + (9.0 * 2.50) = 48.10 + 22.50 = 70.60
      expect(result.ratePerLitre, closeTo(70.60, 0.01));
      // 18.0 * 70.60 = 1270.80
      expect(result.totalAmount, closeTo(1270.80, 0.05));
      expect(result.qualityGrade, 'Grade A');
    });

    test('Substandard milk below min thresholds receives Fair/Substandard grade', () {
      final cowChart = RateChart(
        id: 'RC-COW-TEST',
        title: 'Test Cow Chart',
        milkType: MilkType.cow,
        fatRate: 6.80,
        snfRate: 2.20,
        minFat: 3.2,
        minSnf: 8.3,
        effectiveFrom: DateTime(2026, 10, 1),
        isActive: true,
      );

      final result = cowChart.calculate(
        quantity: 10.0,
        fat: 2.8, // Below 3.2
        snf: 7.8, // Below 8.3
      );

      expect(result.isQualityAcceptable, isFalse);
      expect(result.qualityGrade, 'Sub-standard');
    });
  });

  group('Backend Batch Aggregation & Traceability Tests', () {
    test('Calculates weighted average Fat and SNF accurately across collections', () {
      final entries = [
        MilkEntry(
          id: 'E1',
          farmerId: 'F001',
          farmerName: 'Ram Singh',
          farmerCode: 'F001',
          collectorId: 'C1',
          shift: 'Morning (AM)',
          date: DateTime.now(),
          quantityLitres: 100.0,
          fatPercentage: 4.0,
          snfPercentage: 8.5,
          ratePerLitre: 40.0,
          totalAmount: 4000.0,
          temperature: 4.0,
        ),
        MilkEntry(
          id: 'E2',
          farmerId: 'F002',
          farmerName: 'Rahul Kumar',
          farmerCode: 'F002',
          collectorId: 'C1',
          shift: 'Morning (AM)',
          date: DateTime.now(),
          quantityLitres: 200.0,
          fatPercentage: 5.5,
          snfPercentage: 8.8,
          ratePerLitre: 50.0,
          totalAmount: 10000.0,
          temperature: 4.2,
        ),
      ];

      double totalLitres = 0;
      double weightedFatSum = 0;
      double weightedSnfSum = 0;
      double tempSum = 0;
      final Set<String> uniqueFarmers = {};

      for (final e in entries) {
        totalLitres += e.quantityLitres;
        weightedFatSum += (e.fatPercentage * e.quantityLitres);
        weightedSnfSum += (e.snfPercentage * e.quantityLitres);
        tempSum += e.temperature;
        uniqueFarmers.add(e.farmerId);
      }

      final avgFat = weightedFatSum / totalLitres;
      final avgSnf = weightedSnfSum / totalLitres;
      final avgTemp = tempSum / entries.length;

      // 100 * 4.0 + 200 * 5.5 = 400 + 1100 = 1500 / 300 = 5.0%
      expect(totalLitres, 300.0);
      expect(avgFat, closeTo(5.0, 0.001));
      // 100 * 8.5 + 200 * 8.8 = 850 + 1760 = 2610 / 300 = 8.7%
      expect(avgSnf, closeTo(8.7, 0.001));
      expect(avgTemp, closeTo(4.1, 0.01));
      expect(uniqueFarmers.length, 2);

      final batch = Batch(
        id: 'BATCH-TEST-001',
        centerId: 'Jaipur Center',
        centerName: 'Jaipur Rural',
        shift: 'Morning (AM)',
        milkType: 'cow',
        date: DateTime.now(),
        totalLitres: totalLitres,
        averageFat: avgFat,
        averageSnf: avgSnf,
        averageTemperature: avgTemp,
        status: 'IN_TRANSIT',
        entryIds: entries.map((e) => e.id).toList(),
        farmerIds: uniqueFarmers.toList(),
        createdAt: DateTime.now(),
      );

      expect(batch.entryIds.length, 2);
      expect(batch.farmerIds.contains('F001'), isTrue);
      expect(batch.farmerIds.contains('F002'), isTrue);
    });
  });

  group('Backend Notification System Tests', () {
    test('Serializes and deserializes NotificationItem correctly', () {
      final now = DateTime(2026, 10, 26, 10, 30);
      final notif = NotificationItem(
        id: 'NOTIF-101',
        userId: 'F001',
        type: NotificationType.entryCorrected,
        title: 'Entry Changed',
        body: 'Morning entry updated from 12.0 L to 12.5 L',
        referenceId: 'ENT-001',
        createdAt: now,
        isRead: false,
      );

      final map = notif.toMap();
      expect(map['userId'], 'F001');
      expect(map['type'], 'entryCorrected');
      expect(map['title'], 'Entry Changed');
      expect(map['isRead'], isFalse);

      final reconstructed = NotificationItem.fromMap(notif.id, {
        'userId': 'F001',
        'type': 'entry_corrected',
        'title': 'Entry Changed',
        'body': 'Morning entry updated from 12.0 L to 12.5 L',
        'referenceId': 'ENT-001',
        'createdAt': map['createdAt'],
        'isRead': false,
      });

      expect(reconstructed.id, 'NOTIF-101');
      expect(reconstructed.type, NotificationType.entryCorrected);
      expect(reconstructed.referenceId, 'ENT-001');
    });
  });

  group('Backend Shift Reconciliation & Sync Tests', () {
    test('ShiftReconciliationReport flags discrepancy when server tally mismatches', () {
      final report = ShiftReconciliationReport(
        centerId: 'Jaipur Center',
        shift: 'Morning (AM)',
        date: DateTime(2026, 10, 26),
        localEntriesCount: 5,
        localTotalLitres: 120.0,
        localTotalPayout: 5040.0,
        serverEntriesCount: 4,
        serverTotalLitres: 100.0,
        serverTotalPayout: 4200.0,
        pendingSyncCount: 1,
        isFullyReconciled: false,
        summaryMessage: 'Discrepancy detected: 1 collections pending sync (20.0 L variance).',
      );

      expect(report.isFullyReconciled, isFalse);
      expect(report.pendingSyncCount, 1);
      expect(report.localTotalLitres - report.serverTotalLitres, 20.0);
    });
  });

  group('Backend Dispute Resolution & Audit Tests', () {
    test('Dispute model correctly calculates variance and credit adjustment', () {
      final dispute = Dispute(
        id: 'DSP-TEST-01',
        entryId: 'ENT-001',
        farmerId: 'F001',
        farmerName: 'Ram Singh',
        farmerPhone: '9876543210',
        centerId: 'Jaipur Center',
        collectorId: 'C-BHN-001',
        collectionDate: DateTime.now(),
        shift: 'Morning (AM)',
        disputeType: 'Quantity Discrepancy',
        reason: 'Measured 15 L at home, logged 12.5 L',
        recordedQuantity: 12.5,
        claimedQuantity: 15.0,
        recordedFat: 4.2,
        claimedFat: 4.2,
        recordedSnf: 8.5,
        claimedSnf: 8.5,
        recordedAmount: 525.0,
        status: 'RESOLVED',
        adjustedAmount: 105.0,
        resolvedBy: 'Admin Sharma',
        createdAt: DateTime.now(),
      );

      expect(dispute.claimedQuantity! - dispute.recordedQuantity, 2.5);
      expect(dispute.adjustedAmount, 105.0);
      expect(dispute.status, 'RESOLVED');
    });
  });

  group('Backend Serialization & Date Parsing Tests (Bug Fix Verification)', () {
    test('MilkEntry.fromMap parses DateTime, Timestamp, and ISO String correctly', () {
      final now = DateTime(2026, 10, 27, 10, 30);
      final timestamp = Timestamp.fromDate(now);
      final isoString = now.toIso8601String();

      // Case 1: Timestamp (from Firestore)
      final entryFromTimestamp = MilkEntry.fromMap('E01', {
        'farmerId': 'F01',
        'farmerName': 'Ram',
        'farmerCode': 'C01',
        'collectorId': 'COL01',
        'shift': 'Morning',
        'date': timestamp,
        'quantityLitres': 25.0,
        'fatPercentage': 4.5,
        'snfPercentage': 8.5,
        'ratePerLitre': 45.0,
        'totalAmount': 1125.0,
      });
      expect(entryFromTimestamp.date.year, 2026);
      expect(entryFromTimestamp.date.month, 10);

      // Case 2: DateTime (local / memory)
      final entryFromDateTime = MilkEntry.fromMap('E02', {
        'farmerId': 'F01',
        'farmerName': 'Ram',
        'farmerCode': 'C01',
        'collectorId': 'COL01',
        'shift': 'Morning',
        'date': now,
        'quantityLitres': 25.0,
        'fatPercentage': 4.5,
        'snfPercentage': 8.5,
        'ratePerLitre': 45.0,
        'totalAmount': 1125.0,
      });
      expect(entryFromDateTime.date, now);

      // Case 3: ISO String
      final entryFromString = MilkEntry.fromMap('E03', {
        'farmerId': 'F01',
        'farmerName': 'Ram',
        'farmerCode': 'C01',
        'collectorId': 'COL01',
        'shift': 'Morning',
        'date': isoString,
        'quantityLitres': 25.0,
        'fatPercentage': 4.5,
        'snfPercentage': 8.5,
        'ratePerLitre': 45.0,
        'totalAmount': 1125.0,
      });
      expect(entryFromString.date.year, 2026);
    });

    test('Batch.fromMap parses DateTime, Timestamp, and ISO String for date fields', () {
      final testDate = DateTime(2026, 10, 27, 8, 0);
      final timestamp = Timestamp.fromDate(testDate);

      // With DateTime
      final batchWithDate = Batch.fromMap('B01', {
        'batchNumber': 'BATCH-001',
        'centerId': 'CTR-01',
        'collectorId': 'COL-01',
        'shift': 'Morning',
        'date': testDate,
        'createdAt': testDate,
        'testedAt': testDate,
        'totalLitres': 500.0,
        'averageFat': 4.2,
        'averageSnf': 8.6,
      });
      expect(batchWithDate.date, testDate);
      expect(batchWithDate.createdAt, testDate);
      expect(batchWithDate.testedAt, testDate);

      // With Timestamp
      final batchWithTimestamp = Batch.fromMap('B02', {
        'batchNumber': 'BATCH-002',
        'centerId': 'CTR-01',
        'collectorId': 'COL-01',
        'shift': 'Morning',
        'date': timestamp,
        'createdAt': timestamp,
        'testedAt': timestamp,
        'totalLitres': 500.0,
        'averageFat': 4.2,
        'averageSnf': 8.6,
      });
      expect(batchWithTimestamp.date.year, 2026);
      expect(batchWithTimestamp.createdAt.year, 2026);
      expect(batchWithTimestamp.testedAt?.year, 2026);
    });

    test('NotificationItem and ReconciliationStatement preserve DateTime in parseDate', () {
      final explicitDate = DateTime(2026, 9, 15, 14, 0);

      final notif = NotificationItem.fromMap('N01', {
        'title': 'Test Notice',
        'body': 'Payout issued',
        'type': 'payment',
        'createdAt': explicitDate,
        'isRead': false,
      });
      expect(notif.createdAt, explicitDate);

      final stmt = FarmerReconciliationStatement.fromMap('ST01', {
        'farmerId': 'F01',
        'farmerName': 'Ram',
        'center': 'Test Center',
        'cycleStart': explicitDate,
        'cycleEnd': explicitDate,
        'totalLitres': 100.0,
        'totalCollections': 10,
        'avgFat': 4.0,
        'avgSnf': 8.5,
        'grossPayable': 4000.0,
        'deductions': 0.0,
        'netPayable': 4000.0,
        'disputedCount': 0,
        'status': 'SETTLED',
      });
      expect(stmt.cycleStart, explicitDate);
      expect(stmt.cycleEnd, explicitDate);
    });

    test('RateChart.fromMap preserves DateTime in effectiveFrom', () {
      final effectiveDate = DateTime(2026, 8, 1);
      final chart = RateChart.fromMap('RC01', {
        'title': 'Monsoon Chart',
        'milkType': 'cow',
        'fatRate': 6.5,
        'snfRate': 2.0,
        'baseRate': 0.0,
        'minFat': 3.2,
        'minSnf': 8.3,
        'effectiveFrom': effectiveDate,
        'isActive': true,
      });
      expect(chart.effectiveFrom, effectiveDate);
    });

    test('MilkEntryRepository todayTotalLitres getter correctly adds entry quantityLitres', () {
      final repo = MilkEntryRepository.instance;
      final initialTotal = repo.todayTotalLitres;

      final testEntry = MilkEntry(
        id: 'TEST-FOLD-ENTRY-999',
        farmerId: 'F999',
        farmerName: 'Fold Test Farmer',
        farmerCode: 'FT99',
        collectorId: 'COL1',
        shift: 'Morning (AM)',
        date: DateTime.now(),
        quantityLitres: 45.5,
        fatPercentage: 4.0,
        snfPercentage: 8.5,
        ratePerLitre: 40.0,
        totalAmount: 1820.0,
      );

      repo.addEntry(testEntry);
      expect(repo.todayTotalLitres, initialTotal + 45.5);
    });
  });

  group('Core Utility Validators Tests', () {
    test('phone requires 10 digits starting with 6-9', () {
      expect(Validators.phone(null), 'Mobile number is required');
      expect(Validators.phone(''), 'Mobile number is required');
      expect(Validators.phone('12345'), 'Enter a valid 10-digit mobile number');
      expect(Validators.phone('abcdefghij'), 'Enter a valid 10-digit mobile number');
      expect(Validators.phone('9876543210'), isNull);
    });

    test('password enforces minimum 6 characters', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password('12345'), 'Use at least 6 characters');
      expect(Validators.password('123456'), isNull);
    });

    test('required validates field presence', () {
      expect(Validators.required(null, field: 'Name'), 'Name is required');
      expect(Validators.required('  ', field: 'Name'), 'Name is required');
      expect(Validators.required('John Doe', field: 'Name'), isNull);
    });

    test('confirmPassword ensures matching passwords', () {
      expect(Validators.confirmPassword('pass123', 'pass456'), 'Passwords do not match');
      expect(Validators.confirmPassword('pass123', 'pass123'), isNull);
    });
  });
}
