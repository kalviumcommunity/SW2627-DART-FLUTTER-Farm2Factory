import 'package:flutter/material.dart';

class QualityTrendChart extends StatelessWidget {
  final String period;

  const QualityTrendChart({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final points = _getQualityPoints(period);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (responsive wrap to prevent horizontal overflow)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.science_outlined, color: Color(0xFF7C3AED), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Milk Quality Composition Trends',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'FAT % and SNF % testing conformance across $period',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendIndicator('FAT % (Avg: 4.25%)', const Color(0xFFD97706)),
                  const SizedBox(width: 14),
                  _legendIndicator('SNF % (Avg: 8.55%)', const Color(0xFF7C3AED)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Standard Targets Info Banner (Clean regulatory compliance banner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.verified_outlined, size: 16, color: Color(0xFF0F5132)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FSSAI Milk Standards: Minimum FAT ≥ 3.8% | Minimum SNF ≥ 8.2% | Temperature ≤ 4.5°C',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quality visual points
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                // Fat range: 3.0 to 5.0 (scale to 120px)
                final fatHeight = ((p.fat - 3.0) / 2.0 * 110).clamp(10.0, 110.0);
                // SNF range: 7.5 to 9.5 (scale to 120px)
                final snfHeight = ((p.snf - 7.5) / 2.0 * 110).clamp(10.0, 110.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: '${p.label} - FAT: ${p.fat}%',
                              child: Container(
                                width: 10,
                                height: fatHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE65100),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Tooltip(
                              message: '${p.label} - SNF: ${p.snf}%',
                              child: Container(
                                width: 10,
                                height: snfHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B1FA2),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.label,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _legendIndicator(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }

  List<_QualityPoint> _getQualityPoints(String period) {
    switch (period) {
      case 'Today':
        return [
          const _QualityPoint('Center 1', 4.30, 8.60),
          const _QualityPoint('Center 2', 4.15, 8.50),
          const _QualityPoint('Center 3', 4.40, 8.70),
          const _QualityPoint('Center 4', 4.20, 8.55),
          const _QualityPoint('Center 5', 4.10, 8.45),
        ];
      case 'This Week':
        return [
          const _QualityPoint('Mon', 4.20, 8.50),
          const _QualityPoint('Tue', 4.25, 8.55),
          const _QualityPoint('Wed', 4.30, 8.60),
          const _QualityPoint('Thu', 4.22, 8.52),
          const _QualityPoint('Fri', 4.35, 8.65),
          const _QualityPoint('Sat', 4.28, 8.58),
          const _QualityPoint('Sun', 4.32, 8.62),
        ];
      case 'This Month':
        return [
          const _QualityPoint('W1', 4.22, 8.52),
          const _QualityPoint('W2', 4.28, 8.57),
          const _QualityPoint('W3', 4.31, 8.60),
          const _QualityPoint('W4', 4.26, 8.54),
        ];
      case 'This Year':
        return [
          const _QualityPoint('Jan', 4.35, 8.65),
          const _QualityPoint('Feb', 4.30, 8.60),
          const _QualityPoint('Mar', 4.25, 8.55),
          const _QualityPoint('Apr', 4.18, 8.48),
          const _QualityPoint('May', 4.10, 8.42),
          const _QualityPoint('Jun', 4.15, 8.45),
          const _QualityPoint('Jul', 4.22, 8.50),
          const _QualityPoint('Aug', 4.26, 8.55),
          const _QualityPoint('Sep', 4.30, 8.58),
          const _QualityPoint('Oct', 4.32, 8.62),
        ];
      default:
        return [
          const _QualityPoint('Morning', 4.28, 8.58),
          const _QualityPoint('Evening', 4.22, 8.52),
        ];
    }
  }
}

class _QualityPoint {
  final String label;
  final double fat;
  final double snf;

  const _QualityPoint(this.label, this.fat, this.snf);
}
