import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/export_helper.dart';
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
    final cleanName = _selectedReportType.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final now = DateTime.now();
    final filename = '${cleanName}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';

    ExportHelper.downloadFile(filename: filename, content: _generatedCsvPreview);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.file_download_done, color: AppTheme.brandGreen, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Report Downloaded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $filename', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              const Text('Location: Saved directly to your device Downloads folder.', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download Again'),
                      onPressed: () {
                        ExportHelper.downloadFile(filename: filename, content: _generatedCsvPreview);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Share / Copy CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedCsvPreview));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report copied to clipboard! Ready to paste into Excel or messaging apps.'),
                            backgroundColor: AppTheme.brandGreen,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
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

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brandGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _downloadCsv,
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.print_outlined, size: 16),
                        label: const Text('Print Summary'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.brandTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Data Preview & Verification',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: const Text('Live CSV Stream', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
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
