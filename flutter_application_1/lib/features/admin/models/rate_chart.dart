import 'package:cloud_firestore/cloud_firestore.dart';

enum MilkType { cow, buffalo, mixed }

extension MilkTypeExtension on MilkType {
  String get displayName {
    switch (this) {
      case MilkType.cow:
        return 'Cow Milk';
      case MilkType.buffalo:
        return 'Buffalo Milk';
      case MilkType.mixed:
        return 'Mixed Milk';
    }
  }

  String get emoji {
    switch (this) {
      case MilkType.cow:
        return '🐄';
      case MilkType.buffalo:
        return '🐃';
      case MilkType.mixed:
        return '🥛';
    }
  }
}

/// Calculation breakdown for transparency and slips
class RateCalculationResult {
  final double ratePerLitre;
  final double totalAmount;
  final double fatComponent;
  final double snfComponent;
  final double baseComponent;
  final bool isQualityAcceptable;
  final String qualityGrade;
  final String? warningMessage;
  final String rateChartTitle;

  const RateCalculationResult({
    required this.ratePerLitre,
    required this.totalAmount,
    required this.fatComponent,
    required this.snfComponent,
    required this.baseComponent,
    required this.isQualityAcceptable,
    required this.qualityGrade,
    this.warningMessage,
    required this.rateChartTitle,
  });

  static const RateCalculationResult empty = RateCalculationResult(
    ratePerLitre: 0.0,
    totalAmount: 0.0,
    fatComponent: 0.0,
    snfComponent: 0.0,
    baseComponent: 0.0,
    isQualityAcceptable: true,
    qualityGrade: 'Standard',
    rateChartTitle: 'Standard Chart',
  );
}

/// Configurable pricing chart for dairy cooperatives
class RateChart {
  final String id;
  final String title;
  final MilkType milkType;
  final double fatRate; // Rate coefficient per 1% Fat (e.g. ₹6.80)
  final double snfRate; // Rate coefficient per 1% SNF (e.g. ₹2.20)
  final double baseRate; // Base floor rate (e.g. ₹0.0 or ₹5.0)
  final double minFat; // Minimum acceptable Fat percentage
  final double minSnf; // Minimum acceptable SNF percentage
  final DateTime effectiveFrom;
  final bool isActive;

  const RateChart({
    required this.id,
    required this.title,
    required this.milkType,
    required this.fatRate,
    required this.snfRate,
    this.baseRate = 0.0,
    this.minFat = 3.0,
    this.minSnf = 8.0,
    required this.effectiveFrom,
    this.isActive = true,
  });

  /// Core pricing engine formula:
  /// Rate = Base + (Fat% * FatRate) + (SNF% * SNFRate)
  RateCalculationResult calculate({
    required double quantity,
    required double fat,
    required double snf,
  }) {
    if (fat <= 0 || snf <= 0 || quantity <= 0) {
      return RateCalculationResult.empty;
    }

    final fatComp = double.parse((fat * fatRate).toStringAsFixed(2));
    final snfComp = double.parse((snf * snfRate).toStringAsFixed(2));
    final rawRate = baseRate + fatComp + snfComp;
    final rate = double.parse(rawRate.toStringAsFixed(2));
    final total = double.parse((quantity * rate).toStringAsFixed(2));

    // Quality check
    final isQualityAcceptable = fat >= minFat && snf >= minSnf;
    String? warning;
    String grade = 'Grade A';

    if (!isQualityAcceptable) {
      grade = 'Sub-standard';
      if (fat < minFat && snf < minSnf) {
        warning = 'Both Fat & SNF below cooperative standard!';
      } else if (fat < minFat) {
        warning = 'Fat below $minFat% standard limit.';
      } else {
        warning = 'SNF below $minSnf% standard limit.';
      }
    } else if (fat >= (minFat + 1.2) && snf >= (minSnf + 0.5)) {
      grade = 'Premium Plus';
    }

    return RateCalculationResult(
      ratePerLitre: rate,
      totalAmount: total,
      fatComponent: fatComp,
      snfComponent: snfComp,
      baseComponent: baseRate,
      isQualityAcceptable: isQualityAcceptable,
      qualityGrade: grade,
      warningMessage: warning,
      rateChartTitle: title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'milkType': milkType.name,
      'fatRate': fatRate,
      'snfRate': snfRate,
      'baseRate': baseRate,
      'minFat': minFat,
      'minSnf': minSnf,
      'effectiveFrom': Timestamp.fromDate(effectiveFrom),
      'isActive': isActive,
    };
  }

  factory RateChart.fromMap(String docId, Map<String, dynamic> map) {
    MilkType parseType(String? val) {
      if (val == 'buffalo') return MilkType.buffalo;
      if (val == 'mixed') return MilkType.mixed;
      return MilkType.cow;
    }

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RateChart(
      id: docId,
      title: map['title'] ?? 'Standard Rate Chart',
      milkType: parseType(map['milkType'] as String?),
      fatRate: (map['fatRate'] as num?)?.toDouble() ?? 6.8,
      snfRate: (map['snfRate'] as num?)?.toDouble() ?? 2.2,
      baseRate: (map['baseRate'] as num?)?.toDouble() ?? 0.0,
      minFat: (map['minFat'] as num?)?.toDouble() ?? 3.0,
      minSnf: (map['minSnf'] as num?)?.toDouble() ?? 8.0,
      effectiveFrom: parseDate(map['effectiveFrom']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  RateChart copyWith({
    String? id,
    String? title,
    MilkType? milkType,
    double? fatRate,
    double? snfRate,
    double? baseRate,
    double? minFat,
    double? minSnf,
    DateTime? effectiveFrom,
    bool? isActive,
  }) {
    return RateChart(
      id: id ?? this.id,
      title: title ?? this.title,
      milkType: milkType ?? this.milkType,
      fatRate: fatRate ?? this.fatRate,
      snfRate: snfRate ?? this.snfRate,
      baseRate: baseRate ?? this.baseRate,
      minFat: minFat ?? this.minFat,
      minSnf: minSnf ?? this.minSnf,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      isActive: isActive ?? this.isActive,
    );
  }
}
