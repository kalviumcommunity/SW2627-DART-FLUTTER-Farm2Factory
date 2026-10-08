/// Seller / Commercial Supplier model directly providing bulk milk to the Dairy Plant.
class Seller {
  final String id;
  final String name;
  final String farmName;
  final String location;
  final String phone;
  final int cattleCount;
  final double dailySupplyLitres;
  final double monthlySupplyLitres;
  final double avgFat;
  final double avgSnf;
  final double ratePerLitre;
  final String paymentStatus; // 'Paid', 'Pending'
  final String status; // 'Active', 'Inactive'
  final List<SellerSupplyRecord> supplies;
  final List<SellerPaymentRecord> payments;

  const Seller({
    required this.id,
    required this.name,
    required this.farmName,
    required this.location,
    required this.phone,
    required this.cattleCount,
    required this.dailySupplyLitres,
    required this.monthlySupplyLitres,
    required this.avgFat,
    required this.avgSnf,
    required this.ratePerLitre,
    required this.paymentStatus,
    this.status = 'Active',
    this.supplies = const [],
    this.payments = const [],
  });
}

class SellerSupplyRecord {
  final DateTime date;
  final double quantityLitres;
  final double fat;
  final double snf;
  final double temperature;
  final double amount;
  final String grade;

  const SellerSupplyRecord({
    required this.date,
    required this.quantityLitres,
    required this.fat,
    required this.snf,
    required this.temperature,
    required this.amount,
    this.grade = 'A Grade',
  });
}

class SellerPaymentRecord {
  final String id;
  final DateTime date;
  final double amount;
  final String method;
  final String status; // 'Paid', 'Pending'
  final String transactionId;

  const SellerPaymentRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionId,
  });
}
