import 'package:flutter/foundation.dart';

import '../models/vehicle.dart';

class VehicleRepository extends ChangeNotifier {
  VehicleRepository._();
  static final VehicleRepository instance = VehicleRepository._();

  final List<Vehicle> _vehicles = [
    Vehicle(
      id: 'VH-01',
      vehicleNo: 'RJ-14-GA-1022',
      driverName: 'Vikram Singh',
      driverPhone: '9829012345',
      capacityLitres: 5000,
      containersCount: 125,
      status: 'Dispatched',
      route: 'Behror - Kotputli Route',
      dispatchedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Vehicle(
      id: 'VH-02',
      vehicleNo: 'RJ-01-EA-4520',
      driverName: 'Harish Chandra',
      driverPhone: '9829054321',
      capacityLitres: 4500,
      containersCount: 110,
      status: 'En Route',
      route: 'Ajmer South Route',
      dispatchedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    Vehicle(
      id: 'VH-03',
      vehicleNo: 'RJ-23-MA-8819',
      driverName: 'Dharmendra Yadav',
      driverPhone: '9783011223',
      capacityLitres: 6000,
      containersCount: 150,
      status: 'Received',
      route: 'Sikar Center Direct',
      dispatchedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }
}
