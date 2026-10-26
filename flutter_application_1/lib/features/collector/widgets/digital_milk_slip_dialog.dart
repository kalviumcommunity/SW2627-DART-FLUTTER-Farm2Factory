import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../models/milk_entry.dart';

/// Clean, modal Digital Milk Slip (दूध पर्ची) displayed immediately
/// after milk collection is recorded, or on demand from recent entry history.
class DigitalMilkSlipDialog extends StatelessWidget {
  final MilkEntry entry;

  const DigitalMilkSlipDialog({super.key, required this.entry});

  /// Static helper to display the milk slip modal dialog.
  static Future<void> show(BuildContext context, MilkEntry entry) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DigitalMilkSlipDialog(entry: entry),
    );
  }

  String _formatSlipText() {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(entry.date);
    return '''
==============================
   FARM2FACTORY DAIRY COOP
      DIGITAL MILK SLIP
==============================
Receipt ID : ${entry.id}
Date & Time: $dateStr
Shift      : ${entry.shift}
Center     : ${entry.centerId}
------------------------------
Farmer Name: ${entry.farmerName}
Farmer ID  : ${entry.farmerCode}
Milk Type  : ${entry.milkType.toUpperCase()}
------------------------------
Quantity   : ${entry.quantityLitres.toStringAsFixed(1)} Litres
Fat        : ${entry.fatPercentage.toStringAsFixed(1)} %
SNF        : ${entry.snfPercentage.toStringAsFixed(1)} %
Temperature: ${entry.temperature.toStringAsFixed(1)} °C
Quality    : ${entry.qualityStatus} (${entry.qualityGrade})
------------------------------
Rate / L   : ₹ ${entry.ratePerLitre.toStringAsFixed(2)}
TOTAL AMT  : ₹ ${entry.totalAmount.toStringAsFixed(2)}
==============================
Thank you for your milk supply!
''';
  }

  void _copySlip(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _formatSlipText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Milk Slip copied to clipboard!'),
        backgroundColor: AppTheme.brandGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(entry.date);
    final isAccepted = entry.isAccepted;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with logo and cooperative title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppLogo(size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farm2Factory Dairy Coop',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandGreenDark,
                          ),
                        ),
                        Text(
                          'Digital Milk Slip • ${entry.centerId}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAccepted
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Text(
                      entry.qualityStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAccepted
                            ? Colors.green.shade800
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Farmer Information Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.brandGreen,
                      child: Text(
                        entry.farmerName.isNotEmpty
                            ? entry.farmerName[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.farmerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Farmer ID: ${entry.farmerCode} • ${entry.shift}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Slip Details Grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _slipRow('Date & Time', formattedDate),
                    const Divider(height: 16),
                    _slipRow(
                      'Milk Type',
                      entry.milkType.toUpperCase() == 'BUFFALO'
                          ? 'Buffalo Milk 🐃'
                          : 'Cow Milk 🐄',
                    ),
                    const Divider(height: 16),
                    _slipRow(
                      'Quantity',
                      '${entry.quantityLitres.toStringAsFixed(1)} Litres',
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            'Fat %',
                            '${entry.fatPercentage.toStringAsFixed(1)}%',
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: _metricTile(
                            'SNF %',
                            '${entry.snfPercentage.toStringAsFixed(1)}%',
                          ),
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: _metricTile(
                            'Temp',
                            '${entry.temperature.toStringAsFixed(1)}°C',
                          ),
                        ),
                      ],
                    ),
                    if (entry.qualityGrade.isNotEmpty) ...[
                      const Divider(height: 16),
                      _slipRow('Quality Grade', entry.qualityGrade),
                    ],
                    if (entry.rejectionReason != null &&
                        entry.rejectionReason!.isNotEmpty) ...[
                      const Divider(height: 16),
                      _slipRow(
                        'Quality Note',
                        entry.rejectionReason!,
                        valueColor: Colors.orange.shade900,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Total Payout Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.brandGreen.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rate per Litre',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${entry.ratePerLitre.toStringAsFixed(2)} / L',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandGreenDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${entry.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.brandGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () => _copySlip(context),
                      icon: const Icon(Icons.copy_outlined, size: 16),
                      label: const Text(
                        'Copy Slip',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slipRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
