import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/reconciliation_statement.dart';
import '../../../services/reconciliation_service.dart';
import '../data/dairy_payment_repository.dart';
import '../models/dairy_payment.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/dairy_stat_card.dart';
import '../widgets/status_badge.dart';
import '../../../core/routes/app_router.dart';

class DairyPaymentsScreen extends StatefulWidget {
  const DairyPaymentsScreen({super.key});

  @override
  State<DairyPaymentsScreen> createState() => _DairyPaymentsScreenState();
}

class _DairyPaymentsScreenState extends State<DairyPaymentsScreen> {
  final _paymentRepo = DairyPaymentRepository.instance;
  final ReconciliationService _reconciliationService = ReconciliationService();

  String _selectedCycle = '10 Days';
  String _selectedTypeFilter = 'All';

  ReconciliationCycleSummary? _farmerSummary;
  bool _isLoadingFarmers = false;

  @override
  void initState() {
    super.initState();
    _loadFarmerReconciliation();
  }

  Future<void> _loadFarmerReconciliation() async {
    setState(() => _isLoadingFarmers = true);
    final now = DateTime.now();
    try {
      final summary = await _reconciliationService.getReconciliationForCycle(
        startDate: DateTime(now.year, now.month, 11),
        endDate: DateTime(now.year, now.month, 20),
      );
      if (!mounted) return;
      setState(() {
        _farmerSummary = summary;
        _isLoadingFarmers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingFarmers = false);
    }
  }

  List<DairyPayment> get _filteredPayments {
    if (_selectedTypeFilter == 'All') return _paymentRepo.payments;
    return _paymentRepo.payments
        .where((p) =>
            p.recipientType.toLowerCase() == _selectedTypeFilter.toLowerCase())
        .toList();
  }

  void _showPaymentConfirmationDialog(BuildContext context, DairyPayment p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Confirm Payout Disbursal',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipient: ${p.recipientName} (${p.recipientType})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Center: ${p.centerOrLocation}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 18),
            _dialogRow('Total Milk Supplied', '${p.totalLitres.toInt()} Litres'),
            _dialogRow('Base Rate per Litre', 'â‚¹ ${p.ratePerLitre}'),
            _dialogRow('Gross Calculation', 'â‚¹ ${p.grossAmount.toInt()}'),
            _dialogRow('Adjustments / Bonus', 'â‚¹ ${p.adjustments.toInt()}'),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Final Disbursal Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('â‚¹ ${p.finalAmount.toInt()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppTheme.brandGreenDark)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.blueGrey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        'Simulated NEFT payment gateway. Direct bank transfer will be scheduled.',
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ),
                ],
              ),
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
              _paymentRepo.markAsPaid(p.id);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Payment of â‚¹ ${p.finalAmount.toInt()} settled successfully!'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
            },
            child: const Text('Approve & Disburse'),
          ),
        ],
      ),
    );
  }

  void _showFarmerDisbursalDialog(FarmerReconciliationStatement s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Disburse Farmer Payout',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: ${s.farmerName} (${s.farmerId})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Center: ${s.center}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 18),
            _dialogRow('Total Volume', '${s.totalLitres} Litres'),
            _dialogRow('Average Quality', 'FAT ${s.avgFat}%  |  SNF ${s.avgSnf}%'),
            _dialogRow('Collections Recorded', '${s.totalCollections} Shifts'),
            _dialogRow('Gross Payout', 'â‚¹ ${s.grossPayable}'),
            _dialogRow('Deductions / Penalties', 'â‚¹ ${s.deductions}'),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Disbursal Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('â‚¹ ${s.netPayable.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppTheme.brandGreenDark)),
              ],
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
            onPressed: () async {
              await _reconciliationService.disburseStatement(s);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Disbursed â‚¹ ${s.netPayable.toInt()} to ${s.farmerName}!'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
              _loadFarmerReconciliation();
            },
            child: const Text('Confirm NEFT Transfer'),
          ),
        ],
      ),
    );
  }

  void _exportCsv() {
    if (_farmerSummary == null) return;
    final csv = _reconciliationService.generateNeftCsv(_farmerSummary!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Bank NEFT Export CSV', style: TextStyle(fontSize: 16)),
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
                  content: Text('Exported Bank NEFT CSV!'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredPayments;
    final isFarmersTab = _selectedTypeFilter == 'Farmers';

    return DairyPortalScaffold(
      activeRoute: AppRoutes.adminPayments,
      title: 'Payments & Settlement',
      portalType: DairyPortalType.admin,
      actions: [
        IconButton(
          tooltip: 'Export Bank NEFT CSV',
          icon: const Icon(Icons.file_download_outlined,
              color: AppTheme.brandGreen),
          onPressed: _exportCsv,
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh, color: AppTheme.brandGreen),
          onPressed: () {
            setState(() {});
            _loadFarmerReconciliation();
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Cards
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  MediaQuery.of(context).size.width > 700 ? 1.4 : 1.18,
              children: [
                DairyStatCard(
                  icon: Icons.hourglass_empty,
                  iconColor: const Color(0xFFE65100),
                  title: isFarmersTab ? 'Farmer Pending' : 'Pending Payout',
                  value: isFarmersTab
                      ? 'â‚¹ ${_farmerSummary?.totalPayable.toInt() ?? 0}'
                      : 'â‚¹ ${_paymentRepo.totalPendingPayout.toInt()}',
                  subtitle: isFarmersTab
                      ? '${_farmerSummary?.farmerCount ?? 0} farmers reconciled'
                      : '${_paymentRepo.pendingCollectorsCount} pending settlements',
                  badgeText: 'Action Req',
                  badgeColor: const Color(0xFFE65100),
                  cardBgColor: AppTheme.cardPeach,
                ),
                DairyStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.brandGreen,
                  title: isFarmersTab ? 'Reconciled Volume' : 'Paid This Week',
                  value: isFarmersTab
                      ? '${_farmerSummary?.totalLitres.toInt() ?? 0} L'
                      : 'â‚¹ ${_paymentRepo.totalPaidThisWeek.toInt()}',
                  subtitle: isFarmersTab ? '10-Day Cycle' : 'Direct NEFT RTGS',
                  cardBgColor: AppTheme.cardMint,
                ),
                DairyStatCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF0288D1),
                  title: 'Cycle Label',
                  value: isFarmersTab
                      ? (_farmerSummary?.cycleLabel ?? '11-20 Oct')
                      : '10th Oct 2026',
                  subtitle: 'Cycle #3',
                  cardBgColor: AppTheme.cardSky,
                ),
                DairyStatCard(
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF5C6BC0),
                  title: 'Total Collections',
                  value: isFarmersTab
                      ? '${_farmerSummary?.totalCollections ?? 0}'
                      : 'â‚¹ ${_paymentRepo.totalPaidThisMonth.toInt()}',
                  subtitle: '100% verified payouts',
                  cardBgColor: AppTheme.cardLavender,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Settlement Cycle Selector
            Row(
              children: [
                const Text('Cycle:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Weekly', '10 Days', 'Monthly', 'Custom']
                          .map((cyc) {
                        final isSelected = _selectedCycle == cyc;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(cyc),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                            selectedColor: AppTheme.brandGreen,
                            onSelected: (_) =>
                                setState(() => _selectedCycle = cyc),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Filter (All, Collector, Seller, Farmers)
            Row(
              children: ['All', 'Collector', 'Seller', 'Farmers'].map((typ) {
                final isSelected = _selectedTypeFilter == typ;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(typ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    selectedColor: AppTheme.brandGreen,
                    onSelected: (_) =>
                        setState(() => _selectedTypeFilter = typ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Payout Transaction List (Farmers view vs Collector/Seller view)
            if (isFarmersTab) ...[
              if (_isLoadingFarmers)
                const Center(child: CircularProgressIndicator())
              else if (_farmerSummary == null ||
                  _farmerSummary!.statements.isEmpty)
                const Center(child: Text('No farmer statements for this cycle'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _farmerSummary!.statements.length,
                  itemBuilder: (context, idx) {
                    final s = _farmerSummary!.statements[idx];
                    final isPaid = s.isDisbursed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            s.farmerName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text('Farmer',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.farmerId} â€¢ ${s.center}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(status: s.status),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${s.totalLitres} L (${s.totalCollections} collections)',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    'FAT ${s.avgFat}% | SNF ${s.avgSnf}%',
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'â‚¹ ${s.netPayable.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (!isPaid) ...[
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.brandGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () =>
                                          _showFarmerDisbursalDialog(s),
                                      child: const Text('Approve',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ] else ...[
              // Standard Collector / Seller List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  final p = list[idx];
                  final isPending = p.status == 'Pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.recipientName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text(p.recipientType,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.recipientId} â€¢ ${p.centerOrLocation}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: p.status),
                          ],
                        ),
                        const Divider(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 380;
                            final detailsCol = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${p.totalLitres.toInt()} L @ â‚¹${p.ratePerLitre}/L',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey.shade700)),
                                Text('Ref: ${p.transactionReference}',
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.grey.shade500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            );

                            final actionRow = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: isNarrow
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Text('â‚¹ ${p.finalAmount.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0F172A))),
                                    Text(
                                        '${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500)),
                                  ],
                                ),
                                if (isPending) ...[
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.brandGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () =>
                                        _showPaymentConfirmationDialog(
                                            context, p),
                                    child: const Text('Disburse',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            );

                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  detailsCol,
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [actionRow],
                                  ),
                                ],
                              );
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: detailsCol),
                                const SizedBox(width: 8),
                                actionRow,
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
