import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/reconciliation_statement.dart';
import '../../../services/reconciliation_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ReconciliationService _reconciliationService = ReconciliationService();

  bool _isLoading = true;
  ReconciliationCycleSummary? _summary;
  int _selectedCycleIndex = 1; // Default to Middle 10-day cycle

  final List<Map<String, dynamic>> _cycles = [
    {
      'label': '01 - 10 Oct',
      'start': DateTime(2026, 10, 1),
      'end': DateTime(2026, 10, 10),
    },
    {
      'label': '11 - 20 Oct',
      'start': DateTime(2026, 10, 11),
      'end': DateTime(2026, 10, 20),
    },
    {
      'label': '21 - 31 Oct',
      'start': DateTime(2026, 10, 21),
      'end': DateTime(2026, 10, 31),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadReconciliation();
  }

  Future<void> _loadReconciliation() async {
    setState(() => _isLoading = true);
    final active = _cycles[_selectedCycleIndex];
    final summary = await _reconciliationService.getReconciliationForCycle(
      startDate: active['start'] as DateTime,
      endDate: active['end'] as DateTime,
    );

    if (!mounted) return;
    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  void _showDisputeResolutionDialog(FarmerReconciliationStatement statement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statement.farmerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${statement.farmerId} • Cycle: ${_summary?.cycleLabel ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.brandGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol('Total Milk', '${statement.totalLitres} L'),
                    _metricCol('Avg FAT', '${statement.avgFat}%'),
                    _metricCol('Avg SNF', '${statement.avgSnf}%'),
                    _metricCol('Net Payable', '₹ ${statement.netPayable.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Shift-by-Shift Audit Log (Eliminates Disputes)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: statement.entries.isEmpty
                    ? Center(
                        child: Text(
                          'No entry breakdown records available.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: statement.entries.length,
                        itemBuilder: (context, idx) {
                          final e = statement.entries[idx];
                          final formattedDate =
                              '${e.date.day}/${e.date.month}/${e.date.year}';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  e.shift.contains('Morning')
                                      ? Icons.wb_sunny_outlined
                                      : Icons.nightlight_round_outlined,
                                  color: e.shift.contains('Morning')
                                      ? Colors.amber.shade700
                                      : Colors.indigo,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$formattedDate • ${e.shift}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'FAT ${e.fatPercentage}%  |  SNF ${e.snfPercentage}%  |  ₹${e.ratePerLitre.toStringAsFixed(1)}/L',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${e.quantityLitres} L',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₹ ${e.totalAmount.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.brandGreenDark,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Statement Reconciled & Disbursed'),
                  onPressed: () async {
                    await _reconciliationService.disburseStatement(statement);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payout for ${statement.farmerName} recorded!'),
                        backgroundColor: AppTheme.brandGreen,
                      ),
                    );
                    _loadReconciliation();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _exportCsv() {
    if (_summary == null) return;
    final csv = _reconciliationService.generateNeftCsv(_summary!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Bank NEFT Reconciliation CSV', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brandGreen),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reconciliation statement exported to CSV!'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
            },
            child: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.collectorDashboard),
        ),
        title: const Text(
          'Reconciliation & Payouts',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Export Bank NEFT CSV',
            icon: const Icon(Icons.file_download_outlined, color: AppTheme.brandGreen),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: _loadReconciliation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReconciliation,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cycle Switcher Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_cycles.length, (idx) {
                        final isSelected = _selectedCycleIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_cycles[idx]['label'] as String),
                            selected: isSelected,
                            selectedColor: AppTheme.brandGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCycleIndex = idx);
                                _loadReconciliation();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Hero Payout Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cycle Reconciliation Status',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _summary?.cycleLabel ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹ ${_summary?.totalPayable.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _whiteCol('Total Volume', '${_summary?.totalLitres ?? 0} L'),
                            _whiteCol('Farmers', '${_summary?.farmerCount ?? 0}'),
                            _whiteCol('Collections', '${_summary?.totalCollections ?? 0}'),
                            _whiteCol('Pending', '${_summary?.pendingPayouts ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Farmer Reconciliation Statements',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.bolt, size: 16, color: AppTheme.brandGreen),
                        label: const Text('Disburse All', style: TextStyle(fontSize: 12, color: AppTheme.brandGreen)),
                        onPressed: () async {
                          if (_summary != null) {
                            await _reconciliationService.disburseAllEligible(_summary!.statements);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All pending statements marked as disbursed!'),
                                backgroundColor: AppTheme.brandGreen,
                              ),
                            );
                            _loadReconciliation();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_summary == null || _summary!.statements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No statements for this cycle', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  else
                    ..._summary!.statements.map((s) => _farmerReconciliationCard(s)),
                ],
              ),
            ),
    );
  }

  Widget _whiteCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _farmerReconciliationCard(FarmerReconciliationStatement s) {
    final bool isDisbursed = s.isDisbursed;
    final bool hasDispute = s.hasDispute;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasDispute ? Colors.amber.shade300 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: hasDispute
              ? Colors.amber.shade100
              : isDisbursed
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
          child: Text(
            s.farmerName.isNotEmpty ? s.farmerName[0] : 'F',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasDispute
                  ? Colors.amber.shade800
                  : isDisbursed
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
            ),
          ),
        ),
        title: Text(
          s.farmerName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${s.farmerId} • ${s.totalLitres} L (${s.totalCollections} entries)',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              'FAT: ${s.avgFat}% | SNF: ${s.avgSnf}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹ ${s.netPayable.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.brandGreenDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDisbursed
                    ? Colors.green.shade50
                    : hasDispute
                        ? Colors.amber.shade50
                        : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDisbursed
                      ? Colors.green.shade200
                      : hasDispute
                          ? Colors.amber.shade300
                          : Colors.orange.shade200,
                ),
              ),
              child: Text(
                s.status,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: isDisbursed
                      ? Colors.green.shade800
                      : hasDispute
                          ? Colors.amber.shade900
                          : Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showDisputeResolutionDialog(s),
      ),
    );
  }
}
