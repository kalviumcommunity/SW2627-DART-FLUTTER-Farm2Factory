import 'package:flutter/material.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/rate_chart_repository.dart';
import '../models/rate_chart.dart';
import '../widgets/dairy_portal_scaffold.dart';

class RateChartScreen extends StatefulWidget {
  const RateChartScreen({super.key});

  @override
  State<RateChartScreen> createState() => _RateChartScreenState();
}

class _RateChartScreenState extends State<RateChartScreen> {
  final _repo = RateChartRepository.instance;

  // Simulator controls
  MilkType _simMilkType = MilkType.cow;
  double _simQuantity = 10.0;
  double _simFat = 4.0;
  double _simSnf = 8.5;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoUpdate);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoUpdate);
    super.dispose();
  }

  void _onRepoUpdate() {
    if (mounted) setState(() {});
  }

  void _showUpdateRatesDialog(BuildContext context, {RateChart? initialChart}) {
    final isEditingBuffalo = (initialChart?.milkType ?? _simMilkType) == MilkType.buffalo;
    MilkType selectedType = initialChart?.milkType ?? _simMilkType;

    final titleCtrl = TextEditingController(
      text: initialChart != null
          ? 'Revised ${initialChart.title}'
          : '${selectedType.displayName} Revision (${DateTime.now().day}/${DateTime.now().month})',
    );
    final fatRateCtrl = TextEditingController(
      text: (initialChart?.fatRate ?? (isEditingBuffalo ? 7.50 : 6.80)).toStringAsFixed(2),
    );
    final snfRateCtrl = TextEditingController(
      text: (initialChart?.snfRate ?? (isEditingBuffalo ? 2.50 : 2.20)).toStringAsFixed(2),
    );
    final baseRateCtrl = TextEditingController(
      text: (initialChart?.baseRate ?? 0.0).toStringAsFixed(2),
    );
    final minFatCtrl = TextEditingController(
      text: (initialChart?.minFat ?? (isEditingBuffalo ? 5.5 : 3.2)).toStringAsFixed(1),
    );
    final minSnfCtrl = TextEditingController(
      text: (initialChart?.minSnf ?? (isEditingBuffalo ? 8.8 : 8.3)).toStringAsFixed(1),
    );

    DateTime effectiveDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.brandGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppTheme.brandGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text('Configure Rate Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Updates will immediately apply to all collector milk entries with this effective date.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),

                      // Milk Type Selector
                      const Text('Milk Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Text('${MilkType.cow.emoji} Cow Milk'),
                              selected: selectedType == MilkType.cow,
                              selectedColor: AppTheme.cardMint,
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    selectedType = MilkType.cow;
                                    fatRateCtrl.text = '6.80';
                                    snfRateCtrl.text = '2.20';
                                    minFatCtrl.text = '3.2';
                                    minSnfCtrl.text = '8.3';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Text('${MilkType.buffalo.emoji} Buffalo Milk'),
                              selected: selectedType == MilkType.buffalo,
                              selectedColor: AppTheme.cardMint,
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    selectedType = MilkType.buffalo;
                                    fatRateCtrl.text = '7.50';
                                    snfRateCtrl.text = '2.50';
                                    minFatCtrl.text = '5.5';
                                    minSnfCtrl.text = '8.8';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Chart Title / Description',
                          hintText: 'e.g. Diwali Season Incentive Chart',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fatRateCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Fat Rate (₹ per 1%)',
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: snfRateCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'SNF Rate (₹ per 1%)',
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minFatCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Min Fat %',
                                suffixText: '%',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: minSnfCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Min SNF %',
                                suffixText: '%',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: baseRateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Base Rate Floor (₹ per Litre)',
                          prefixText: '₹ ',
                          helperText: 'Default 0.00 (Pricing driven by Fat + SNF)',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Effective Date Picker Button
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: effectiveDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => effectiveDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Effective Date', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    '${effectiveDate.day}/${effectiveDate.month}/${effectiveDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              const Icon(Icons.calendar_month, color: AppTheme.brandGreen, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final fatRate = double.tryParse(fatRateCtrl.text) ?? 6.80;
                    final snfRate = double.tryParse(snfRateCtrl.text) ?? 2.20;
                    final baseRate = double.tryParse(baseRateCtrl.text) ?? 0.0;
                    final minFat = double.tryParse(minFatCtrl.text) ?? 3.2;
                    final minSnf = double.tryParse(minSnfCtrl.text) ?? 8.3;

                    await _repo.updateRates(
                      milkType: selectedType,
                      title: titleCtrl.text.isNotEmpty
                          ? titleCtrl.text
                          : '${selectedType.displayName} Rate Chart',
                      fatRate: fatRate,
                      snfRate: snfRate,
                      baseRate: baseRate,
                      minFat: minFat,
                      minSnf: minSnf,
                      effectiveFrom: effectiveDate,
                    );

                    if (context.mounted) {
                      Navigator.pop(dialogCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Activated new ${selectedType.displayName} rate chart!'),
                          backgroundColor: AppTheme.brandGreen,
                        ),
                      );
                    }
                  },
                  child: const Text('Save & Apply Rates'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cowChart = _repo.activeCowChart;
    final buffaloChart = _repo.activeBuffaloChart;
    final allCharts = _repo.allCharts;

    // Simulate current values
    final simResult = _repo.calculate(
      quantity: _simQuantity,
      fat: _simFat,
      snf: _simSnf,
      milkType: _simMilkType,
    );

    return DairyPortalScaffold(
      activeRoute: AppRoutes.dairyRates,
      title: 'Rate Charts & Pricing Engine',
      actions: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brandGreen,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('New Rate Revision'),
          onPressed: () => _showUpdateRatesDialog(context),
        ),
        const SizedBox(width: 8),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Formula Overview Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF134E4A), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_graph, color: Color(0xFF5EEAD4), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Standard Cooperative Pricing Formula',
                              style: TextStyle(color: Color(0xFFCCFBF1), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Rate = (Fat% × FatRate) + (SNF% × SNFRate) + Base',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Calculated live on every milk collection. Changes take effect on the configured effective date.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Update Rates', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showUpdateRatesDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Charts Side-by-Side (Cow & Buffalo)
            const Text(
              'Active Pricing Policies',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final cards = [
                  _buildActivePolicyCard(context, cowChart),
                  _buildActivePolicyCard(context, buffaloChart),
                ];

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  );
                }
                return Column(
                  children: [
                    cards[0],
                    const SizedBox(height: 12),
                    cards[1],
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Live Rate Simulator & Calculator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                      const Row(
                        children: [
                          Icon(Icons.tune, color: AppTheme.brandGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Interactive Rate Simulator & Testing',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SegmentedButton<MilkType>(
                        segments: [
                          ButtonSegment(
                            value: MilkType.cow,
                            label: Text('${MilkType.cow.emoji} Cow'),
                          ),
                          ButtonSegment(
                            value: MilkType.buffalo,
                            label: Text('${MilkType.buffalo.emoji} Buffalo'),
                          ),
                        ],
                        selected: {_simMilkType},
                        onSelectionChanged: (val) {
                          setState(() {
                            _simMilkType = val.first;
                            if (_simMilkType == MilkType.buffalo) {
                              _simFat = 6.5;
                              _simSnf = 9.0;
                            } else {
                              _simFat = 4.0;
                              _simSnf = 8.5;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Simulate how farmer rates and total earnings are computed under active pricing coefficients:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  // Sliders & Inputs
                  Row(
                    children: [
                      Expanded(
                        child: _buildSliderControl(
                          label: 'Quantity',
                          valueText: '${_simQuantity.toStringAsFixed(1)} Litres',
                          min: 1.0,
                          max: 50.0,
                          value: _simQuantity,
                          onChanged: (v) => setState(() => _simQuantity = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSliderControl(
                          label: 'Fat %',
                          valueText: '${_simFat.toStringAsFixed(1)} %',
                          min: 2.0,
                          max: 10.0,
                          value: _simFat,
                          onChanged: (v) => setState(() => _simFat = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSliderControl(
                          label: 'SNF %',
                          valueText: '${_simSnf.toStringAsFixed(1)} %',
                          min: 6.0,
                          max: 11.0,
                          value: _simSnf,
                          onChanged: (v) => setState(() => _simSnf = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Real-time calculation output card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.brandGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Computed Milk Rate', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${simResult.ratePerLitre.toStringAsFixed(2)} / L',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.brandGreenDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: simResult.isQualityAcceptable ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    simResult.isQualityAcceptable ? Icons.verified : Icons.warning_amber,
                                    size: 16,
                                    color: simResult.isQualityAcceptable ? Colors.green.shade800 : Colors.orange.shade900,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    simResult.qualityGrade,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: simResult.isQualityAcceptable ? Colors.green.shade800 : Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Farmer Payout', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${simResult.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.brandGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Fat Component: ₹${simResult.fatComponent.toStringAsFixed(2)} (${_simFat.toStringAsFixed(1)}% × ₹${(_simMilkType == MilkType.cow ? cowChart : buffaloChart).fatRate})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                            Text(
                              'SNF Component: ₹${simResult.snfComponent.toStringAsFixed(2)} (${_simSnf.toStringAsFixed(1)}% × ₹${(_simMilkType == MilkType.cow ? cowChart : buffaloChart).snfRate})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                        if (simResult.warningMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            simResult.warningMessage!,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Historical Revisions Table
            const Text(
              'Rate Chart Revisions & History',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allCharts.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final c = allCharts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: c.isActive ? AppTheme.cardMint : Colors.grey.shade100,
                      child: Text(c.milkType.emoji, style: const TextStyle(fontSize: 18)),
                    ),
                    title: Row(
                      children: [
                        Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        if (c.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.brandGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      'Effective: ${c.effectiveFrom.day}/${c.effectiveFrom.month}/${c.effectiveFrom.year} • Fat Rate: ₹${c.fatRate.toStringAsFixed(2)} • SNF Rate: ₹${c.snfRate.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Revise'),
                      onPressed: () => _showUpdateRatesDialog(context, initialChart: c),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePolicyCard(BuildContext context, RateChart chart) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.brandGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(chart.milkType.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    chart.milkType.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('LIVE IN APP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(chart.title, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRateStat(
                  label: 'Fat Rate Coeff.',
                  value: '₹ ${chart.fatRate.toStringAsFixed(2)}',
                  sub: 'per 1.0% Fat',
                ),
              ),
              Expanded(
                child: _buildRateStat(
                  label: 'SNF Rate Coeff.',
                  value: '₹ ${chart.snfRate.toStringAsFixed(2)}',
                  sub: 'per 1.0% SNF',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRateStat(
                  label: 'Min Quality Fat',
                  value: '${chart.minFat.toStringAsFixed(1)}%',
                  sub: 'Standard floor',
                ),
              ),
              Expanded(
                child: _buildRateStat(
                  label: 'Min Quality SNF',
                  value: '${chart.minSnf.toStringAsFixed(1)}%',
                  sub: 'Standard floor',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Effective: ${chart.effectiveFrom.day}/${chart.effectiveFrom.month}/${chart.effectiveFrom.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              TextButton(
                onPressed: () => _showUpdateRatesDialog(context, initialChart: chart),
                child: const Text('Adjust Rate', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateStat({required String label, required String value, required String sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildSliderControl({
    required String label,
    required String valueText,
    required double min,
    required double max,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(valueText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppTheme.brandGreen,
            inactiveColor: Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
