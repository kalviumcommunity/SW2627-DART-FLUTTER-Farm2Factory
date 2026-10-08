/// Geo-ready operational location model for collection centers, plants, and vehicles.
enum DairyLocationType { plant, center, sellerFarm, vehicle }

class DairyLocation {
  final String id;
  final String name;
  final DairyLocationType type;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String status; // 'Active', 'En Route', 'Operating', 'Offline'
  final String contactPerson;
  final String contactPhone;
  final String lastUpdated;
  final double todayVolumeLitres;

  const DairyLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.contactPerson,
    required this.contactPhone,
    required this.lastUpdated,
    this.todayVolumeLitres = 0.0,
  });
}
