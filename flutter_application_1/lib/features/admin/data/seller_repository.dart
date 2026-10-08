import 'package:flutter/foundation.dart';

import '../models/seller.dart';

class SellerRepository extends ChangeNotifier {
  SellerRepository._() {
    _initMockSellers();
  }
  static final SellerRepository instance = SellerRepository._();

  final List<Seller> _sellers = [];

  List<Seller> get sellers => List.unmodifiable(_sellers);

  Seller? getSellerById(String id) {
    try {
      return _sellers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void _initMockSellers() {
    final now = DateTime.now();

    List<SellerSupplyRecord> generateSupplies(double dailyBase) {
      return List.generate(10, (i) {
        final d = now.subtract(Duration(days: i));
        final qty = dailyBase + ((i % 3) * 60) - ((i % 2) * 35);
        return SellerSupplyRecord(
          date: d,
          quantityLitres: qty,
          fat: 4.2 + (i % 3) * 0.1,
          snf: 8.5 + (i % 2) * 0.1,
          temperature: 4.1 + (i % 2) * 0.2,
          amount: qty * 49.0,
          grade: i == 3 ? 'B Grade' : 'A Grade',
        );
      });
    }

    List<SellerPaymentRecord> generatePayments(String id, double base) {
      return List.generate(6, (i) {
        return SellerPaymentRecord(
          id: 'SPAY-$id-${100 + i}',
          date: now.subtract(Duration(days: (i + 1) * 5)),
          amount: base + (i * 2500),
          method: 'Bank RTGS',
          status: i == 0 ? 'Pending' : 'Paid',
          transactionId: 'RTGS-F2F-$id-${9900 + i}',
        );
      });
    }

    _sellers.addAll([
      Seller(
        id: 'S-001',
        name: 'Green Valley Farm',
        farmName: 'Green Valley Agro & Cattle Estate',
        location: 'Amer Road, Jaipur',
        phone: '9828111222',
        cattleCount: 120,
        dailySupplyLitres: 2000.0,
        monthlySupplyLitres: 58500.0,
        avgFat: 4.35,
        avgSnf: 8.65,
        ratePerLitre: 49.5,
        paymentStatus: 'Paid',
        status: 'Active',
        supplies: generateSupplies(2000.0),
        payments: generatePayments('S-001', 98000),
      ),
      Seller(
        id: 'S-002',
        name: 'Surya Cattle Farms',
        farmName: 'Surya Commercial Dairy Farm',
        location: 'Pushkar Bypass, Ajmer',
        phone: '9828222333',
        cattleCount: 85,
        dailySupplyLitres: 1450.0,
        monthlySupplyLitres: 42100.0,
        avgFat: 4.2,
        avgSnf: 8.5,
        ratePerLitre: 48.0,
        paymentStatus: 'Pending',
        status: 'Active',
        supplies: generateSupplies(1450.0),
        payments: generatePayments('S-002', 69000),
      ),
      Seller(
        id: 'S-003',
        name: 'Rajasthan Organic Gaushala',
        farmName: 'Rajasthan Organic Desi Cow Sanctuary',
        location: 'Ringas, Sikar',
        phone: '9828333444',
        cattleCount: 210,
        dailySupplyLitres: 3200.0,
        monthlySupplyLitres: 94000.0,
        avgFat: 4.6,
        avgSnf: 8.85,
        ratePerLitre: 53.0,
        paymentStatus: 'Paid',
        status: 'Active',
        supplies: generateSupplies(3200.0),
        payments: generatePayments('S-003', 169000),
      ),
      Seller(
        id: 'S-004',
        name: 'Govardhan Dairy Agro',
        farmName: 'Govardhan High-Yield Dairy Tech',
        location: 'RIICO Phase II, Behror',
        phone: '9828444555',
        cattleCount: 160,
        dailySupplyLitres: 2600.0,
        monthlySupplyLitres: 76500.0,
        avgFat: 4.3,
        avgSnf: 8.6,
        ratePerLitre: 49.0,
        paymentStatus: 'Paid',
        status: 'Active',
        supplies: generateSupplies(2600.0),
        payments: generatePayments('S-004', 127000),
      ),
      Seller(
        id: 'S-005',
        name: 'Krishna Dairy Producers',
        farmName: 'Krishna Milk Agro Co.',
        location: 'Malpura, Tonk',
        phone: '9828555666',
        cattleCount: 60,
        dailySupplyLitres: 950.0,
        monthlySupplyLitres: 27800.0,
        avgFat: 4.15,
        avgSnf: 8.45,
        ratePerLitre: 47.5,
        paymentStatus: 'Pending',
        status: 'Inactive',
        supplies: generateSupplies(950.0),
        payments: generatePayments('S-005', 45000),
      ),
    ]);
  }
}
