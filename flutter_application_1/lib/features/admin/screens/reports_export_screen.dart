import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../services/report_service.dart';
import '../widgets/dairy_portal_scaffold.dart';

class ReportsExportScreen extends StatefulWidget {
  const ReportsExportScreen({super.key});

  @override
  State<ReportsExportScreen> createState() => _ReportsExportScreenState();
}

class _ReportsExportScreenState extends State<ReportsExportScreen> {
  String _selectedReportType = ReportService.reportTypes.first;
  String _selectedCenter = 'All Centers';
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  String _generatedCsvPreview = '';

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  void _generatePreview() {
    setState(() {
      _generatedCsvPreview = ReportService.generateCsv(
        reportType: _selectedReportType,
        fromDate: _fromDate,
        toDate: _toDate,
        center: _selectedCenter,
      );
    });
  }

  void _downloadCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report generated: "$_selectedReportType.csv" ready for download!'),
        backgroundColor: AppTheme.brandGreen,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DairyPortalScaffold(
      activeRoute: '/dairy/reports',
      title: 'Reports & Data Exports',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Card
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
                  const Text('Report Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  // Report Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    decoration: const InputDecoration(
                      labelText: 'Select Report Category',
                      prefixIcon: Icon(Icons.assessment_outlined),
                    ),
                    items: ReportService.reportTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedReportType = val);
                        _generatePreview();
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Center Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCenter,
                    decoration: const InputDecoration(
                      labelText: 'Filter Center / Hub',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: ['All Centers', 'Behror Center', 'Jaipur Center', 'Ajmer Center', 'Sikar Center', 'Tonk Center'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCenter = val);
                        _generatePreview();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Pickers Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14),
                          label: Text('From: ${_fromDate.day}/${_fromDate.month}/${_fromDate.year}', style: const TextStyle(fontSize: 12)),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime(2022),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) {
                              setState(() => _fromDate = d);
                              _generatePreview();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event, size: 14),
                          label: Text('To: ${_toDate.day}/${_toDate.month}/${_toDate.year}', style: const TextStyle(fontSize: 12)),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _toDate,
                              firstDate: DateTime(2022),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) {
                              setState(() => _toDate = d);
                              _generatePreview();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _downloadCsv,
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.print_outlined, size: 16),
                        label: const Text('Print Summary'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.brandTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Print preview rendered for thermal and A4 printer.')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Preview Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Data Preview & Verification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.cardMint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Live CSV Stream', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        _generatedCsvPreview,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
