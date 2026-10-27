import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/dispute.dart';
import '../../../services/dispute_service.dart';
import '../widgets/dairy_filter_bar.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/dairy_stat_card.dart';

class DisputeManagementScreen extends StatefulWidget {
  const DisputeManagementScreen({super.key});

  @override
  State<DisputeManagementScreen> createState() =>
      _DisputeManagementScreenState();
}

class _DisputeManagementScreenState extends State<DisputeManagementScreen> {
  final _disputeService = DisputeService.instance;

  String _selectedStatus = 'All';
  String _selectedCenter = 'All Centers';
  String _searchQuery = '';
  bool _isLoading = true;
  List<Dispute> _disputes = [];

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoading = true);
    final list = await _disputeService.getAllDisputes();
    if (mounted) {
      setState(() {
        _disputes = list;
        _isLoading = false;
      });
    }
  }

  List<Dispute> get _filteredDisputes {
    return _disputes.where((d) {
      if (_selectedStatus != 'All' &&
          d.status.toUpperCase() != _selectedStatus.toUpperCase()) {
        return false;
      }
      if (_selectedCenter != 'All Centers' &&
          !d.centerId.toLowerCase().contains(
              _selectedCenter.toLowerCase().replaceAll(' center', ''))) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = d.farmerName.toLowerCase().contains(q) ||
            d.farmerId.toLowerCase().contains(q) ||
            d.id.toLowerCase().contains(q) ||
            d.farmerPhone.contains(q) ||
            d.disputeType.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  void _showResolutionDialog(Dispute dispute, bool isApprove) {
    final noteCtrl = TextEditingController(
      text: isApprove
          ? 'Difference verified against center lab log. Approved payout adjustment.'
          : 'Reading verified with calibrated equipment. Rejection upheld under FSSAI rules.',
    );
    final amountCtrl = TextEditingController(
      text: isApprove
          ? (dispute.quantityDifference > 0
                  ? (dispute.quantityDifference * 48.0)
                  : 75.0)
              .toStringAsFixed(2)
          : '0.0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? AppTheme.brandGreen : Colors.redAccent,
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Approve & Settle Dispute' : 'Reject Dispute',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farmer: ${dispute.farmerName} (${dispute.farmerId})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Dispute ID: ${dispute.id} • ${dispute.shift}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (isApprove) ...[
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Payout Credit Adjustment (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                    hintText: 'e.g. 150.00',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isApprove
                      ? 'Resolution Audit Notes'
                      : 'Rejection Justification',
                  hintText: 'Enter formal reason for audit statement...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isApprove ? AppTheme.brandGreen : Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final note = noteCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              final newStatus = isApprove ? 'RESOLVED' : 'REJECTED';

              await _disputeService.resolveDispute(
                disputeId: dispute.id,
                status: newStatus,
                resolutionNote: note,
                adjustedAmount: isApprove ? amount : 0.0,
                resolvedBy: 'Dairy Quality Audit Lead',
              );

              if (context.mounted) {
                Navigator.pop(context);
                _loadDisputes();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isApprove
                          ? 'Dispute ${dispute.id} approved! ₹${amount.toStringAsFixed(2)} credited.'
                          : 'Dispute ${dispute.id} marked as rejected.',
                    ),
                    backgroundColor:
                        isApprove ? AppTheme.brandGreen : Colors.redAccent,
                  ),
                );
              }
            },
            child: Text(isApprove ? 'Confirm Settlement' : 'Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  void _markUnderReview(Dispute dispute) async {
    await _disputeService.resolveDispute(
      disputeId: dispute.id,
      status: 'UNDER_REVIEW',
      resolutionNote: 'Collector and sample verification initiated.',
      adjustedAmount: 0.0,
      resolvedBy: 'Field Supervisor',
    );
    _loadDisputes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dispute.id} is now under field review.'),
          backgroundColor: const Color(0xFF0288D1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = _disputes;
    final openCount = all.where((d) => d.isOpen).length;
    final underReviewCount = all.where((d) => d.isUnderReview).length;
    final resolvedCount = all.where((d) => d.isResolved).length;
    final totalAdjustments = all.fold(0.0, (sum, d) => sum + d.adjustedAmount);

    final filtered = _filteredDisputes;

    return DairyPortalScaffold(
      activeRoute: AppRoutes.dairyDisputes,
      title: 'Disputes & Audit Resolution',
      actions: [
        IconButton(
          tooltip: 'Sync Disputes',
          icon: const Icon(Icons.refresh, color: AppTheme.brandGreen),
          onPressed: _loadDisputes,
        ),
      ],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.brandGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Bar
                  DairyFilterBar(
                    selectedDateFilter: 'Today',
                    selectedCenter: _selectedCenter,
                    searchHint: 'Search dispute by farmer, ID, phone...',
                    onDateFilterChanged: (_) {},
                    onCenterChanged: (c) => setState(() => _selectedCenter = c),
                    onSearchChanged: (q) => setState(() => _searchQuery = q),
                  ),
                  const SizedBox(height: 18),

                  // KPI Summary Grid
                  LayoutBuilder(builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: crossAxisCount == 4 ? 1.4 : 1.18,
                      children: [
                        DairyStatCard(
                          icon: Icons.gavel,
                          iconColor: const Color(0xFF7B1FA2),
                          title: 'Total Disputes',
                          value: '${all.length} Logged',
                          subtitle: 'Digital audit trail active',
                          cardBgColor: AppTheme.cardLavender,
                        ),
                        DairyStatCard(
                          icon: Icons.hourglass_top_outlined,
                          iconColor: const Color(0xFFE65100),
                          title: 'Pending Inquiries',
                          value: '$openCount Open',
                          subtitle: '$underReviewCount under review',
                          badgeText: openCount > 0 ? 'Action Req.' : null,
                          badgeColor: const Color(0xFFE65100),
                          cardBgColor: AppTheme.cardPeach,
                        ),
                        DairyStatCard(
                          icon: Icons.check_circle_outline,
                          iconColor: AppTheme.brandGreen,
                          title: 'Resolved Cases',
                          value: '$resolvedCount Settled',
                          subtitle: '100% auditable logs',
                          cardBgColor: AppTheme.cardMint,
                        ),
                        DairyStatCard(
                          icon: Icons.currency_rupee,
                          iconColor: const Color(0xFF0288D1),
                          title: 'Adjustments Credited',
                          value: '₹ ${totalAdjustments.toStringAsFixed(0)}',
                          subtitle: 'Reconciled to payouts',
                          cardBgColor: AppTheme.cardSky,
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 22),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'OPEN',
                        'UNDER_REVIEW',
                        'RESOLVED',
                        'REJECTED'
                      ].map((st) {
                        final isSelected = _selectedStatus == st;
                        String label = st;
                        if (st == 'All') label = 'All (${all.length})';
                        if (st == 'OPEN') label = 'Open ($openCount)';
                        if (st == 'UNDER_REVIEW') {
                          label = 'Under Review ($underReviewCount)';
                        }
                        if (st == 'RESOLVED') {
                          label = 'Resolved ($resolvedCount)';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(label),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.brandGreen,
                            onSelected: (_) =>
                                setState(() => _selectedStatus = st),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contested Milk Collections (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Resolution Ceiling: < 24h',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dispute Cards List
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final dispute = filtered[idx];
                        return _buildDisputeCard(context, dispute);
                      },
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.verified_user_outlined,
              size: 48, color: AppTheme.brandGreen.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          const Text(
            'Zero Disputes Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'All collection center readings are reconciled and in full agreement.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard(BuildContext context, Dispute d) {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    switch (d.status.toUpperCase()) {
      case 'OPEN':
        statusBg = const Color(0xFFFFF3E0);
        statusText = const Color(0xFFE65100);
        statusIcon = Icons.hourglass_top;
        break;
      case 'UNDER_REVIEW':
        statusBg = const Color(0xFFE1F5FE);
        statusText = const Color(0xFF0288D1);
        statusIcon = Icons.search;
        break;
      case 'RESOLVED':
        statusBg = const Color(0xFFE8F5E9);
        statusText = AppTheme.brandGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
      default:
        statusBg = const Color(0xFFFFEBEE);
        statusText = Colors.redAccent;
        statusIcon = Icons.cancel;
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(d.collectionDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID + Status + Dispute Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.id,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLavender,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.disputeType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C6BC0),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusText),
                      const SizedBox(width: 4),
                      Text(
                        d.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Farmer & Collection Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.brandGreen.withValues(alpha: 0.12),
                  child: Text(
                    d.farmerName.isNotEmpty ? d.farmerName[0] : 'F',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandGreen,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.farmerName} (${d.farmerId})',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${d.centerId} • $dateStr (${d.shift})',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call Farmer',
                  icon: const Icon(Icons.phone_outlined,
                      color: AppTheme.brandGreen, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${d.farmerName} (${d.farmerPhone})...'),
                        backgroundColor: AppTheme.brandGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reading Comparison Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recorded at Center',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.recordedQuantity.toStringAsFixed(1)} L  •  ${d.recordedFat.toStringAsFixed(1)}% FAT',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        Text(
                          'SNF: ${d.recordedSnf.toStringAsFixed(1)}% | ₹${d.recordedAmount.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farmer Claim',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(d.claimedQuantity ?? d.recordedQuantity).toStringAsFixed(1)} L  •  ${(d.claimedFat ?? d.recordedFat).toStringAsFixed(1)}% FAT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        Text(
                          d.quantityDifference != 0
                              ? 'Variance: ${(d.quantityDifference > 0 ? "+" : "")}${d.quantityDifference.toStringAsFixed(1)} L'
                              : 'Variance: ${(d.fatDifference > 0 ? "+" : "")}${d.fatDifference.toStringAsFixed(1)}% FAT',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Reason Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '"${d.reason}"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),

            // Resolution Box (if resolved/rejected)
            if (d.resolutionNote != null && d.resolutionNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: d.isResolved
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: d.isResolved
                        ? AppTheme.brandGreen.withValues(alpha: 0.3)
                        : Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          d.isResolved ? 'Audit Settlement Note' : 'Rejection Reason',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: d.isResolved
                                ? AppTheme.brandGreenDark
                                : Colors.redAccent,
                          ),
                        ),
                        if (d.adjustedAmount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.brandGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+ ₹${d.adjustedAmount.toStringAsFixed(2)} Credited',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.resolutionNote!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (if open or under review)
            if (d.isOpen || d.isUnderReview) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                            color: Colors.redAccent.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject',
                          style: TextStyle(fontSize: 12)),
                      onPressed: () => _showResolutionDialog(d, false),
                    ),
                  ),
                  if (d.isOpen) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0288D1),
                          side: const BorderSide(color: Color(0xFF0288D1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Review',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () => _markUnderReview(d),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve & Credit',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showResolutionDialog(d, true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
