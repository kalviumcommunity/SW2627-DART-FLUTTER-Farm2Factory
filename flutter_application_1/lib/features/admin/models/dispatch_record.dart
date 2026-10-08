/// Milk dispatch and logistics record tracking movement from collection centers to dairy factory.
class DispatchRecord {
  final String id;
  final String vehicleNo;
  final String vehicleType;
  final String driverName;
  final String driverPhone;
  final int capacityLitres;
  final int loadedLitres;
  final int containersCount;
  final String fromLocation;
  final String toDestination;
  final DateTime dispatchedAt;
  final DateTime expectedArrival;
  final DateTime? actualArrival;
  final String status; // 'Scheduled', 'Loading', 'Dispatched', 'En Route', 'Delivered', 'Delayed', 'Cancelled'
  final int currentStageIndex; // 0: Loading, 1: Dispatched, 2: En Route, 3: Dairy Arrival, 4: Unloading, 5: Completed
  final double temperature;
  final double dispatchAmount;
  final String paymentStatus; // 'Paid', 'Pending'
  final String lastKnownLocation;
  final DateTime lastLocationUpdate;
  final List<DispatchTimelineStep> timeline;

  const DispatchRecord({
    required this.id,
    required this.vehicleNo,
    this.vehicleType = 'Insulated Road Tanker',
    required this.driverName,
    required this.driverPhone,
    required this.capacityLitres,
    required this.loadedLitres,
    required this.containersCount,
    required this.fromLocation,
    this.toDestination = 'Jaipur Central Dairy Plant',
    required this.dispatchedAt,
    required this.expectedArrival,
    this.actualArrival,
    required this.status,
    this.currentStageIndex = 2,
    this.temperature = 4.0,
    required this.dispatchAmount,
    this.paymentStatus = 'Paid',
    this.lastKnownLocation = 'NH-48 Highway near Kotputli',
    required this.lastLocationUpdate,
    this.timeline = const [],
  });
}

class DispatchTimelineStep {
  final String stageName; // 'Loading', 'Dispatched', 'En Route', 'Dairy Arrival', 'Unloading', 'Completed'
  final String time;
  final bool isCompleted;
  final bool isCurrent;
  final String note;

  const DispatchTimelineStep({
    required this.stageName,
    required this.time,
    required this.isCompleted,
    this.isCurrent = false,
    this.note = '',
  });
}
