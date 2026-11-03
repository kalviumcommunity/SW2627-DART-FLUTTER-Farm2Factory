import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class IntakeDispatchChart extends StatelessWidget {
  final String period; // 'Today', 'This Week', 'This Month', 'This Year'

  const IntakeDispatchChart({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData(period);
    final maxVal = chartData.map((d) => d.intake > d.dispatch ? d.intake : d.dispatch).reduce((a, b) => a > b ? a : b);

    final totalIntake = chartData.fold(0.0, (sum, d) => sum + d.intake);
    final totalDispatch = chartData.fold(0.0, (sum, d) => sum + d.dispatch);
    final diff = totalIntake - totalDispatch;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.creamSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.creamBorder),
                    ),
                    child: const Icon(Icons.bar_chart, color: Color(0xFF0F5132), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Milk Intake vs. Tanker Dispatch ($period)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Reconciliation between Collection Centers and Factory Dispatches',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  _buildLegendItem('Intake (Litres)', AppTheme.brandGreen),
                  const SizedBox(width: 16),
                  _buildLegendItem('Dispatched (Litres)', const Color(0xFF0288D1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Stats Pill Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.creamSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Total Procured', '${totalIntake.toInt()} L', AppTheme.brandGreenDark),
                Container(width: 1, height: 28, color: AppTheme.creamBorder),
                _buildStatPill('Total Dispatched', '${totalDispatch.toInt()} L', const Color(0xFF0288D1)),
                Container(width: 1, height: 28, color: AppTheme.creamBorder),
                _buildStatPill(
                  'Net Buffer / Silo',
                  '${diff >= 0 ? '+' : ''}${diff.toInt()} L',
                  diff >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
                Container(width: 1, height: 28, color: AppTheme.creamBorder),
                _buildStatPill('Dispatch Efficiency', '${((totalDispatch / totalIntake) * 100).toStringAsFixed(1)}%', const Color(0xFFE65100)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Visual Bars Area
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((item) {
                final intakeHeight = maxVal > 0 ? (item.intake / maxVal) * 160 : 0.0;
                final dispatchHeight = maxVal > 0 ? (item.dispatch / maxVal) * 160 : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bars Pair
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Intake Bar
                            Tooltip(
                              message: '${item.label} Intake: ${item.intake.toInt()} L',
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 14,
                                height: intakeHeight.clamp(8.0, 160.0),
                                decoration: BoxDecoration(
                                  color: AppTheme.brandGreen,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.brandGreen.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Dispatch Bar
                            Tooltip(
                              message: '${item.label} Dispatch: ${item.dispatch.toInt()} L',
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 14,
                                height: dispatchHeight.clamp(8.0, 160.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0288D1),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0288D1).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
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

  static Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  static Widget _buildStatPill(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  List<_ChartPoint> _getChartData(String period) {
    switch (period) {
      case 'Today':
        return [
          const _ChartPoint('06:00 AM', 4200, 3800),
          const _ChartPoint('08:00 AM', 8600, 8000),
          const _ChartPoint('10:00 AM', 10600, 10000),
          const _ChartPoint('12:00 PM', 3200, 3000),
          const _ChartPoint('02:00 PM', 1800, 1500),
          const _ChartPoint('04:00 PM', 6400, 5800),
          const _ChartPoint('06:00 PM', 8050, 7500),
        ];
      case 'This Week':
        return [
          const _ChartPoint('Mon', 41200, 39500),
          const _ChartPoint('Tue', 42850, 40500),
          const _ChartPoint('Wed', 43500, 42000),
          const _ChartPoint('Thu', 44100, 41800),
          const _ChartPoint('Fri', 42300, 40900),
          const _ChartPoint('Sat', 45000, 43200),
          const _ChartPoint('Sun', 46200, 44500),
        ];
      case 'This Month':
        return [
          const _ChartPoint('W1 (1-7)', 295000, 282000),
          const _ChartPoint('W2 (8-14)', 305000, 294000),
          const _ChartPoint('W3 (15-21)', 312000, 301000),
          const _ChartPoint('W4 (22-28)', 318000, 308000),
          const _ChartPoint('W5 (29-31)', 138000, 132000),
        ];
      case 'This Year':
        return [
          const _ChartPoint('Jan', 1240000, 1180000),
          const _ChartPoint('Feb', 1280000, 1220000),
          const _ChartPoint('Mar', 1340000, 1290000),
          const _ChartPoint('Apr', 1410000, 1360000),
          const _ChartPoint('May', 1490000, 1420000),
          const _ChartPoint('Jun', 1450000, 1390000),
          const _ChartPoint('Jul', 1380000, 1310000),
          const _ChartPoint('Aug', 1390000, 1330000),
          const _ChartPoint('Sep', 1420000, 1370000),
          const _ChartPoint('Oct', 1480000, 1410000),
        ];
      default:
        return [
          const _ChartPoint('Morning', 23400, 22000),
          const _ChartPoint('Evening', 19450, 18500),
        ];
    }
  }
}

class _ChartPoint {
  final String label;
  final double intake;
  final double dispatch;

  const _ChartPoint(this.label, this.intake, this.dispatch);
}
