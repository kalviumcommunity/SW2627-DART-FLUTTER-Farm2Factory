import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
          'Collection Reports',
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Total Litres Collected: 1,248 L', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Morning: 680 L  |  Evening: 568 L', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                SizedBox(height: 4),
                Text('Average Fat: 4.2%  |  Average SNF: 8.5%', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Past Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _reportTile('Yesterday Report (06 Oct 2026)', '1,210 L', '₹ 50,820'),
          _reportTile('05 Oct 2026 Shift Report', '1,195 L', '₹ 49,890'),
          _reportTile('04 Oct 2026 Shift Report', '1,240 L', '₹ 52,080'),
          _reportTile('Monthly September 2026 Summary', '36,400 L', '₹ 15,28,800'),
        ],
      ),
    );
  }

  Widget _reportTile(String title, String litres, String total) {
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
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(litres, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          Row(
            children: [
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
              const SizedBox(width: 8),
              const Icon(Icons.download_outlined, size: 20, color: AppTheme.brandGreen),
            ],
          ),
        ],
      ),
    );
  }
}
