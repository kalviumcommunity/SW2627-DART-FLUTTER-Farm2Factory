import 'package:flutter/foundation.dart';

import '../models/dairy_payment.dart';

class DairyPaymentRepository extends ChangeNotifier {
  DairyPaymentRepository._() {
    _initMockPayments();
  }
  static final DairyPaymentRepository instance = DairyPaymentRepository._();

  final List<DairyPayment> _payments = [];

  List<DairyPayment> get payments => List.unmodifiable(_payments);

  double get totalPendingPayout => _payments
      .where((p) => p.status == 'Pending')
      .fold(0.0, (sum, p) => sum + p.finalAmount);

  double get totalPaidThisWeek => _payments
      .where((p) => p.status == 'Paid' && p.paymentDate.isAfter(DateTime.now().subtract(const Duration(days: 7))))
      .fold(0.0, (sum, p) => sum + p.finalAmount);

  double get totalPaidThisMonth => _payments
      .where((p) => p.status == 'Paid' && p.paymentDate.isAfter(DateTime.now().subtract(const Duration(days: 30))))
      .fold(0.0, (sum, p) => sum + p.finalAmount);

  int get pendingCollectorsCount => _payments
      .where((p) => p.status == 'Pending' && p.recipientType == 'Collector')
      .length;

  List<DairyPayment> get pendingPayments =>
      _payments.where((p) => p.status == 'Pending').toList();

  List<DairyPayment> get paymentHistory =>
      _payments.where((p) => p.status == 'Paid').toList();

  DairyPayment? disburseAndNotify({
    required String paymentId,
    String? customUtr,
  }) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final old = _payments[idx];
      final now = DateTime.now();
      final utr = customUtr ?? 'UTR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${old.recipientId}';
      final updated = DairyPayment(
        id: old.id,
        recipientId: old.recipientId,
        recipientName: old.recipientName,
        recipientPhone: old.recipientPhone,
        recipientType: old.recipientType,
        centerOrLocation: old.centerOrLocation,
        totalLitres: old.totalLitres,
        ratePerLitre: old.ratePerLitre,
        grossAmount: old.grossAmount,
        adjustments: old.adjustments,
        finalAmount: old.finalAmount,
        paymentCycle: old.paymentCycle,
        status: 'Paid',
        paymentDate: old.paymentDate,
        disbursedAt: now,
        paymentMethod: old.paymentMethod,
        transactionReference: utr,
        bankAccountMasked: old.bankAccountMasked,
        notified: true,
        notificationSummary: 'SMS & in-app payout alert delivered to +91 ${old.recipientPhone}',
      );
      _payments[idx] = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  void markAsPaid(String paymentId) {
    disburseAndNotify(paymentId: paymentId);
  }

  void _initMockPayments() {
    final now = DateTime.now();

    _payments.addAll([
      DairyPayment(
        id: 'PAY-COL-001',
        recipientId: 'C-BHN-001',
        recipientName: 'Ramesh Kumar',
        recipientPhone: '9999999999',
        recipientType: 'Collector',
        centerOrLocation: 'Behror Center',
        totalLitres: 14000.0,
        ratePerLitre: 48.5,
        grossAmount: 679000.0,
        adjustments: 2500.0,
        finalAmount: 681500.0,
        paymentCycle: '10 Days',
        status: 'Pending',
        paymentDate: now,
        bankAccountMasked: 'SBI Bank •••• 4102',
      ),
      DairyPayment(
        id: 'PAY-COL-002',
        recipientId: 'C-JAI-002',
        recipientName: 'Suresh Sharma',
        recipientPhone: '9829012345',
        recipientType: 'Collector',
        centerOrLocation: 'Jaipur Center',
        totalLitres: 20020.0,
        ratePerLitre: 49.0,
        grossAmount: 980980.0,
        adjustments: 5200.0,
        finalAmount: 986180.0,
        paymentCycle: '10 Days',
        status: 'Paid',
        paymentDate: now.subtract(const Duration(days: 2)),
        disbursedAt: now.subtract(const Duration(days: 2)),
        transactionReference: 'UTR-20261024-C-JAI-002',
        bankAccountMasked: 'HDFC Bank •••• 8821',
        notified: true,
        notificationSummary: 'SMS & in-app payout alert delivered to +91 9829012345',
      ),
      DairyPayment(
        id: 'PAY-COL-003',
        recipientId: 'C-AJM-003',
        recipientName: 'Mahesh Verma',
        recipientPhone: '9414056789',
        recipientType: 'Collector',
        centerOrLocation: 'Ajmer Center',
        totalLitres: 12880.0,
        ratePerLitre: 48.0,
        grossAmount: 618240.0,
        adjustments: -1200.0,
        finalAmount: 617040.0,
        paymentCycle: '10 Days',
        status: 'Pending',
        paymentDate: now,
        bankAccountMasked: 'ICICI Bank •••• 6340',
      ),
      DairyPayment(
        id: 'PAY-COL-004',
        recipientId: 'C-SKR-004',
        recipientName: 'Vikram Singh',
        recipientPhone: '9783011223',
        recipientType: 'Collector',
        centerOrLocation: 'Sikar Center',
        totalLitres: 16520.0,
        ratePerLitre: 49.2,
        grossAmount: 812784.0,
        adjustments: 3400.0,
        finalAmount: 816184.0,
        paymentCycle: '10 Days',
        status: 'Paid',
        paymentDate: now.subtract(const Duration(days: 5)),
        disbursedAt: now.subtract(const Duration(days: 5)),
        transactionReference: 'UTR-20261021-C-SKR-004',
        bankAccountMasked: 'PNB Bank •••• 1928',
        notified: true,
        notificationSummary: 'SMS & in-app payout alert delivered to +91 9783011223',
      ),
      DairyPayment(
        id: 'PAY-SEL-001',
        recipientId: 'S-001',
        recipientName: 'Green Valley Farm',
        recipientPhone: '9828099887',
        recipientType: 'Seller',
        centerOrLocation: 'Jaipur Farm',
        totalLitres: 20000.0,
        ratePerLitre: 49.5,
        grossAmount: 990000.0,
        adjustments: 0.0,
        finalAmount: 990000.0,
        paymentCycle: '10 Days',
        status: 'Paid',
        paymentDate: now.subtract(const Duration(days: 4)),
        disbursedAt: now.subtract(const Duration(days: 4)),
        transactionReference: 'UTR-20261022-S-001',
        bankAccountMasked: 'Axis Bank •••• 7710',
        notified: true,
        notificationSummary: 'SMS & in-app payout alert delivered to +91 9828099887',
      ),
      DairyPayment(
        id: 'PAY-SEL-002',
        recipientId: 'S-002',
        recipientName: 'Surya Cattle Farms',
        recipientPhone: '9660144556',
        recipientType: 'Seller',
        centerOrLocation: 'Ajmer Farm',
        totalLitres: 14500.0,
        ratePerLitre: 48.0,
        grossAmount: 696000.0,
        adjustments: -3000.0,
        finalAmount: 693000.0,
        paymentCycle: '10 Days',
        status: 'Pending',
        paymentDate: now,
        bankAccountMasked: 'BOB Bank •••• 5591',
      ),
    ]);
  }
}
