import 'package:flutter/foundation.dart';

import '../models/dispatch_record.dart';

class DispatchRepository extends ChangeNotifier {
  DispatchRepository._() {
    _initMockDispatches();
  }
  static final DispatchRepository instance = DispatchRepository._();

  final List<DispatchRecord> _dispatches = [];

  List<DispatchRecord> get dispatches => List.unmodifiable(_dispatches);

  DispatchRecord? getDispatchById(String id) {
    try {
      return _dispatches.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  void addDispatch(DispatchRecord dispatch) {
    _dispatches.insert(0, dispatch);
    notifyListeners();
  }

  void updateDispatchStatus(String id, String newStatus, int stageIndex) {
    final idx = _dispatches.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final old = _dispatches[idx];
      _dispatches[idx] = DispatchRecord(
        id: old.id,
        vehicleNo: old.vehicleNo,
        vehicleType: old.vehicleType,
        driverName: old.driverName,
        driverPhone: old.driverPhone,
        capacityLitres: old.capacityLitres,
        loadedLitres: old.loadedLitres,
        containersCount: old.containersCount,
        fromLocation: old.fromLocation,
        toDestination: old.toDestination,
        dispatchedAt: old.dispatchedAt,
        expectedArrival: old.expectedArrival,
        actualArrival: newStatus == 'Delivered' ? DateTime.now() : old.actualArrival,
        status: newStatus,
        currentStageIndex: stageIndex,
        temperature: old.temperature,
        dispatchAmount: old.dispatchAmount,
        paymentStatus: old.paymentStatus,
        lastKnownLocation: old.lastKnownLocation,
        lastLocationUpdate: DateTime.now(),
        timeline: old.timeline,
      );
      notifyListeners();
    }
  }

  void _initMockDispatches() {
    final now = DateTime.now();

    List<DispatchTimelineStep> generateTimeline(int stage) {
      return [
        DispatchTimelineStep(
          stageName: 'Loading at Center',
          time: '05:30 AM',
          isCompleted: stage >= 0,
          isCurrent: stage == 0,
          note: 'Chilled milk containers loaded and insulated.',
        ),
        DispatchTimelineStep(
          stageName: 'Dispatched & Sealed',
          time: '06:15 AM',
          isCompleted: stage >= 1,
          isCurrent: stage == 1,
          note: 'Quality check verified. E-lock seal #SL-8842 applied.',
        ),
        DispatchTimelineStep(
          stageName: 'En Route',
          time: '07:00 AM',
          isCompleted: stage >= 2,
          isCurrent: stage == 2,
          note: 'Tanker travelling on state expressway at 48 km/h.',
        ),
        DispatchTimelineStep(
          stageName: 'Dairy Plant Arrival',
          time: '08:45 AM',
          isCompleted: stage >= 3,
          isCurrent: stage == 3,
          note: 'Weighbridge entry scan and gross weight verified.',
        ),
        DispatchTimelineStep(
          stageName: 'Lab Check & Unloading',
          time: '09:15 AM',
          isCompleted: stage >= 4,
          isCurrent: stage == 4,
          note: 'Fat & SNF cross-tested; pumped to Silo #3.',
        ),
        DispatchTimelineStep(
          stageName: 'Completed & CIP Cleaned',
          time: '10:00 AM',
          isCompleted: stage >= 5,
          isCurrent: stage == 5,
          note: 'Container sanitized and cleared for return route.',
        ),
      ];
    }

    _dispatches.addAll([
      DispatchRecord(
        id: 'DSP-101',
        vehicleNo: 'RJ-14-GA-1022',
        driverName: 'Vikram Singh',
        driverPhone: '9829012345',
        capacityLitres: 5000,
        loadedLitres: 4650,
        containersCount: 125,
        fromLocation: 'Behror Collection Center',
        toDestination: 'Jaipur Central Dairy Plant',
        dispatchedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        expectedArrival: now.add(const Duration(minutes: 45)),
        status: 'En Route',
        currentStageIndex: 2,
        temperature: 4.0,
        dispatchAmount: 225525.0,
        paymentStatus: 'Paid',
        lastKnownLocation: 'NH-48 Highway near Kotputli (42 km to Plant)',
        lastLocationUpdate: now.subtract(const Duration(minutes: 5)),
        timeline: generateTimeline(2),
      ),
      DispatchRecord(
        id: 'DSP-102',
        vehicleNo: 'RJ-01-EA-4520',
        driverName: 'Harish Chandra',
        driverPhone: '9829054321',
        capacityLitres: 4500,
        loadedLitres: 4100,
        containersCount: 110,
        fromLocation: 'Ajmer Collection Center',
        toDestination: 'Jaipur Central Dairy Plant',
        dispatchedAt: now.subtract(const Duration(hours: 1)),
        expectedArrival: now.add(const Duration(hours: 1, minutes: 30)),
        status: 'Dispatched',
        currentStageIndex: 1,
        temperature: 3.9,
        dispatchAmount: 198850.0,
        paymentStatus: 'Paid',
        lastKnownLocation: 'Kishangarh Toll Plaza',
        lastLocationUpdate: now.subtract(const Duration(minutes: 12)),
        timeline: generateTimeline(1),
      ),
      DispatchRecord(
        id: 'DSP-103',
        vehicleNo: 'RJ-23-MA-8819',
        driverName: 'Dharmendra Yadav',
        driverPhone: '9783011223',
        capacityLitres: 6000,
        loadedLitres: 5850,
        containersCount: 150,
        fromLocation: 'Sikar Collection Center',
        toDestination: 'Jaipur Central Dairy Plant',
        dispatchedAt: now.subtract(const Duration(hours: 4, minutes: 30)),
        expectedArrival: now.subtract(const Duration(minutes: 30)),
        actualArrival: now.subtract(const Duration(minutes: 25)),
        status: 'Delivered',
        currentStageIndex: 5,
        temperature: 4.2,
        dispatchAmount: 286650.0,
        paymentStatus: 'Paid',
        lastKnownLocation: 'Silo Bay #3, Jaipur Dairy Plant',
        lastLocationUpdate: now.subtract(const Duration(minutes: 2)),
        timeline: generateTimeline(5),
      ),
      DispatchRecord(
        id: 'DSP-104',
        vehicleNo: 'RJ-26-PA-3211',
        driverName: 'Mukesh Gujjar',
        driverPhone: '9829099887',
        capacityLitres: 3500,
        loadedLitres: 3200,
        containersCount: 85,
        fromLocation: 'Tonk Collection Center',
        toDestination: 'Jaipur Central Dairy Plant',
        dispatchedAt: now.subtract(const Duration(minutes: 30)),
        expectedArrival: now.add(const Duration(hours: 2)),
        status: 'Loading',
        currentStageIndex: 0,
        temperature: 4.1,
        dispatchAmount: 155200.0,
        paymentStatus: 'Pending',
        lastKnownLocation: 'Tonk Chilling Yard Bay #1',
        lastLocationUpdate: now.subtract(const Duration(minutes: 8)),
        timeline: generateTimeline(0),
      ),
    ]);
  }
}
