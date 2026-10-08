/// Collector model representing an aggregation agent connected to the Dairy Plant.
class Collector {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String center;
  final String location;
  final DateTime joiningDate;
  final String status; // 'Active', 'Collecting', 'On Duty', 'Offline', 'Inactive'
  final String lastActiveTime;
  final int farmersHandled;
  final double morningLitresToday;
  final double eveningLitresToday;
  final String paymentStatus; // 'Paid', 'Pending', 'Processing'
  final double avgFat;
  final double avgSnf;
  final double avgTemp;
  final List<CollectorDailyRecord> dailyRecords;
  final List<CollectorPaymentTransaction> payments;
  final List<String> assignedFarmerIds;
  final List<CollectorActivityLog> activities;

  const Collector({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.center,
    required this.location,
    required this.joiningDate,
    required this.status,
    required this.lastActiveTime,
    required this.farmersHandled,
    required this.morningLitresToday,
    required this.eveningLitresToday,
    required this.paymentStatus,
    this.avgFat = 4.2,
    this.avgSnf = 8.5,
    this.avgTemp = 4.1,
    this.dailyRecords = const [],
    this.payments = const [],
    this.assignedFarmerIds = const [],
    this.activities = const [],
  });

  double get todayTotalLitres => morningLitresToday + eveningLitresToday;

  double get monthlyTotalLitres {
    if (dailyRecords.isEmpty) return todayTotalLitres * 28;
    return dailyRecords.fold(0.0, (sum, r) => sum + r.totalLitres);
  }

  double get avgDailyLitres {
    if (dailyRecords.isEmpty) return todayTotalLitres;
    return monthlyTotalLitres / dailyRecords.length;
  }
}

class CollectorDailyRecord {
  final DateTime date;
  final double morningLitres;
  final double eveningLitres;
  final double totalLitres;
  final double fat;
  final double snf;
  final double temperature;
  final double amount;

  const CollectorDailyRecord({
    required this.date,
    required this.morningLitres,
    required this.eveningLitres,
    required this.totalLitres,
    required this.fat,
    required this.snf,
    required this.temperature,
    required this.amount,
  });
}

class CollectorPaymentTransaction {
  final String id;
  final DateTime date;
  final String period;
  final double amount;
  final String method;
  final String referenceId;
  final String status; // 'Paid', 'Pending', 'Failed'
  final String timestamp;

  const CollectorPaymentTransaction({
    required this.id,
    required this.date,
    required this.period,
    required this.amount,
    required this.method,
    required this.referenceId,
    required this.status,
    required this.timestamp,
  });
}

class CollectorActivityLog {
  final DateTime timestamp;
  final String action; // 'Login', 'Started Collection', 'Farmer Collection', 'Dispatched', 'Logout'
  final String description;

  const CollectorActivityLog({
    required this.timestamp,
    required this.action,
    required this.description,
  });
}
