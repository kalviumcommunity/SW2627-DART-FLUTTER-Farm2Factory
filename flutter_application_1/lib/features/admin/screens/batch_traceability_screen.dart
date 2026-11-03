import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/batch.dart';
import '../../../services/batch_service.dart';
import '../widgets/status_badge.dart';

class BatchTraceabilityScreen extends StatefulWidget {
  const BatchTraceabilityScreen({super.key});

  @override
  State<BatchTraceabilityScreen> createState() =>
      _BatchTraceabilityScreenState();
}

class _BatchTraceabilityScreenState extends State<BatchTraceabilityScreen> {
  final BatchService _batchService = BatchService();
  bool _isLoading = true;
  List<Batch> _batches = [];
  final String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    final batches = await _batchService.getBatches(
      status: _filter == 'All' ? null : _filter,
    );
    if (!mounted) return;
    setState(() {
      _batches = batches;
      _isLoading = false;
    });
  }

  void _showTraceabilityModal(Batch batch) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FutureBuilder<BatchTraceabilityReport>(
        future: _batchService.traceBatchSources(batch.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to trace batch: ${snapshot.error}'),
                ],
              ),
            );
          }

          final report = snapshot.data!;
          final isRejected = report.batch.isRejected;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hub_outlined,
                                  color: AppTheme.brandGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.batch.id,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Center: ${report.batch.centerName} • ${report.batch.shift}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: report.batch.status),
                  ],
                ),
                const Divider(height: 24),

                // Traceability banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRejected
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRejected
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: isRejected ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          report.traceabilitySummary,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isRejected
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quality breakdown
                Row(
                  children: [
                    _qualityStat(
                        'Total Volume', '${report.batch.totalLitres} L'),
                    _qualityStat(
                        'Avg FAT', '${report.batch.averageFat}%'),
                    _qualityStat(
                        'Avg SNF', '${report.batch.averageSnf}%'),
                    _qualityStat('Avg Temp',
                        '${report.batch.averageTemperature}°C'),
                  ],
                ),
                const SizedBox(height: 16),

                // Suspect collections section if rejected
                if (report.flaggedEntries.isNotEmpty) ...[
                  Text(
                    '⚠️ Contributing Suspect Collections (${report.flaggedEntries.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: report.flaggedEntries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${e.farmerName} (${e.farmerCode}) • ${e.quantityLitres} L',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                'FAT: ${e.fatPercentage}% | SNF: ${e.snfPercentage}% | ${e.temperature}°C',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contributing Farmers list
                Text(
                  'Source Collections (${report.sourceEntries.length} entries from ${report.totalFarmers} farmers)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.builder(
                    itemCount: report.sourceEntries.length,
                    itemBuilder: (context, idx) {
                      final entry = report.sourceEntries[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.farmerName} (${entry.farmerCode})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${entry.milkType.toUpperCase()} • FAT: ${entry.fatPercentage}% | SNF: ${entry.snfPercentage}% | ${entry.temperature}°C',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${entry.quantityLitres} L',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brandGreenDark,
                                  ),
                                ),
                                Text(
                                  '₹${entry.totalAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                // Action Buttons for Quality Inspector
                Row(
                  children: [
                    if (!report.batch.isAccepted)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await _batchService.updateBatchStatus(
                              batchId: report.batch.id,
                              status: 'ACCEPTED',
                              testedBy: 'Quality Lab Lead',
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _loadBatches();
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Accept Batch'),
                        ),
                      ),
                    if (!report.batch.isAccepted && !report.batch.isRejected)
                      const SizedBox(width: 10),
                    if (!report.batch.isRejected)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await _batchService.updateBatchStatus(
                              batchId: report.batch.id,
                              status: 'REJECTED',
                              rejectionReason: report.flaggedEntries.isNotEmpty
                                  ? 'Quality threshold shortfall detected in source entries'
                                  : 'Plant quality check failed',
                              testedBy: 'Quality Lab Lead',
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            _loadBatches();
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject Batch'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qualityStat(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Text(value,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Batch Traceability',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'No Batches Dispatched Yet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Dispatch batches from the Milk Collection screen.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _batches.length,
                  itemBuilder: (context, idx) {
                    final batch = _batches[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showTraceabilityModal(batch),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.brandGreen
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.local_shipping_outlined,
                                              color: AppTheme.brandGreen,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                batch.id,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${batch.centerName} • ${batch.shift}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: batch.status),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                      Text('${batch.totalLitres} L',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Avg FAT',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                      Text('${batch.averageFat}%',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Avg SNF',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                      Text('${batch.averageSnf}%',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Sources',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600)),
                                      Text('${batch.farmerIds.length} farmers',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tanker: ${batch.tankerNumber ?? "N/A"}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                  const Row(
                                    children: [
                                      Text('Trace Sources',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.brandGreen,
                                              fontWeight: FontWeight.bold)),
                                      Icon(Icons.chevron_right,
                                          size: 16,
                                          color: AppTheme.brandGreen),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
