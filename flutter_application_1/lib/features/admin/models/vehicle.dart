/// Milk container transport vehicle for Dairy Admin fleet tracking.
class Vehicle {
  final String id;
  final String vehicleNo;
  final String driverName;
  final String driverPhone;
  final int capacityLitres;
  final int containersCount;
  final String status; // 'Dispatched', 'En Route', 'Received', 'Maintenance'
  final String route;
  final DateTime dispatchedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNo,
    required this.driverName,
    required this.driverPhone,
    required this.capacityLitres,
    required this.containersCount,
    required this.status,
    required this.route,
    required this.dispatchedAt,
  });
}
