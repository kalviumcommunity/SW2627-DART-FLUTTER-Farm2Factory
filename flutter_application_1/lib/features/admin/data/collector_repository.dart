import 'package:flutter/foundation.dart';

import '../models/collector.dart';

class CollectorRepository extends ChangeNotifier {
  CollectorRepository._() {
    _initMockCollectors();
  }
  static final CollectorRepository instance = CollectorRepository._();

  final List<Collector> _collectors = [];

  List<Collector> get collectors => List.unmodifiable(_collectors);

  Collector? getCollectorById(String id) {
    try {
      return _collectors.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
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
}
