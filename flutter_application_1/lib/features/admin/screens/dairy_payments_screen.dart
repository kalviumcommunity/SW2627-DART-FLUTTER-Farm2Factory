import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/export_helper.dart';
import '../data/dairy_payment_repository.dart';
import '../models/dairy_payment.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/dairy_stat_card.dart';
import '../widgets/status_badge.dart';

class DairyPaymentsScreen extends StatefulWidget {
  const DairyPaymentsScreen({super.key});

  @override
  State<DairyPaymentsScreen> createState() => _DairyPaymentsScreenState();
}

class _DairyPaymentsScreenState extends State<DairyPaymentsScreen> {
  final _paymentRepo = DairyPaymentRepository.instance;
  
  // Sheet Selector: 0 = Pending Approvals & Disbursal, 1 = Disbursed Payment History
  int _currentSheetIndex = 0;

  String _selectedCycle = '10 Days';
  String _selectedTypeFilter = 'All';
  String _historySearchQuery = '';
  String _historySortOption = 'Date: Newest First';

  List<DairyPayment> get _filteredPendingPayments {
    final pending = _paymentRepo.pendingPayments;
    return pending.where((p) {
      final matchesType = _selectedTypeFilter == 'All' ||
          p.recipientType.toLowerCase() == _selectedTypeFilter.toLowerCase();
      final matchesCycle = _selectedCycle == 'Custom' || p.paymentCycle == _selectedCycle;
      return matchesType && matchesCycle;
    }).toList();
  }

  List<DairyPayment> get _sortedPaymentHistory {
    var list = _paymentRepo.paymentHistory.where((p) {
      final matchesSearch = p.recipientName.toLowerCase().contains(_historySearchQuery.toLowerCase()) ||
          p.recipientId.toLowerCase().contains(_historySearchQuery.toLowerCase()) ||
          p.transactionReference.toLowerCase().contains(_historySearchQuery.toLowerCase()) ||
          p.centerOrLocation.toLowerCase().contains(_historySearchQuery.toLowerCase());
      final matchesType = _selectedTypeFilter == 'All' ||
          p.recipientType.toLowerCase() == _selectedTypeFilter.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();

    switch (_historySortOption) {
      case 'Date: Newest First':
        list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
        break;
      case 'Date: Oldest First':
        list.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
        break;
      case 'Amount: High to Low':
        list.sort((a, b) => b.finalAmount.compareTo(a.finalAmount));
        break;
      case 'Amount: Low to High':
        list.sort((a, b) => a.finalAmount.compareTo(b.finalAmount));
        break;
      case 'Recipient: A to Z':
        list.sort((a, b) => a.recipientName.compareTo(b.recipientName));
        break;
    }
    return list;
  }

  void _showPaymentConfirmationDialog(BuildContext context, DairyPayment p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Confirm Payout Disbursal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recipient: ${p.recipientName} (${p.recipientType})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Center: ${p.centerOrLocation} • Mobile: +91 ${p.recipientPhone}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('Beneficiary Bank: ${p.bankAccountMasked}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const Divider(height: 18),
              _dialogRow('Total Milk Supplied', '${p.totalLitres.toInt()} Litres'),
              _dialogRow('Base Rate per Litre', '₹ ${p.ratePerLitre}'),
              _dialogRow('Gross Calculation', '₹ ${p.grossAmount.toInt()}'),
              _dialogRow('Adjustments / Bonus', '₹ ${p.adjustments.toInt()}'),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Final Disbursal Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                  Text('₹ ${p.finalAmount.toInt()}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.accentGreen)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.creamSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF0284C7)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instant Notification Enabled: An automated SMS receipt & in-app payment alert will be dispatched to the recipient immediately.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final updated = _paymentRepo.disburseAndNotify(paymentId: p.id);
              setState(() {});
              if (updated != null) {
                _showDisbursedNotificationModal(context, updated);
              }
            },
            child: const Text('Approve & Disburse'),
          ),
        ],
      ),
    );
  }

  void _showDisbursedNotificationModal(BuildContext context, DairyPayment p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppTheme.brandGreen, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Payment Disbursed & Notified',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.brandGreen.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text('Amount Successfully Disbursed', style: TextStyle(fontSize: 11.5, color: AppTheme.accentGreen)),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${p.finalAmount.toInt()}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'UTR: ${p.transactionReference}',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Recipient Multi-Channel Notification Status:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildNotificationStatusRow(
                icon: Icons.chat_bubble_outline,
                title: 'In-App Payment Credit Notice',
                detail: 'Delivered to ${p.recipientName}\'s account (${p.recipientId})',
                status: 'Delivered',
              ),
              const SizedBox(height: 6),
              _buildNotificationStatusRow(
                icon: Icons.sms_outlined,
                title: 'Automated SMS Receipt',
                detail: 'Dispatched to registered mobile +91 ${p.recipientPhone}',
                status: 'Sent',
              ),
              const SizedBox(height: 6),
              _buildNotificationStatusRow(
                icon: Icons.account_balance,
                title: 'Bank Transfer Clearing',
                detail: 'NEFT credit routed to ${p.bankAccountMasked}',
                status: 'Settled',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.history_edu, size: 16, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This transaction has been logged in the Disbursed Payment History sheet with permanent audit trail.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.share, size: 15),
            label: const Text('Share Receipt'),
            onPressed: () {
              final receiptText =
                  'Farm2Factory Payment Receipt\nRecipient: ${p.recipientName}\nAmount: ₹${p.finalAmount.toInt()}\nLitres: ${p.totalLitres} L\nUTR: ${p.transactionReference}\nBank: ${p.bankAccountMasked}\nDate: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
              Clipboard.setData(ClipboardData(text: receiptText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment receipt copied to clipboard!'), backgroundColor: AppTheme.brandGreen),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.list_alt, size: 16),
            label: const Text('View in Payment History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _currentSheetIndex = 1); // Switch to Payment History sheet
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStatusRow({
    required IconData icon,
    required String title,
    required String detail,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F766E)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(detail, style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.badgeMintBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.badgeMintBorder),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
            ),
          ),
        ],
      ),
    );
  }

  void _exportHistoryCsv() {
    final history = _sortedPaymentHistory;
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln('# Farm2Factory Dairy Operations - Disbursed Payment History');
    buffer.writeln('# Exported At: ${now.toIso8601String()} | Total Settled Records: ${history.length}');
    buffer.writeln('');
    buffer.writeln('Payment ID,Disbursed Date,Time,Recipient ID,Recipient Name,Phone,Type,Center/Location,Litres (L),Rate (INR),Amount (INR),UTR Reference,Bank Account,Notification Status');
    for (final p in history) {
      final dateStr = '${p.paymentDate.day.toString().padLeft(2, '0')}/${p.paymentDate.month.toString().padLeft(2, '0')}/${p.paymentDate.year}';
      final timeStr = p.disbursedAt != null
          ? '${p.disbursedAt!.hour.toString().padLeft(2, '0')}:${p.disbursedAt!.minute.toString().padLeft(2, '0')}'
          : '14:30';
      buffer.writeln('${p.id},$dateStr,$timeStr,${p.recipientId},"${p.recipientName}",${p.recipientPhone},${p.recipientType},"${p.centerOrLocation}",${p.totalLitres},${p.ratePerLitre},${p.finalAmount.toInt()},${p.transactionReference},"${p.bankAccountMasked}",Delivered');
    }

    final filename = 'payment_history_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
    ExportHelper.downloadFile(filename: filename, content: buffer.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment History exported (${history.length} records). Downloaded to device.'),
        backgroundColor: AppTheme.brandGreen,
      ),
    );
  }

  Widget _dialogRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingList = _filteredPendingPayments;
    final historyList = _sortedPaymentHistory;

    return DairyPortalScaffold(
      activeRoute: '/dairy/payments',
      title: 'Payments & Payout Management',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
              childAspectRatio: MediaQuery.of(context).size.width > 700
                  ? 1.4
                  : (MediaQuery.of(context).size.width < 380 ? 0.98 : 1.15),
              children: [
                DairyStatCard(
                  icon: Icons.hourglass_empty,
                  iconColor: const Color(0xFFD97706),
                  title: 'Pending Payout',
                  value: '₹ ${_paymentRepo.totalPendingPayout.toInt()}',
                  subtitle: '${_paymentRepo.pendingCollectorsCount} pending settlements',
                  badgeText: 'Action Req',
                  badgeColor: const Color(0xFFD97706),
                ),
                DairyStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF0F5132),
                  title: 'Paid This Week',
                  value: '₹ ${_paymentRepo.totalPaidThisWeek.toInt()}',
                  subtitle: 'Direct NEFT RTGS',
                ),
                DairyStatCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF0284C7),
                  title: 'Next Settlement Date',
                  value: '10th Oct 2026',
                  subtitle: 'Cycle #3',
                ),
                DairyStatCard(
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Monthly Total',
                  value: '₹ ${_paymentRepo.totalPaidThisMonth.toInt()}',
                  subtitle: '100% verified payouts',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sheet / Tab Switcher (Pending Approvals vs Disbursed Payment History)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSheetTabButton(
                      title: 'Pending Approvals & Disbursals',
                      count: _paymentRepo.pendingPayments.length,
                      isSelected: _currentSheetIndex == 0,
                      icon: Icons.pending_actions,
                      onTap: () => setState(() => _currentSheetIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSheetTabButton(
                      title: 'Disbursed Payment History',
                      count: _paymentRepo.paymentHistory.length,
                      isSelected: _currentSheetIndex == 1,
                      icon: Icons.history,
                      onTap: () => setState(() => _currentSheetIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // RENDER SELECTED SHEET
            if (_currentSheetIndex == 0)
              _buildPendingDisbursalSheet(pendingList)
            else
              _buildPaymentHistorySheet(historyList),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.brandGreenDark : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.brandGreen : AppTheme.creamBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SHEET 1: PENDING APPROVALS & DISBURSALS
  // =========================================================================
  Widget _buildPendingDisbursalSheet(List<DairyPayment> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter bar (Cycle + Recipient Type)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Cycle:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Weekly', '10 Days', 'Monthly', 'Custom'].map((cyc) {
                      final isSelected = _selectedCycle == cyc;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(cyc),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                          selectedColor: AppTheme.brandGreen,
                          onSelected: (_) => setState(() => _selectedCycle = cyc),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Row(
              children: ['All', 'Collector', 'Seller'].map((typ) {
                final isSelected = _selectedTypeFilter == typ;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(typ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    selectedColor: AppTheme.brandGreen,
                    onSelected: (_) => setState(() => _selectedTypeFilter = typ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Pending Items
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.done_all, size: 40, color: AppTheme.brandGreen),
                const SizedBox(height: 10),
                Text(
                  'All Payouts Disbursed!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'No pending settlements in this cycle. View completed records in Payment History.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final p = list[idx];
              return _buildPaymentCard(p, isHistory: false);
            },
          ),
      ],
    );
  }

  // =========================================================================
  // SHEET 2: DISBURSED PAYMENT HISTORY (With Search & Sorting)
  // =========================================================================
  Widget _buildPaymentHistorySheet(List<DairyPayment> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // History Toolbar: Search + Sort + Export
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.creamBorder),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              // Search input
              SizedBox(
                width: 250,
                height: 38,
                child: TextField(
                  onChanged: (v) => setState(() => _historySearchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search recipient, ID, UTR...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // Sort Option Dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sort By: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _historySortOption,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        dropdownColor: AppTheme.cardSurface,
                        items: [
                          'Date: Newest First',
                          'Date: Oldest First',
                          'Amount: High to Low',
                          'Amount: Low to High',
                          'Recipient: A to Z',
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _historySortOption = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Export History Button
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Export History CSV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.brandGreen,
                  side: const BorderSide(color: AppTheme.brandGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _exportHistoryCsv,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // History Items List
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: const Center(
              child: Text('No historical disbursements matching current filter.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final p = list[idx];
              return _buildPaymentCard(p, isHistory: true);
            },
          ),
      ],
    );
  }

  Widget _buildPaymentCard(DairyPayment p, {required bool isHistory}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.creamBorder),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.creamSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.recipientType,
                            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isHistory && p.notified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 10, color: Color(0xFF15803D)),
                                SizedBox(width: 2),
                                Text(
                                  'Notified (SMS & App)',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.recipientId} • ${p.centerOrLocation} • +91 ${p.recipientPhone}',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
          Divider(height: 18, color: AppTheme.creamBorder),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.totalLitres.toInt()} L @ ₹${p.ratePerLitre}/L',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                  ),
                  Text(
                    'UTR: ${p.transactionReference}',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isHistory ? const Color(0xFF0369A1) : Colors.grey.shade500),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${p.finalAmount.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isHistory ? AppTheme.accentGreen : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  if (!isHistory && p.status == 'Pending')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showPaymentConfirmationDialog(context, p),
                      child: const Text('Disburse', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  else
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long, size: 13),
                      label: const Text('Receipt', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showDisbursedNotificationModal(context, p),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
