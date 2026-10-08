/// Milk quality testing metrics, quality grades, and configurable operational alert thresholds.
class QualityMetric {
  final double avgFat;
  final double avgSnf;
  final double avgTemperature;
  final double totalQuantity;
  final double gradeAPercent;
  final double gradeBPercent;
  final double gradeCPercent;
  final double rejectedPercent;

  // Configurable Quality Thresholds
  final double minFatThreshold;
  final double minSnfThreshold;
  final double maxTempThreshold;

  final List<QualityAlert> activeAlerts;

  const QualityMetric({
    this.avgFat = 4.25,
    this.avgSnf = 8.55,
    this.avgTemperature = 4.1,
    this.totalQuantity = 42850.0,
    this.gradeAPercent = 84.5,
    this.gradeBPercent = 11.2,
    this.gradeCPercent = 3.1,
    this.rejectedPercent = 1.2,
    this.minFatThreshold = 3.8,
    this.minSnfThreshold = 8.2,
    this.maxTempThreshold = 6.0,
    this.activeAlerts = const [],
  });

  QualityMetric copyWith({
    double? minFatThreshold,
    double? minSnfThreshold,
    double? maxTempThreshold,
    List<QualityAlert>? activeAlerts,
  }) {
    return QualityMetric(
      avgFat: avgFat,
      avgSnf: avgSnf,
      avgTemperature: avgTemperature,
      totalQuantity: totalQuantity,
      gradeAPercent: gradeAPercent,
      gradeBPercent: gradeBPercent,
      gradeCPercent: gradeCPercent,
      rejectedPercent: rejectedPercent,
      minFatThreshold: minFatThreshold ?? this.minFatThreshold,
      minSnfThreshold: minSnfThreshold ?? this.minSnfThreshold,
      maxTempThreshold: maxTempThreshold ?? this.maxTempThreshold,
      activeAlerts: activeAlerts ?? this.activeAlerts,
    );
  }
}

class QualityAlert {
  final String id;
  final String severity; // 'High', 'Warning', 'Info'
  final String title;
  final String message;
  final DateTime timestamp;
  final String location;

  const QualityAlert({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.location,
  });
}
