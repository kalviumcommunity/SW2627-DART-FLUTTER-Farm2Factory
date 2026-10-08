import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/dairy_analytics_repository.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/dairy_stat_card.dart';

class QualityAnalyticsScreen extends StatefulWidget {
  const QualityAnalyticsScreen({super.key});

  @override
  State<QualityAnalyticsScreen> createState() => _QualityAnalyticsScreenState();
}

class _QualityAnalyticsScreenState extends State<QualityAnalyticsScreen> {
  final _analyticsRepo = DairyAnalyticsRepository.instance;

  void _showConfigureThresholdsDialog(BuildContext context) {
    final metric = _analyticsRepo.metric;
    double currentFat = metric.minFatThreshold;
    double currentSnf = metric.minSnfThreshold;
    double currentTemp = metric.maxTempThreshold;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.tune, color: AppTheme.brandGreen),
              SizedBox(width: 8),
              Text('Configure Quality Limits', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minimum FAT Threshold: ${currentFat.toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: currentFat,
                min: 3.0,
                max: 5.0,
                divisions: 20,
                activeColor: AppTheme.brandGreen,
                onChanged: (val) => setDialogState(() => currentFat = val),
              ),
              const SizedBox(height: 10),
              Text('Minimum SNF Threshold: ${currentSnf.toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: currentSnf,
                min: 7.5,
                max: 9.5,
                divisions: 20,
                activeColor: const Color(0xFF0288D1),
                onChanged: (val) => setDialogState(() => currentSnf = val),
              ),
              const SizedBox(height: 10),
              Text('Maximum Chilling Temp: ${currentTemp.toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: currentTemp,
                min: 3.0,
                max: 10.0,
                divisions: 14,
                activeColor: const Color(0xFFE65100),
                onChanged: (val) => setDialogState(() => currentTemp = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _analyticsRepo.updateThresholds(
                  minFat: currentFat,
                  minSnf: currentSnf,
                  maxTemp: currentTemp,
                );
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Threshold alerts updated!'), backgroundColor: AppTheme.brandGreen),
                );
              },
              child: const Text('Save Thresholds'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _analyticsRepo.metric;

    return DairyPortalScaffold(
      activeRoute: '/dairy/quality',
      title: 'Milk Quality & Lab Analytics',
      actions: [
        IconButton(
          tooltip: 'Configure Thresholds',
          icon: const Icon(Icons.tune, color: AppTheme.brandGreen),
          onPressed: () => _showConfigureThresholdsDialog(context),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stat Cards
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: MediaQuery.of(context).size.width > 700 ? 1.4 : 1.18,
              children: [
                DairyStatCard(
                  icon: Icons.grain,
                  iconColor: AppTheme.brandGreen,
                  title: 'Average FAT',
                  value: '${m.avgFat}%',
                  subtitle: 'Threshold: ≥ ${m.minFatThreshold}%',
                  cardBgColor: AppTheme.cardMint,
                ),
                DairyStatCard(
                  icon: Icons.opacity,
                  iconColor: const Color(0xFF0288D1),
                  title: 'Average SNF',
                  value: '${m.avgSnf}%',
                  subtitle: 'Threshold: ≥ ${m.minSnfThreshold}%',
                  cardBgColor: AppTheme.cardSky,
                ),
                DairyStatCard(
                  icon: Icons.thermostat,
                  iconColor: const Color(0xFFE65100),
                  title: 'Chilling Temp',
                  value: '${m.avgTemperature}°C',
                  subtitle: 'Ceiling: ≤ ${m.maxTempThreshold}°C',
                  cardBgColor: AppTheme.cardPeach,
                ),
                DairyStatCard(
                  icon: Icons.verified_outlined,
                  iconColor: const Color(0xFF6A1B9A),
                  title: 'Grade A Purity',
                  value: '${m.gradeAPercent}%',
                  subtitle: 'Total: ${m.totalQuantity.toInt()} L tested',
                  cardBgColor: AppTheme.cardLavender,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quality Distribution Breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Intake Quality Grading Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 18,
                      child: Row(
                        children: [
                          Expanded(flex: (m.gradeAPercent * 10).toInt(), child: Container(color: AppTheme.brandGreen)),
                          Expanded(flex: (m.gradeBPercent * 10).toInt(), child: Container(color: const Color(0xFFFFA000))),
                          Expanded(flex: (m.gradeCPercent * 10).toInt(), child: Container(color: const Color(0xFF5C6BC0))),
                          Expanded(flex: (m.rejectedPercent * 10).toInt(), child: Container(color: const Color(0xFFC62828))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      _gradePill('Grade A', '${m.gradeAPercent}%', AppTheme.brandGreen),
                      _gradePill('Grade B', '${m.gradeBPercent}%', const Color(0xFFFFA000)),
                      _gradePill('Grade C', '${m.gradeCPercent}%', const Color(0xFF5C6BC0)),
                      _gradePill('Rejected', '${m.rejectedPercent}%', const Color(0xFFC62828)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Center-wise Comparison Chart Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Center-Wise FAT & SNF Comparison', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _centerComparisonRow('Jaipur Central Hub', 4.40, 8.70, 1430),
                  _centerComparisonRow('Behror Chilling Center', 4.30, 8.60, 1000),
                  _centerComparisonRow('Sikar Collection Hub', 4.25, 8.55, 1180),
                  _centerComparisonRow('Ajmer South Station', 4.10, 8.40, 920),
                  _centerComparisonRow('Tonk Chilling Yard', 3.65, 8.35, 650, isAlert: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradePill(String label, String percent, Color col) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($percent)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  Widget _centerComparisonRow(String center, double fat, double snf, int litres, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAlert ? Colors.redAccent : const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$litres L  •  FAT: $fat%  •  SNF: $snf%',
                style: TextStyle(fontSize: 11.5, color: isAlert ? Colors.redAccent : Colors.grey.shade700, fontWeight: isAlert ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (fat / 5.0).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(isAlert ? Colors.redAccent : AppTheme.brandGreen),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
