import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../farmers/data/farmer_repository.dart';
import '../data/collector_repository.dart';
import '../models/collector.dart';
import '../widgets/dairy_portal_scaffold.dart';
import '../widgets/status_badge.dart';

class CollectorDetailsScreen extends StatefulWidget {
  final String collectorId;

  const CollectorDetailsScreen({super.key, required this.collectorId});

  @override
  State<CollectorDetailsScreen> createState() => _CollectorDetailsScreenState();
}

class _CollectorDetailsScreenState extends State<CollectorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collectorRepo = CollectorRepository.instance;
  final _farmerRepo = FarmerRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collector = _collectorRepo.getCollectorById(widget.collectorId) ??
        _collectorRepo.collectors.first;

    return DairyPortalScaffold(
      activeRoute: '/dairy/collectors',
      title: '${collector.name} (${collector.id})',
      actions: [
        IconButton(
          tooltip: 'Call Collector',
          icon: const Icon(Icons.phone_outlined, color: AppTheme.brandGreen),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Dialing ${collector.phone}...')),
            );
          },
        ),
      ],
      body: Column(
        children: [
          // Top Collector Profile Header Card
          _buildCollectorHeaderCard(context, collector),

          // 6 Tab Bar Navigation
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.brandGreen,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppTheme.brandGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined, size: 16), text: 'Overview'),
                Tab(icon: Icon(Icons.water_drop_outlined, size: 16), text: 'Milk Data'),
                Tab(icon: Icon(Icons.receipt_long_outlined, size: 16), text: 'Payments (10)'),
                Tab(icon: Icon(Icons.people_outline, size: 16), text: 'Farmers'),
                Tab(icon: Icon(Icons.timeline_outlined, size: 16), text: 'Activity'),
                Tab(icon: Icon(Icons.badge_outlined, size: 16), text: 'Profile'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(collector),
                _buildMilkDataTab(collector),
                _buildPaymentsTab(collector),
                _buildFarmersTab(collector),
                _buildActivityTab(collector),
                _buildProfileTab(collector),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorHeaderCard(BuildContext context, Collector c) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.brandGreen,
                child: Text(
                  c.name[0],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: c.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${c.id}  •  ${c.center}',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phone: +91 ${c.phone}  •  Joined: ${c.joiningDate.day}/${c.joiningDate.month}/${c.joiningDate.year}',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.brandGreen,
                  side: const BorderSide(color: AppTheme.brandGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collector edit dialog opened')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Overview Tab
  Widget _buildOverviewTab(Collector c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _overviewCard('Today Morning', '${c.morningLitresToday.toInt()} L', AppTheme.cardPeach, const Color(0xFFF57C00)),
              _overviewCard('Today Evening', '${c.eveningLitresToday.toInt()} L', AppTheme.cardLavender, const Color(0xFF5C6BC0)),
              _overviewCard('Today Total', '${c.todayTotalLitres.toInt()} L', AppTheme.cardMint, AppTheme.brandGreen),
              _overviewCard('Monthly Total', '${c.monthlyTotalLitres.toInt()} L', AppTheme.cardSky, const Color(0xFF0288D1)),
              _overviewCard('Daily Average', '${c.avgDailyLitres.toInt()} L/day', AppTheme.cardMint, AppTheme.brandGreenDark),
              _overviewCard('Active Farmers', '${c.farmersHandled} Farmers', AppTheme.cardPeach, const Color(0xFFE65100)),
              _overviewCard('Average FAT', '${c.avgFat}%', AppTheme.cardSky, const Color(0xFF0288D1)),
              _overviewCard('Average SNF', '${c.avgSnf}%', AppTheme.cardLavender, const Color(0xFF6A1B9A)),
              _overviewCard('Chilling Temp', '${c.avgTemp}°C', AppTheme.cardMint, AppTheme.brandGreen),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Payment Status', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Settled for Current Cycle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                StatusBadge(status: c.paymentStatus, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(String title, String val, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: iconColor)),
          ),
        ],
      ),
    );
  }

  // 2. Milk Data Tab
  Widget _buildMilkDataTab(Collector c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Morning vs Evening Trend Visual Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Collection Shift Trend (Last 7 Days)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Color(0xFFF57C00)),
                        SizedBox(width: 4),
                        Text('Morning', style: TextStyle(fontSize: 11)),
                        SizedBox(width: 12),
                        Icon(Icons.circle, size: 10, color: Color(0xFF5C6BC0)),
                        SizedBox(width: 4),
                        Text('Evening', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final rec = c.dailyRecords[i];
                    final maxH = 90.0;
                    final mHeight = (rec.morningLitres / 800) * maxH;
                    final eHeight = (rec.eveningLitres / 800) * maxH;
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(width: 12, height: mHeight, decoration: BoxDecoration(color: const Color(0xFFF57C00), borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 3),
                            Container(width: 12, height: eHeight, decoration: BoxDecoration(color: const Color(0xFF5C6BC0), borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${rec.date.day}/${rec.date.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Daily Milk Log Records', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.dailyRecords.length,
            itemBuilder: (context, idx) {
              final r = c.dailyRecords[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.date.day}/${r.date.month}/${r.date.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text('AM: ${r.morningLitres.toInt()}L  •  PM: ${r.eveningLitres.toInt()}L', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${r.totalLitres.toInt()} Litres', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
                        Text('FAT: ${r.fat}%  •  SNF: ${r.snf}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Payments Tab
  Widget _buildPaymentsTab(Collector c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last 10 Payout Transactions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Showing all 24 past payment transactions')));
                },
                child: const Text('View All Payments', style: TextStyle(fontSize: 12, color: AppTheme.brandGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.payments.length,
            itemBuilder: (context, idx) {
              final p = c.payments[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                        Text(p.period, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('${p.method} • Ref: ${p.referenceId}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        Text(p.timestamp, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹ ${p.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        StatusBadge(status: p.status, fontSize: 10),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. Farmers Tab
  Widget _buildFarmersTab(Collector c) {
    final assignedFarmers = _farmerRepo.farmers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assigned Farmers (${assignedFarmers.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('Active Center: ${c.center}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignedFarmers.length,
            itemBuilder: (context, idx) {
              final f = assignedFarmers[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.brandGreen.withValues(alpha: 0.1),
                          child: Text(f.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandGreen)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${f.id} • ${f.village}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('16.5 L / day', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
                        Text('Grade A (4.2% FAT)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 5. Activity Timeline Tab
  Widget _buildActivityTab(Collector c) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: c.activities.length,
      itemBuilder: (context, idx) {
        final act = c.activities[idx];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppTheme.brandGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                if (idx != c.activities.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(act.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(act.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 2),
                  Text(
                    '${act.timestamp.hour.toString().padLeft(2, '0')}:${act.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 6. Profile Tab
  Widget _buildProfileTab(Collector c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _profileSection('Center & Operational Details', [
            _profileRow('Assigned Center', c.center),
            _profileRow('Location', c.location),
            _profileRow('Collector ID', c.id),
            _profileRow('Terminal Device', 'F2F Micro-Analyzer #M-8821'),
            _profileRow('Current Status', c.status),
          ]),
          const SizedBox(height: 14),
          _profileSection('Contact & Authentication', [
            _profileRow('Phone Number', '+91 ${c.phone}'),
            _profileRow('Email Address', c.email),
            _profileRow('Joining Date', '${c.joiningDate.day}/${c.joiningDate.month}/${c.joiningDate.year}'),
            _profileRow('Emergency Contact', '+91 9414000111'),
          ]),
          const SizedBox(height: 14),
          _profileSection('Bank & Payout Details', [
            _profileRow('Bank Name', 'State Bank of India'),
            _profileRow('Account Number', 'XXXX-XXXX-8821'),
            _profileRow('IFSC Code', 'SBIN0031122'),
            _profileRow('Settlement Mode', 'Automatic NEFT 10-Day Cycle'),
          ]),
        ],
      ),
    );
  }

  Widget _profileSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
