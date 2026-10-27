/// Payout transaction and cycle record for collectors, sellers, and logistics.
class DairyPayment {
  final String id;
  final String recipientId;
  final String recipientName;
  final String recipientPhone;
  final String recipientType; // 'Collector', 'Seller', 'Driver'
  final String centerOrLocation;
  final double totalLitres;
  final double ratePerLitre;
  final double grossAmount;
  final double adjustments; // Bonus / Quality deductions
  final double finalAmount;
  final String paymentCycle; // 'Weekly', '10 Days', 'Monthly', 'Custom'
  final String status; // 'Paid', 'Pending', 'Processing', 'Failed'
  final DateTime paymentDate;
  final DateTime? disbursedAt;
  final String paymentMethod;
  final String transactionReference;
  final String bankAccountMasked;
  final bool notified;
  final String notificationSummary;

  const DairyPayment({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    this.recipientPhone = '9876543210',
    required this.recipientType,
    required this.centerOrLocation,
    required this.totalLitres,
    required this.ratePerLitre,
    required this.grossAmount,
    this.adjustments = 0.0,
    required this.finalAmount,
    this.paymentCycle = '10 Days',
    required this.status,
    required this.paymentDate,
    this.disbursedAt,
    this.paymentMethod = 'Bank NEFT/RTGS',
    this.transactionReference = 'TXN-998822',
    this.bankAccountMasked = 'HDFC Bank •••• 4102',
    this.notified = false,
    this.notificationSummary = '',
  });
}
