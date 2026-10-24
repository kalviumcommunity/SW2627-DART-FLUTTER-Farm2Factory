/// Milk quality testing metrics, quality grades, and configurable operational alert thresholds.
class CenterQualityStat {
  final String centerName;
  final double avgFat;
  final double avgSnf;
  final double totalLitres;
  final bool isAlert;

  const CenterQualityStat({
    required this.centerName,
    required this.avgFat,
    required this.avgSnf,
    required this.totalLitres,
    this.isAlert = false,
  });
}

class QualityMetric {
  final double avgFat;
  final double avgSnf;
  final double avgTemperature;
  final double totalQuantity;
  final double morningQuantity;
  final double eveningQuantity;
  final int totalEntries;
  final int acceptedEntries;
  final int rejectedEntries;
  final double gradeAPercent;
  final double gradeBPercent;
  final double gradeCPercent;
  final double rejectedPercent;
  final List<CenterQualityStat> centerStats;

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
    this.morningQuantity = 23400.0,
    this.eveningQuantity = 19450.0,
    this.totalEntries = 840,
    this.acceptedEntries = 830,
    this.rejectedEntries = 10,
    this.gradeAPercent = 84.5,
    this.gradeBPercent = 11.2,
    this.gradeCPercent = 3.1,
    this.rejectedPercent = 1.2,
    this.centerStats = const [
      CenterQualityStat(centerName: 'Jaipur Central Hub', avgFat: 4.40, avgSnf: 8.70, totalLitres: 14300),
      CenterQualityStat(centerName: 'Behror Chilling Center', avgFat: 4.30, avgSnf: 8.60, totalLitres: 10000),
      CenterQualityStat(centerName: 'Sikar Collection Hub', avgFat: 4.25, avgSnf: 8.55, totalLitres: 11800),
      CenterQualityStat(centerName: 'Ajmer South Station', avgFat: 4.10, avgSnf: 8.40, totalLitres: 9200),
      CenterQualityStat(centerName: 'Tonk Chilling Yard', avgFat: 3.65, avgSnf: 8.35, totalLitres: 6500, isAlert: true),
    ],
    this.minFatThreshold = 3.8,
    this.minSnfThreshold = 8.2,
    this.maxTempThreshold = 6.0,
    this.activeAlerts = const [],
  });

  QualityMetric copyWith({
    double? avgFat,
    double? avgSnf,
    double? avgTemperature,
    double? totalQuantity,
    double? morningQuantity,
    double? eveningQuantity,
    int? totalEntries,
    int? acceptedEntries,
    int? rejectedEntries,
    double? gradeAPercent,
    double? gradeBPercent,
    double? gradeCPercent,
    double? rejectedPercent,
    List<CenterQualityStat>? centerStats,
    double? minFatThreshold,
    double? minSnfThreshold,
    double? maxTempThreshold,
    List<QualityAlert>? activeAlerts,
  }) {
    return QualityMetric(
      avgFat: avgFat ?? this.avgFat,
      avgSnf: avgSnf ?? this.avgSnf,
      avgTemperature: avgTemperature ?? this.avgTemperature,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      morningQuantity: morningQuantity ?? this.morningQuantity,
      eveningQuantity: eveningQuantity ?? this.eveningQuantity,
      totalEntries: totalEntries ?? this.totalEntries,
      acceptedEntries: acceptedEntries ?? this.acceptedEntries,
      rejectedEntries: rejectedEntries ?? this.rejectedEntries,
      gradeAPercent: gradeAPercent ?? this.gradeAPercent,
      gradeBPercent: gradeBPercent ?? this.gradeBPercent,
      gradeCPercent: gradeCPercent ?? this.gradeCPercent,
      rejectedPercent: rejectedPercent ?? this.rejectedPercent,
      centerStats: centerStats ?? this.centerStats,
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
