import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
  String _selectedCycle = '10 Days';
  String _selectedTypeFilter = 'All';

  List<DairyPayment> get _filteredPayments {
    if (_selectedTypeFilter == 'All') return _paymentRepo.payments;
    return _paymentRepo.payments
        .where((p) => p.recipientType.toLowerCase() == _selectedTypeFilter.toLowerCase())
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
            Text('Confirm Payout Disbursal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipient: ${p.recipientName} (${p.recipientType})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('Center: ${p.centerOrLocation}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Divider(height: 18),
            _dialogRow('Total Milk Supplied', '${p.totalLitres.toInt()} Litres'),
            _dialogRow('Base Rate per Litre', '₹ ${p.ratePerLitre}'),
            _dialogRow('Gross Calculation', '₹ ${p.grossAmount.toInt()}'),
            _dialogRow('Adjustments / Bonus', '₹ ${p.adjustments.toInt()}'),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Final Disbursal Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('₹ ${p.finalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.brandGreenDark)),
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
                    child: Text('Simulated NEFT payment gateway. Direct bank transfer will be scheduled.', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
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
                  content: Text('Payment of ₹ ${p.finalAmount.toInt()} settled successfully!'),
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
    final list = _filteredPayments;

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
              childAspectRatio: 1.5,
              children: [
                DairyStatCard(
                  icon: Icons.hourglass_empty,
                  iconColor: const Color(0xFFE65100),
                  title: 'Pending Payout',
                  value: '₹ ${_paymentRepo.totalPendingPayout.toInt()}',
                  subtitle: '${_paymentRepo.pendingCollectorsCount} pending settlements',
                  badgeText: 'Action Req',
                  badgeColor: const Color(0xFFE65100),
                  cardBgColor: AppTheme.cardPeach,
                ),
                DairyStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.brandGreen,
                  title: 'Paid This Week',
                  value: '₹ ${_paymentRepo.totalPaidThisWeek.toInt()}',
                  subtitle: 'Direct NEFT RTGS',
                  cardBgColor: AppTheme.cardMint,
                ),
                DairyStatCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF0288D1),
                  title: 'Next Settlement Date',
                  value: '10th Oct 2026',
                  subtitle: 'Cycle Cycle #3',
                  cardBgColor: AppTheme.cardSky,
                ),
                DairyStatCard(
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF5C6BC0),
                  title: 'Monthly Total',
                  value: '₹ ${_paymentRepo.totalPaidThisMonth.toInt()}',
                  subtitle: '100% verified payouts',
                  cardBgColor: AppTheme.cardLavender,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Settlement Cycle Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Settlement Cycle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Weekly', '10 Days', 'Monthly', 'Custom'].map((cyc) {
                      final isSelected = _selectedCycle == cyc;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
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
            const SizedBox(height: 16),

            // Type Filter (All, Collector, Seller)
            Row(
              children: ['All', 'Collector', 'Seller'].map((typ) {
                final isSelected = _selectedTypeFilter == typ;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(typ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    selectedColor: AppTheme.brandGreen,
                    onSelected: (_) => setState(() => _selectedTypeFilter = typ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Payout Transaction List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final p = list[idx];
                final isPending = p.status == 'Pending';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(p.recipientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                    child: Text(p.recipientType, style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${p.recipientId} • ${p.centerOrLocation} • ${p.paymentCycle}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                            ],
                          ),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.totalLitres.toInt()} L @ ₹${p.ratePerLitre}/L', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              Text('Ref: ${p.transactionReference}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹ ${p.finalAmount.toInt()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                  Text('${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year}', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
                                ],
                              ),
                              if (isPending) ...[
                                const SizedBox(width: 14),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.brandGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _showPaymentConfirmationDialog(context, p),
                                  child: const Text('Disburse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}
