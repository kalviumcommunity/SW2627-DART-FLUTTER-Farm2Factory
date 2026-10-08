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

  void markAsPaid(String paymentId) {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final old = _payments[idx];
      _payments[idx] = DairyPayment(
        id: old.id,
        recipientId: old.recipientId,
        recipientName: old.recipientName,
        recipientType: old.recipientType,
        centerOrLocation: old.centerOrLocation,
        totalLitres: old.totalLitres,
        ratePerLitre: old.ratePerLitre,
        grossAmount: old.grossAmount,
        adjustments: old.adjustments,
        finalAmount: old.finalAmount,
        paymentCycle: old.paymentCycle,
        status: 'Paid',
        paymentDate: DateTime.now(),
        paymentMethod: old.paymentMethod,
        transactionReference: 'NEFT-${DateTime.now().millisecondsSinceEpoch}',
      );
      notifyListeners();
    }
  }

  void _initMockPayments() {
    final now = DateTime.now();

    _payments.addAll([
      DairyPayment(
        id: 'PAY-COL-001',
        recipientId: 'C-BHN-001',
        recipientName: 'Ramesh Kumar',
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
      ),
      DairyPayment(
        id: 'PAY-COL-002',
        recipientId: 'C-JAI-002',
        recipientName: 'Suresh Sharma',
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
      ),
      DairyPayment(
        id: 'PAY-COL-003',
        recipientId: 'C-AJM-003',
        recipientName: 'Mahesh Verma',
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
      ),
      DairyPayment(
        id: 'PAY-COL-004',
        recipientId: 'C-SKR-004',
        recipientName: 'Vikram Singh',
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
      ),
      DairyPayment(
        id: 'PAY-SEL-001',
        recipientId: 'S-001',
        recipientName: 'Green Valley Farm',
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
      ),
      DairyPayment(
        id: 'PAY-SEL-002',
        recipientId: 'S-002',
        recipientName: 'Surya Cattle Farms',
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
      ),
    ]);
  }
}
