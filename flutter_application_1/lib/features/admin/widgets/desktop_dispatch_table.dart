import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/call_helper.dart';
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
    final csv = ReportService.generateCsv(
      reportType: 'Dispatch & Logistics Register',
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now(),
      center: 'All Centers',
    );
    assert(csv.isNotEmpty);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dispatches exported successfully (${_filteredRecords.length} records ready)!'),
        backgroundColor: AppTheme.brandGreen,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                    color: AppTheme.cardSky,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: AppTheme.brandTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanker Logistics & Dispatch Register',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Daily insulated milk road transit records from chilling centers',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search tanker / driver...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
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
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
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
                    foregroundColor: AppTheme.brandGreen,
                    side: const BorderSide(color: AppTheme.brandGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),

                // New Dispatch Button
                ElevatedButton.icon(
                  onPressed: widget.onNewDispatch,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Tanker Dispatch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Responsive Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('TANKER NO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DRIVER & CONTACT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ORIGIN CENTER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('DESTINATION PLANT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('LOADED LITRES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('TEMP (°C)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              ],
              rows: records.map((d) {
                return DataRow(
                  cells: [
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
