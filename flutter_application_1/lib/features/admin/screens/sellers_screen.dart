import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/seller_repository.dart';
import '../models/seller.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/status_badge.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final _sellerRepo = SellerRepository.instance;
  String _searchQuery = '';

  List<Seller> get _filteredSellers {
    if (_searchQuery.isEmpty) return _sellerRepo.sellers;
    return _sellerRepo.sellers.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.farmName.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q);
    }).toList();
  }

  void _showSellerDetailsModal(BuildContext context, Seller s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.farmName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text('${s.id}  •  ${s.name}  •  +91 ${s.phone}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  StatusBadge(status: s.status),
                ],
              ),
              const Divider(height: 24),

              // Farm KPIs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _sellerModalMetric('Cattle Headcount', '${s.cattleCount} Cows', Icons.pets),
                  _sellerModalMetric('Daily Supply', '${s.dailySupplyLitres.toInt()} L', Icons.water_drop),
                  _sellerModalMetric('FAT / SNF', '${s.avgFat}% / ${s.avgSnf}%', Icons.science),
                  _sellerModalMetric('Rate / Litre', '₹ ${s.ratePerLitre}', Icons.currency_rupee),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Recent Milk Supply Logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...s.supplies.take(5).map((sup) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${sup.date.day}/${sup.date.month}/${sup.date.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('FAT: ${sup.fat}% • SNF: ${sup.snf}% • ${sup.temperature}°C', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${sup.quantityLitres.toInt()} Litres', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
                          StatusBadge(status: sup.grade, fontSize: 10),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sellerModalMetric(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.brandGreen),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellers = _filteredSellers;

    return DairyPortalScaffold(
      activeRoute: '/dairy/sellers',
      title: 'Sellers & Commercial Farms',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                onChanged: (q) => setState(() => _searchQuery = q),
                decoration: const InputDecoration(
                  hintText: 'Search farm name, seller ID or location...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.brandGreen, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bulk Farm Suppliers (${sellers.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  'Total Cattle: ${sellers.fold(0, (sum, s) => sum + s.cattleCount)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sellers.length,
              itemBuilder: (context, idx) {
                final s = sellers[idx];
                return _buildSellerCard(context, s);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Seller s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showSellerDetailsModal(context, s),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF558B2F).withValues(alpha: 0.12),
                          child: const Icon(Icons.agriculture, color: Color(0xFF558B2F)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.farmName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${s.id} • ${s.location}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    StatusBadge(status: s.status),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardMint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol('Cattle Head', '${s.cattleCount}'),
                      _metricCol('Daily Supply', '${s.dailySupplyLitres.toInt()} L'),
                      _metricCol('Avg FAT', '${s.avgFat}%'),
                      _metricCol('Rate / L', '₹ ${s.ratePerLitre}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contact: ${s.name} (+91 ${s.phone})', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                    StatusBadge(status: s.paymentStatus, fontSize: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCol(String title, String val) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}
