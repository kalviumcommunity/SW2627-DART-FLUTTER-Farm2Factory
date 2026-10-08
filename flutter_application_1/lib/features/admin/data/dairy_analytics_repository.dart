import 'package:flutter/foundation.dart';

import '../models/quality_metric.dart';

class DairyAnalyticsRepository extends ChangeNotifier {
  DairyAnalyticsRepository._() {
    _initMetrics();
  }
  static final DairyAnalyticsRepository instance = DairyAnalyticsRepository._();

  QualityMetric _metric = const QualityMetric();

  QualityMetric get metric => _metric;

  void updateThresholds({double? minFat, double? minSnf, double? maxTemp}) {
    _metric = _metric.copyWith(
      minFatThreshold: minFat,
      minSnfThreshold: minSnf,
      maxTempThreshold: maxTemp,
    );
    notifyListeners();
  }

  void dismissAlert(String alertId) {
    final updated = _metric.activeAlerts.where((a) => a.id != alertId).toList();
    _metric = _metric.copyWith(activeAlerts: updated);
    notifyListeners();
  }

  void _initMetrics() {
    final now = DateTime.now();
    _metric = QualityMetric(
      avgFat: 4.25,
      avgSnf: 8.55,
      avgTemperature: 4.1,
      totalQuantity: 42850.0,
      gradeAPercent: 84.5,
      gradeBPercent: 11.2,
      gradeCPercent: 3.1,
      rejectedPercent: 1.2,
      minFatThreshold: 3.8,
      minSnfThreshold: 8.2,
      maxTempThreshold: 6.0,
      activeAlerts: [
        QualityAlert(
          id: 'ALT-01',
          severity: 'Warning',
          title: 'Low FAT Sample Detected',
          message: 'Collector Kailash (Tonk Center) recorded batch sample FAT at 3.65% (below threshold 3.80%).',
          timestamp: now.subtract(const Duration(minutes: 40)),
          location: 'Tonk Center',
        ),
        QualityAlert(
          id: 'ALT-02',
          severity: 'High',
          title: 'Temperature Warning on Tanker',
          message: 'Tanker RJ-26-PA-3211 recorded internal temperature of 5.8°C approaching chill ceiling (6.0°C).',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
          location: 'NH-12 Highway',
        ),
        QualityAlert(
          id: 'ALT-03',
          severity: 'Info',
          title: 'Peak Milk Collection Milestone',
          message: 'Daily plant intake crossed 40,000 Litres at 09:30 AM with 98.8% Grade A pass rate.',
          timestamp: now.subtract(const Duration(hours: 3)),
          location: 'Jaipur Plant',
        ),
      ],
    );
  }
}
