import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/call_helper.dart';
import '../../../core/utils/export_helper.dart';
import '../data/dispatch_repository.dart';
import '../models/dispatch_record.dart';
import '../services/report_service.dart';
import 'status_badge.dart';

class DesktopDispatchTable extends StatefulWidget {
  final VoidCallback onNewDispatch;

  const DesktopDispatchTable({super.key, required this.onNewDispatch});

  @override
  State<DesktopDispatchTable> createState() => _DesktopDispatchTableState();
}

class _DesktopDispatchTableState extends State<DesktopDispatchTable> {
  final _dispatchRepo = DispatchRepository.instance;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  List<DispatchRecord> get _filteredRecords {
    return _dispatchRepo.dispatches.where((d) {
      final matchesSearch = d.vehicleNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.driverName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.fromLocation.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' || d.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _exportDispatches() {
    final records = _filteredRecords;
    final csv = ReportService.generateDispatchRegisterCsv(records);
    final now = DateTime.now();
    final filename =
        'tanker_dispatch_register_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';

    // 1. Trigger actual browser / device download
    ExportHelper.downloadFile(filename: filename, content: csv);

    // 2. Open interactive Download & Share dialog
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
              child: Text(
                'Report Exported Successfully',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.creamSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            filename,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.cardMint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${records.length} Records',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.folder_outlined, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 6),
                        Text(
                          'Destination: Saved to your device Downloads folder.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 6),
                        Text(
                          'Includes: Date, Time, Tanker No, Driver, Origin, Destination, Volume & Temp.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Options for this Export:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.file_download, size: 16),
                      label: const Text('Download Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.brandGreen,
                        side: const BorderSide(color: AppTheme.brandGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ExportHelper.downloadFile(filename: filename, content: csv);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading "$filename" again to your device...'),
                            backgroundColor: AppTheme.brandGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: csv));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CSV report copied to clipboard! Ready to share or paste into Excel/WhatsApp/Email.'),
                            backgroundColor: AppTheme.brandGreen,
                            duration: Duration(seconds: 3),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTimelineModal(DispatchRecord d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: AppTheme.brandTeal),
                const SizedBox(width: 10),
                Text('${d.vehicleNo} - Logistics Journey', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            StatusBadge(status: d.status, fontSize: 13),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver: ${d.driverName} • ${d.driverPhone}', style: TextStyle(color: Colors.grey.shade700)),
              Text('Route: ${d.fromLocation} → ${d.toDestination}', style: TextStyle(color: Colors.grey.shade700)),
              Text('Payload: ${d.loadedLitres} L (Chilled at ${d.temperature}°C)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              const Text('6-Stage Transport Milestones:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              ...List.generate(d.timeline.length, (idx) {
                final step = d.timeline[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        step.isCompleted ? Icons.check_circle : (step.isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                        color: step.isCompleted ? AppTheme.brandGreen : (step.isCurrent ? const Color(0xFF0288D1) : Colors.grey.shade400),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(step.stageName, style: TextStyle(fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.normal)),
                      const Spacer(),
                      Text(step.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          if (d.status == 'En Route')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandGreen, foregroundColor: Colors.white),
              onPressed: () {
                _dispatchRepo.updateDispatchStatus(d.id, 'Delivered', 5);
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Confirm Factory Delivery'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Toolbar
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.creamSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.creamBorder),
                  ),
                  child: Icon(Icons.local_shipping_outlined, color: AppTheme.textPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanker Logistics & Dispatch Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Daily insulated milk road transit records from chilling centers',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const Spacer(),

                // Search box
                SizedBox(
                  width: 220,
                  height: 38,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search tanker / driver...',
                      hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      prefixIcon: Icon(Icons.search, size: 17, color: AppTheme.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.creamBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.creamBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.creamBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      dropdownColor: AppTheme.cardSurface,
                      style: TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                      items: ['All', 'En Route', 'Delivered', 'Dispatched', 'Loading'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Export Button
                OutlinedButton.icon(
                  onPressed: _exportDispatches,
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: AppTheme.creamBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),

                // New Dispatch Button
                ElevatedButton.icon(
                  onPressed: widget.onNewDispatch,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Tanker Dispatch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5132),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.creamBorder),

          // Responsive Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppTheme.creamSurface),
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: [
                DataColumn(label: Text('DATE & TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('TANKER NO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('DRIVER & CONTACT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('ORIGIN CENTER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('DESTINATION PLANT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('LOADED LITRES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('TEMP (°C)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.4))),
              ],
              rows: records.map((d) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${d.dispatchedAt.day.toString().padLeft(2, '0')}/${d.dispatchedAt.month.toString().padLeft(2, '0')}/${d.dispatchedAt.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          Text(
                            '${d.dispatchedAt.hour.toString().padLeft(2, '0')}:${d.dispatchedAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_bus, size: 16, color: AppTheme.brandTeal),
                          const SizedBox(width: 8),
                          Text(d.vehicleNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(d.driverName, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, size: 15, color: AppTheme.brandGreen),
                            tooltip: 'Call Driver (${d.driverPhone})',
                            onPressed: () => CallHelper.showCallChooser(
                              context,
                              name: d.driverName,
                              phone: d.driverPhone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(d.fromLocation, style: const TextStyle(fontSize: 13))),
                    DataCell(Text(d.toDestination, style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Text(
                        '${d.loadedLitres} L / ${d.capacityLitres} L',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: d.temperature <= 4.5 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${d.temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: d.temperature <= 4.5 ? AppTheme.brandGreenDark : const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ),
                    DataCell(StatusBadge(status: d.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showTimelineModal(d),
                            child: const Text('Timeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
                          ),
                          if (d.status == 'En Route')
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.brandGreen),
                              tooltip: 'Mark Delivered',
                              onPressed: () {
                                _dispatchRepo.updateDispatchStatus(d.id, 'Delivered', 5);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('No tanker dispatch records matching filters', style: TextStyle(color: Colors.grey.shade500)),
              ),
            ),
        ],
      ),
    );
  }
}
