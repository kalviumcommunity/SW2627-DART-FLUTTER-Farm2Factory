import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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

  String _shift = 'Morning (AM)';
  String? _selectedFarmerId;
  final _litresController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();

  double _calculatedRate = 0.0;
  double _calculatedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    if (_farmerRepo.farmers.isNotEmpty) {
      _selectedFarmerId = _farmerRepo.farmers.first.id;
    }
  }

  @override
  void dispose() {
    _litresController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final qty = double.tryParse(_litresController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final snf = double.tryParse(_snfController.text) ?? 0.0;

    if (fat > 0 && snf > 0) {
      // Standard dairy formula: Base rate + Fat weight + SNF weight
      final rate = (fat * 6.5) + (snf * 1.8);
      setState(() {
        _calculatedRate = double.parse(rate.toStringAsFixed(2));
        _calculatedAmount = double.parse((qty * _calculatedRate).toStringAsFixed(2));
      });
    } else {
      setState(() {
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

    _litresController.clear();
    _fatController.clear();
    _snfController.clear();
    setState(() {
      _calculatedRate = 0.0;
      _calculatedAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved entry for ${entry.farmerName}: ${entry.quantityLitres} L (₹${entry.totalAmount})'),
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
                  const Text(
                    'Record Farmer Milk',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rate per Litre',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(
                              '₹ ${_calculatedRate.toStringAsFixed(2)} / L',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.brandGreenDark,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Amount',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            Text(
                              '₹ ${_calculatedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.brandGreen,
                              ),
                            ),
                          ],
                        ),
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
