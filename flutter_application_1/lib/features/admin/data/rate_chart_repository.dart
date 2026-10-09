import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/rate_chart.dart';

/// Central dairy pricing repository managing active and historical rate charts.
class RateChartRepository extends ChangeNotifier {
  RateChartRepository._() {
    _initFirestoreListener();
  }
  static final RateChartRepository instance = RateChartRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<RateChart> _rateCharts = [
    RateChart(
      id: 'RC-COW-2026-OCT',
      title: 'Standard Cow Milk Chart (Autumn 2026)',
      milkType: MilkType.cow,
      fatRate: 6.80, // ₹6.80 per 1% Fat
      snfRate: 2.20, // ₹2.20 per 1% SNF
      baseRate: 0.0,
      minFat: 3.2,
      minSnf: 8.3,
      effectiveFrom: DateTime(2026, 10, 1),
      isActive: true,
    ),
    RateChart(
      id: 'RC-BUF-2026-OCT',
      title: 'High-Fat Buffalo Milk Chart (Autumn 2026)',
      milkType: MilkType.buffalo,
      fatRate: 7.40, // ₹7.40 per 1% Fat
      snfRate: 2.50, // ₹2.50 per 1% SNF
      baseRate: 0.0,
      minFat: 5.5,
      minSnf: 8.8,
      effectiveFrom: DateTime(2026, 10, 1),
      isActive: true,
    ),
    RateChart(
      id: 'RC-COW-2026-SEP',
      title: 'Monsoon Cow Rate Chart (Archived)',
      milkType: MilkType.cow,
      fatRate: 6.50,
      snfRate: 2.00,
      baseRate: 0.0,
      minFat: 3.0,
      minSnf: 8.0,
      effectiveFrom: DateTime(2026, 9, 1),
      isActive: false,
    ),
  ];

  List<RateChart> get allCharts => List.unmodifiable(_rateCharts);

  RateChart get activeCowChart {
    return _rateCharts.firstWhere(
      (c) => c.isActive && c.milkType == MilkType.cow,
      orElse: () => _rateCharts.first,
    );
  }

  RateChart get activeBuffaloChart {
    return _rateCharts.firstWhere(
      (c) => c.isActive && c.milkType == MilkType.buffalo,
      orElse: () => _rateCharts.first,
    );
  }

  RateChart getActiveChartFor(MilkType type) {
    if (type == MilkType.buffalo) return activeBuffaloChart;
    return activeCowChart;
  }

  /// Calculates pricing immediately given quantity, fat, snf, and milk type.
  RateCalculationResult calculate({
    required double quantity,
    required double fat,
    required double snf,
    MilkType milkType = MilkType.cow,
  }) {
    final chart = getActiveChartFor(milkType);
    return chart.calculate(quantity: quantity, fat: fat, snf: snf);
  }

  /// Dairy Admin updates base rates with an effective date.
  Future<void> updateRates({
    required MilkType milkType,
    required String title,
    required double fatRate,
    required double snfRate,
    double baseRate = 0.0,
    double minFat = 3.2,
    double minSnf = 8.3,
    required DateTime effectiveFrom,
  }) async {
    // 1. Deactivate current active chart for this milk type
    for (int i = 0; i < _rateCharts.length; i++) {
      if (_rateCharts[i].milkType == milkType && _rateCharts[i].isActive) {
        _rateCharts[i] = _rateCharts[i].copyWith(isActive: false);
      }
    }

    // 2. Create new active chart
    final newId = 'RC-${milkType.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final newChart = RateChart(
      id: newId,
      title: title.trim(),
      milkType: milkType,
      fatRate: fatRate,
      snfRate: snfRate,
      baseRate: baseRate,
      minFat: minFat,
      minSnf: minSnf,
      effectiveFrom: effectiveFrom,
      isActive: true,
    );

    _rateCharts.insert(0, newChart);
    notifyListeners();

    // 3. Persist to Firestore if online
    try {
      await _firestore.collection('rate_charts').doc(newId).set(newChart.toMap());
    } catch (e) {
      debugPrint('Firestore rate chart sync skipped/failed: $e');
    }
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('rate_charts').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          for (final doc in snapshot.docs) {
            final chart = RateChart.fromMap(doc.id, doc.data());
            final existingIndex = _rateCharts.indexWhere((c) => c.id == chart.id);
            if (existingIndex >= 0) {
              _rateCharts[existingIndex] = chart;
            } else {
              _rateCharts.insert(0, chart);
            }
          }
          notifyListeners();
        }
      }, onError: (err) {
        debugPrint('Rate chart firestore listener notice: $err');
      });
    } catch (_) {}
  }
}
