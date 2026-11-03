import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../collector/models/milk_entry.dart';
import '../models/collector.dart';

class CollectorRepository extends ChangeNotifier {
  CollectorRepository._() {
    _initMockCollectors();
    _startLiveSubscription();
  }

  static final CollectorRepository instance = CollectorRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _usersSubscription;
  StreamSubscription? _entriesSubscription;

  final List<Collector> _collectors = [];
  bool _isLoading = false;

  List<Collector> get collectors => List.unmodifiable(_collectors);
  bool get isLoading => _isLoading;

  /// Manually trigger a refresh of collector profiles and live milk stats from Firestore.
  Future<void> fetchLiveCollectors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'collector')
          .get();

      for (final doc in userSnap.docs) {
        final data = doc.data();
        final id = (data['customId'] as String?) ?? doc.id;
        final name = (data['name'] as String?) ?? 'Collector';
        final phone = (data['phone'] as String?) ?? '';
        final email = (data['email'] as String?) ?? '$phone@dairycoop.in';
        final center = (data['center'] as String?) ?? 'Jaipur Center';
        final location = (data['location'] as String?) ?? center;

        final existingIndex = _collectors.indexWhere((c) => c.id == id || c.phone == phone);
        if (existingIndex == -1) {
          _collectors.add(
            Collector(
              id: id,
              name: name,
              phone: phone,
              email: email,
              center: center,
              location: location,
              joiningDate: DateTime.now(),
              status: 'Active',
              lastActiveTime: 'Just now',
              farmersHandled: 0,
              morningLitresToday: 0.0,
              eveningLitresToday: 0.0,
              paymentStatus: 'Paid',
              avgFat: 4.2,
              avgSnf: 8.5,
            ),
          );
        }
      }

      final entriesSnap = await _firestore.collection('milk_entries').get();
      final entries = entriesSnap.docs
          .map((doc) => MilkEntry.fromMap(doc.id, doc.data()))
          .toList();
      _syncCollectorStatsFromEntries(entries);
    } catch (_) {
      // Graceful offline fallback: baseline collectors remain intact
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCollector({
    required String id,
    required String name,
    required String phone,
    required String center,
    String? location,
    String? email,
  }) {
    final newCollector = Collector(
      id: id,
      name: name,
      phone: phone,
      email: email ?? '${name.toLowerCase().replaceAll(' ', '.')}@dairycoop.in',
      center: center,
      location: location ?? center,
      joiningDate: DateTime.now(),
      status: 'Active',
      lastActiveTime: 'Just now',
      farmersHandled: 0,
      morningLitresToday: 0.0,
      eveningLitresToday: 0.0,
      paymentStatus: 'Paid',
      avgFat: 4.2,
      avgSnf: 8.5,
    );

    _collectors.insert(0, newCollector);
    notifyListeners();

    // Asynchronously synchronize to Firestore users collection
    try {
      _firestore.collection('users').doc(id).set({
        'customId': id,
        'name': name,
        'phone': phone,
        'email': newCollector.email,
        'role': 'collector',
        'center': center,
        'location': newCollector.location,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Collector? getCollectorById(String id) {
    try {
      return _collectors.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _startLiveSubscription() {
    try {
      _usersSubscription = _firestore
          .collection('users')
          .where('role', isEqualTo: 'collector')
          .snapshots()
          .listen(
            (snapshot) {
              for (final doc in snapshot.docs) {
                final data = doc.data();
                final id = (data['customId'] as String?) ?? doc.id;
                final phone = (data['phone'] as String?) ?? '';
                final existingIdx = _collectors.indexWhere((c) => c.id == id || c.phone == phone);
                if (existingIdx == -1) {
                  _collectors.add(
                    Collector(
                      id: id,
                      name: (data['name'] as String?) ?? 'Collector',
                      phone: phone,
                      email: (data['email'] as String?) ?? '$phone@dairycoop.in',
                      center: (data['center'] as String?) ?? 'Jaipur Center',
                      location: (data['location'] as String?) ?? 'Jaipur Hub',
                      joiningDate: DateTime.now(),
                      status: 'Active',
                      lastActiveTime: 'Just now',
                      farmersHandled: 0,
                      morningLitresToday: 0.0,
                      eveningLitresToday: 0.0,
                      paymentStatus: 'Paid',
                    ),
                  );
                }
              }
              notifyListeners();
            },
            onError: (_) {},
          );

      _entriesSubscription = _firestore
          .collection('milk_entries')
          .snapshots()
          .listen(
            (snapshot) {
              final entries = snapshot.docs
                  .map((doc) => MilkEntry.fromMap(doc.id, doc.data()))
                  .toList();
              _syncCollectorStatsFromEntries(entries);
              notifyListeners();
            },
            onError: (_) {},
          );
    } catch (_) {}
  }

  void _syncCollectorStatsFromEntries(List<MilkEntry> entries) {
    if (entries.isEmpty) return;

    final now = DateTime.now();

    for (int i = 0; i < _collectors.length; i++) {
      final c = _collectors[i];
      // Match entries by collectorId or center
      final matching = entries.where((e) {
        if (e.collectorId == c.id) return true;
        final cleanCenter = c.center.toLowerCase().replaceAll(' center', '');
        return e.centerId.toLowerCase().contains(cleanCenter);
      }).toList();

      if (matching.isEmpty) continue;

      double morningLitres = 0;
      double eveningLitres = 0;
      double weightedFatSum = 0;
      double weightedSnfSum = 0;
      double totalMatchingLitres = 0;
      final Set<String> farmerIds = {};
      DateTime? latestEntryDate;

      for (final e in matching) {
        totalMatchingLitres += e.quantityLitres;
        weightedFatSum += (e.fatPercentage * e.quantityLitres);
        weightedSnfSum += (e.snfPercentage * e.quantityLitres);
        farmerIds.add(e.farmerId);

        final isMorning = e.shift.toLowerCase().contains('morning') || e.shift.contains('AM');
        if (isMorning) {
          morningLitres += e.quantityLitres;
        } else {
          eveningLitres += e.quantityLitres;
        }

        if (latestEntryDate == null || e.date.isAfter(latestEntryDate)) {
          latestEntryDate = e.date;
        }
      }

      final avgFat = totalMatchingLitres > 0
          ? double.parse((weightedFatSum / totalMatchingLitres).toStringAsFixed(2))
          : c.avgFat;
      final avgSnf = totalMatchingLitres > 0
          ? double.parse((weightedSnfSum / totalMatchingLitres).toStringAsFixed(2))
          : c.avgSnf;

      String status = c.status;
      String lastActive = c.lastActiveTime;

      if (latestEntryDate != null) {
        final diff = now.difference(latestEntryDate);
        if (diff.inHours < 2) {
          status = 'Collecting';
          lastActive = diff.inMinutes < 5 ? 'Just now' : '${diff.inMinutes} mins ago';
        } else if (diff.inHours < 12) {
          status = 'Active';
          lastActive = '${diff.inHours} hours ago';
        }
      }

      _collectors[i] = c.copyWith(
        morningLitresToday: morningLitres > 0 ? morningLitres : c.morningLitresToday,
        eveningLitresToday: eveningLitres > 0 ? eveningLitres : c.eveningLitresToday,
        farmersHandled: farmerIds.isNotEmpty ? farmerIds.length : c.farmersHandled,
        avgFat: avgFat,
        avgSnf: avgSnf,
        status: status,
        lastActiveTime: lastActive,
      );
    }
  }

  void _initMockCollectors() {
    final now = DateTime.now();

    // 10 Mock Payments helper
    List<CollectorPaymentTransaction> generatePayments(String collectorId, double baseAmount) {
      return List.generate(10, (index) {
        final date = now.subtract(Duration(days: (index + 1) * 3));
        return CollectorPaymentTransaction(
          id: 'PAY-$collectorId-${1000 + index}',
          date: date,
          period: 'Shift Cycle ${10 - index} (${date.day}/${date.month})',
          amount: baseAmount + (index * 420.0),
          method: index % 3 == 0 ? 'UPI Auto-Pay' : 'Bank NEFT',
          referenceId: 'UTR-${collectorId.replaceAll('-', '')}${8000 + index}',
          status: index == 0 ? 'Pending' : 'Paid',
          timestamp: '${date.day}/${date.month}/${date.year} 11:30 AM',
        );
      });
    }

    // Daily records helper
    List<CollectorDailyRecord> generateDailyRecords(double baseMorning, double baseEvening) {
      return List.generate(14, (i) {
        final d = now.subtract(Duration(days: i));
        final m = baseMorning + ((i % 5) * 12.0);
        final e = baseEvening + ((i % 4) * 9.0);
        final tot = m + e;
        return CollectorDailyRecord(
          date: d,
          morningLitres: m,
          eveningLitres: e,
          totalLitres: tot,
          fat: 4.1 + (i % 3) * 0.15,
          snf: 8.4 + (i % 3) * 0.1,
          temperature: 4.0 + (i % 2) * 0.3,
          amount: tot * 48.5,
        );
      });
    }

    // Activity timeline helper
    List<CollectorActivityLog> generateActivities(String name) {
      return [
        CollectorActivityLog(
          timestamp: now.subtract(const Duration(minutes: 25)),
          action: 'Handover / Dispatched',
          description: '$name dispatched 480L in container tanker RJ-14-GA-1022.',
        ),
        CollectorActivityLog(
          timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
          action: 'Farmer Collection',
          description: 'Collected 18.5L from farmer Rahul Kumar (F002) at 4.4% FAT.',
        ),
        CollectorActivityLog(
          timestamp: now.subtract(const Duration(hours: 3)),
          action: 'Started Collection',
          description: 'Evening collection window opened with analyzer calibrated.',
        ),
        CollectorActivityLog(
          timestamp: now.subtract(const Duration(hours: 7)),
          action: 'Morning Shift Closed',
          description: 'Completed morning collection total 520L from 42 farmers.',
        ),
        CollectorActivityLog(
          timestamp: now.subtract(const Duration(hours: 10)),
          action: 'Login',
          description: 'Logged into mobile collector terminal from Behror Center.',
        ),
      ];
    }

    _collectors.addAll([
      Collector(
        id: 'C-BHN-001',
        name: 'Ramesh Kumar',
        phone: '9829012345',
        email: 'ramesh.behror@dairycoop.in',
        center: 'Behror Center',
        location: 'Behror, Alwar',
        joiningDate: DateTime(2023, 3, 15),
        status: 'Active',
        lastActiveTime: '15 mins ago',
        farmersHandled: 84,
        morningLitresToday: 520.0,
        eveningLitresToday: 480.0,
        paymentStatus: 'Paid',
        avgFat: 4.3,
        avgSnf: 8.6,
        avgTemp: 4.1,
        dailyRecords: generateDailyRecords(520, 480),
        payments: generatePayments('C-BHN-001', 48500),
        assignedFarmerIds: ['F001', 'F002', 'F003', 'F004'],
        activities: generateActivities('Ramesh Kumar'),
      ),
      Collector(
        id: 'C-JAI-002',
        name: 'Suresh Sharma',
        phone: '9829023456',
        email: 'suresh.jaipur@dairycoop.in',
        center: 'Jaipur Center',
        location: 'Chomu Road, Jaipur',
        joiningDate: DateTime(2022, 11, 1),
        status: 'Collecting',
        lastActiveTime: 'Just now',
        farmersHandled: 112,
        morningLitresToday: 740.0,
        eveningLitresToday: 690.0,
        paymentStatus: 'Paid',
        avgFat: 4.4,
        avgSnf: 8.7,
        avgTemp: 3.9,
        dailyRecords: generateDailyRecords(740, 690),
        payments: generatePayments('C-JAI-002', 69500),
        assignedFarmerIds: ['F001', 'F004', 'F006'],
        activities: generateActivities('Suresh Sharma'),
      ),
      Collector(
        id: 'C-AJM-003',
        name: 'Mahesh Verma',
        phone: '9829034567',
        email: 'mahesh.ajmer@dairycoop.in',
        center: 'Ajmer Center',
        location: 'Kishangarh, Ajmer',
        joiningDate: DateTime(2023, 7, 20),
        status: 'On Duty',
        lastActiveTime: '45 mins ago',
        farmersHandled: 76,
        morningLitresToday: 490.0,
        eveningLitresToday: 430.0,
        paymentStatus: 'Pending',
        avgFat: 4.1,
        avgSnf: 8.4,
        avgTemp: 4.3,
        dailyRecords: generateDailyRecords(490, 430),
        payments: generatePayments('C-AJM-003', 44200),
        assignedFarmerIds: ['F002', 'F005'],
        activities: generateActivities('Mahesh Verma'),
      ),
      Collector(
        id: 'C-SKR-004',
        name: 'Vikram Singh',
        phone: '9829045678',
        email: 'vikram.sikar@dairycoop.in',
        center: 'Sikar Center',
        location: 'Neem Ka Thana, Sikar',
        joiningDate: DateTime(2024, 1, 10),
        status: 'Active',
        lastActiveTime: '10 mins ago',
        farmersHandled: 95,
        morningLitresToday: 610.0,
        eveningLitresToday: 570.0,
        paymentStatus: 'Paid',
        avgFat: 4.25,
        avgSnf: 8.55,
        avgTemp: 4.0,
        dailyRecords: generateDailyRecords(610, 570),
        payments: generatePayments('C-SKR-004', 57000),
        assignedFarmerIds: ['F003', 'F006'],
        activities: generateActivities('Vikram Singh'),
      ),
      Collector(
        id: 'C-TNK-005',
        name: 'Kailash Choudhary',
        phone: '9829056789',
        email: 'kailash.tonk@dairycoop.in',
        center: 'Tonk Center',
        location: 'Niwai, Tonk',
        joiningDate: DateTime(2023, 9, 5),
        status: 'Offline',
        lastActiveTime: '2 hours ago',
        farmersHandled: 54,
        morningLitresToday: 340.0,
        eveningLitresToday: 310.0,
        paymentStatus: 'Pending',
        avgFat: 4.05,
        avgSnf: 8.35,
        avgTemp: 4.5,
        dailyRecords: generateDailyRecords(340, 310),
        payments: generatePayments('C-TNK-005', 31500),
        assignedFarmerIds: ['F007'],
        activities: generateActivities('Kailash Choudhary'),
      ),
    ]);
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
