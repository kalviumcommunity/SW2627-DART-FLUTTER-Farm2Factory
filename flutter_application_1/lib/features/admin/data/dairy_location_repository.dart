import 'package:flutter/foundation.dart';

import '../models/dairy_location.dart';

class DairyLocationRepository extends ChangeNotifier {
  DairyLocationRepository._() {
    _initLocations();
  }
  static final DairyLocationRepository instance = DairyLocationRepository._();

  final List<DairyLocation> _locations = [];

  List<DairyLocation> get locations => List.unmodifiable(_locations);

  void _initLocations() {
    _locations.addAll([
      const DairyLocation(
        id: 'LOC-PLANT-01',
        name: 'Jaipur Central Dairy Processing Plant',
        type: DairyLocationType.plant,
        address: 'RIICO Industrial Area, Mansarovar',
        city: 'Jaipur',
        latitude: 26.8524,
        longitude: 75.7612,
        status: 'Operating 24/7',
        contactPerson: 'Er. Rajesh Singhal (Plant Head)',
        contactPhone: '0141-2800111',
        lastUpdated: 'Live telemetry active',
        todayVolumeLitres: 42850.0,
      ),
      const DairyLocation(
        id: 'LOC-CTR-01',
        name: 'Behror Chilling & Collection Center',
        type: DairyLocationType.center,
        address: 'Old Alwar Road, Behror',
        city: 'Alwar',
        latitude: 27.8872,
        longitude: 76.2811,
        status: 'Active (4.1°C Silo)',
        contactPerson: 'Ramesh Kumar (Collector in-charge)',
        contactPhone: '9829012345',
        lastUpdated: '10 mins ago',
        todayVolumeLitres: 1000.0,
      ),
      const DairyLocation(
        id: 'LOC-CTR-02',
        name: 'Jaipur Rural Milk Hub',
        type: DairyLocationType.center,
        address: 'Chomu Bypass, Jaipur',
        city: 'Jaipur',
        latitude: 27.1706,
        longitude: 75.7214,
        status: 'Active (3.9°C Silo)',
        contactPerson: 'Suresh Sharma',
        contactPhone: '9829023456',
        lastUpdated: 'Just now',
        todayVolumeLitres: 1430.0,
      ),
      const DairyLocation(
        id: 'LOC-CTR-03',
        name: 'Ajmer South Chilling Plant',
        type: DairyLocationType.center,
        address: 'Kishangarh Industrial Belt',
        city: 'Ajmer',
        latitude: 26.5744,
        longitude: 74.8624,
        status: 'Active (4.3°C Silo)',
        contactPerson: 'Mahesh Verma',
        contactPhone: '9829034567',
        lastUpdated: '15 mins ago',
        todayVolumeLitres: 920.0,
      ),
      const DairyLocation(
        id: 'LOC-CTR-04',
        name: 'Sikar Shekhawati Chilling Station',
        type: DairyLocationType.center,
        address: 'Neem Ka Thana Road',
        city: 'Sikar',
        latitude: 27.6094,
        longitude: 75.1398,
        status: 'Active (4.0°C Silo)',
        contactPerson: 'Vikram Singh',
        contactPhone: '9829045678',
        lastUpdated: '20 mins ago',
        todayVolumeLitres: 1180.0,
      ),
      const DairyLocation(
        id: 'LOC-FARM-01',
        name: 'Green Valley Mega Dairy Farm',
        type: DairyLocationType.sellerFarm,
        address: 'Amer Rural, Jaipur',
        city: 'Jaipur',
        latitude: 26.9855,
        longitude: 75.8507,
        status: 'Active Supplier',
        contactPerson: 'Dr. Om Prakash (Farm Manager)',
        contactPhone: '9828111222',
        lastUpdated: '45 mins ago',
        todayVolumeLitres: 2000.0,
      ),
      const DairyLocation(
        id: 'LOC-VH-01',
        name: 'Tanker RJ-14-GA-1022 (En Route)',
        type: DairyLocationType.vehicle,
        address: 'NH-48 Highway near Kotputli (Speed: 46 km/h)',
        city: 'Kotputli',
        latitude: 27.7022,
        longitude: 76.1950,
        status: 'En Route (4.0°C)',
        contactPerson: 'Vikram Singh (Driver)',
        contactPhone: '9829012345',
        lastUpdated: '5 mins ago via cellular beacon',
        todayVolumeLitres: 4650.0,
      ),
    ]);
  }
}
