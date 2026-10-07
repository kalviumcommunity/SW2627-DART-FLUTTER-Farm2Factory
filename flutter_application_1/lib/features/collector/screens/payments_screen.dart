import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payments & Payouts',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Pending Payout', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 4),
                Text('₹ 84,250.00', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 6),
                Text('Next Payout Date: 10 Oct 2026 (10-Day Cycle)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Disbursed Payouts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _payoutTile('Cycle: 21 Sep - 30 Sep 2026', '₹ 2,45,600', '84 Farmers Paid', Colors.green),
          _payoutTile('Cycle: 11 Sep - 20 Sep 2026', '₹ 2,38,900', '82 Farmers Paid', Colors.green),
          _payoutTile('Cycle: 01 Sep - 10 Sep 2026', '₹ 2,41,200', '80 Farmers Paid', Colors.green),
        ],
      ),
    );
  }

  Widget _payoutTile(String cycle, String amount, String farmers, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cycle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(farmers, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
        ],
      ),
    );
  }
}
