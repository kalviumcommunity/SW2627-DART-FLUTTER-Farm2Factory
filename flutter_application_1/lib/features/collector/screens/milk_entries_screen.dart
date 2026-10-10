import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../admin/data/rate_chart_repository.dart';
import '../../admin/models/rate_chart.dart';
import '../../farmers/data/farmer_repository.dart';
import '../data/milk_entry_repository.dart';
import '../models/milk_entry.dart';

class MilkEntriesScreen extends StatefulWidget {
  const MilkEntriesScreen({super.key});

  @override
  State<MilkEntriesScreen> createState() => _MilkEntriesScreenState();
}

class _MilkEntriesScreenState extends State<MilkEntriesScreen> {
  final _entryRepo = MilkEntryRepository.instance;
  final _farmerRepo = FarmerRepository.instance;
  final _rateRepo = RateChartRepository.instance;

  String _shift = 'Morning (AM)';
  MilkType _selectedMilkType = MilkType.cow;
  String? _selectedFarmerId;
  final _litresController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();

  double _calculatedRate = 0.0;
  double _calculatedAmount = 0.0;
  RateCalculationResult _calcResult = RateCalculationResult.empty;

  @override
  void initState() {
    super.initState();
    if (_farmerRepo.farmers.isNotEmpty) {
      _selectedFarmerId = _farmerRepo.farmers.first.id;
    }
    _rateRepo.addListener(_onRateChanged);
  }

  @override
  void dispose() {
    _rateRepo.removeListener(_onRateChanged);
    _litresController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    super.dispose();
  }

  void _onRateChanged() {
    _recalculate();
  }

  void _recalculate() {
    final qty = double.tryParse(_litresController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final snf = double.tryParse(_snfController.text) ?? 0.0;

    if (qty > 0 && fat > 0 && snf > 0) {
      final res = _rateRepo.calculate(
        quantity: qty,
        fat: fat,
        snf: snf,
        milkType: _selectedMilkType,
      );
      setState(() {
        _calcResult = res;
        _calculatedRate = res.ratePerLitre;
        _calculatedAmount = res.totalAmount;
      });
    } else {
      setState(() {
        _calcResult = RateCalculationResult.empty;
        _calculatedRate = 0.0;
        _calculatedAmount = 0.0;
      });
    }
  }

  void _saveEntry() {
    final qty = double.tryParse(_litresController.text);
    final fat = double.tryParse(_fatController.text);
    final snf = double.tryParse(_snfController.text);

    if (_selectedFarmerId == null || qty == null || fat == null || snf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all entry fields accurately.')),
      );
      return;
    }

    final farmer = _farmerRepo.getById(_selectedFarmerId!);
    final entry = MilkEntry(
      id: 'ENT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      farmerId: _selectedFarmerId!,
      farmerName: farmer?.name ?? 'Unknown',
      farmerCode: farmer?.id ?? 'F000',
      collectorId: 'C-BHN-001',
      shift: _shift,
      date: DateTime.now(),
      quantityLitres: qty,
      fatPercentage: fat,
      snfPercentage: snf,
      ratePerLitre: _calculatedRate,
      totalAmount: _calculatedAmount,
    );

    _entryRepo.addEntry(entry);

    final grade = _calcResult.qualityGrade;
    _litresController.clear();
    _fatController.clear();
    _snfController.clear();
    setState(() {
      _calcResult = RateCalculationResult.empty;
      _calculatedRate = 0.0;
      _calculatedAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved entry for ${entry.farmerName}: ${entry.quantityLitres} L @ ₹${entry.ratePerLitre}/L (₹${entry.totalAmount}) • $grade'),
        backgroundColor: AppTheme.brandGreen,
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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Milk Collection Entries',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shift Toggle Card
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shift = 'Morning (AM)'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _shift == 'Morning (AM)'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _shift == 'Morning (AM)'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wb_sunny_outlined,
                                size: 16,
                                color: _shift == 'Morning (AM)'
                                    ? const Color(0xFFE65100)
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Morning (AM)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _shift == 'Morning (AM)'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _shift == 'Morning (AM)'
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shift = 'Evening (PM)'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _shift == 'Evening (PM)'
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _shift == 'Evening (PM)'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.nightlight_outlined,
                                size: 16,
                                color: _shift == 'Evening (PM)'
                                    ? const Color(0xFF5E35B1)
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Evening (PM)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _shift == 'Evening (PM)'
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _shift == 'Evening (PM)'
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Entry Form Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Record Farmer Milk',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      // Active policy indicator chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.cardMint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _rateRepo.getActiveChartFor(_selectedMilkType).title,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.brandGreenDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Milk Type Choice (Cow vs Buffalo)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedMilkType = MilkType.cow);
                            _recalculate();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedMilkType == MilkType.cow ? AppTheme.cardMint : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMilkType == MilkType.cow ? AppTheme.brandGreen : Colors.grey.shade300,
                                width: _selectedMilkType == MilkType.cow ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(MilkType.cow.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'Cow Milk',
                                  style: TextStyle(
                                    fontWeight: _selectedMilkType == MilkType.cow ? FontWeight.bold : FontWeight.w500,
                                    color: _selectedMilkType == MilkType.cow ? AppTheme.brandGreenDark : Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedMilkType = MilkType.buffalo);
                            _recalculate();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selectedMilkType == MilkType.buffalo ? AppTheme.cardMint : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMilkType == MilkType.buffalo ? AppTheme.brandGreen : Colors.grey.shade300,
                                width: _selectedMilkType == MilkType.buffalo ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(MilkType.buffalo.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'Buffalo Milk',
                                  style: TextStyle(
                                    fontWeight: _selectedMilkType == MilkType.buffalo ? FontWeight.bold : FontWeight.w500,
                                    color: _selectedMilkType == MilkType.buffalo ? AppTheme.brandGreenDark : Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Select Farmer
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFarmerId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Farmer',
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colors.grey.shade600, size: 20),
                    ),
                    items: _farmerRepo.farmers.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(
                          '${f.name} (${f.id} • ${f.village})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFarmerId = val),
                  ),
                  const SizedBox(height: 14),

                  // Quantity in Litres
                  TextField(
                    controller: _litresController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculate(),
                    decoration: InputDecoration(
                      labelText: 'Quantity (Litres)',
                      hintText: 'e.g. 15.5',
                      prefixIcon: Icon(Icons.water_drop_outlined,
                          color: Colors.grey.shade600, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Fat % and SNF % side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) => _recalculate(),
                          decoration: InputDecoration(
                            labelText: 'Fat %',
                            hintText: 'e.g. 4.2',
                            prefixIcon: Icon(Icons.opacity,
                                color: Colors.grey.shade600, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _snfController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) => _recalculate(),
                          decoration: InputDecoration(
                            labelText: 'SNF %',
                            hintText: 'e.g. 8.5',
                            prefixIcon: Icon(Icons.science_outlined,
                                color: Colors.grey.shade600, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Live Calculated Rate & Amount Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      borderRadius: BorderRadius.circular(14),
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
                                const Text('Rate per Litre',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${_calculatedRate.toStringAsFixed(2)} / L',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brandGreenDark,
                                  ),
                                ),
                              ],
                            ),
                            if (_calculatedRate > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _calcResult.isQualityAcceptable
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _calcResult.qualityGrade,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _calcResult.isQualityAcceptable
                                        ? Colors.green.shade800
                                        : Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total Payout',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  '₹ ${_calculatedAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.brandGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_calculatedRate > 0) ...[
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fat: ₹${_calcResult.fatComponent.toStringAsFixed(2)} + SNF: ₹${_calcResult.snfComponent.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                              Text(
                                '${_selectedMilkType.displayName} Chart',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          if (_calcResult.warningMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _calcResult.warningMessage!,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text('Save Entry',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: _saveEntry,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Collection Entries List
            const Text(
              'Recent Recorded Entries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),

            ListenableBuilder(
              listenable: _entryRepo,
              builder: (context, _) {
                return Column(
                  children: _entryRepo.entries.map((entry) {
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.farmerName} (${entry.farmerCode})',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entry.shift} • Fat ${entry.fatPercentage}% | SNF ${entry.snfPercentage}%',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.quantityLitres} L',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '₹ ${entry.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.brandGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
