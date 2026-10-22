import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/farmer.dart';
import '../../../services/batch_service.dart';
import '../../../services/farmer_service.dart';
import '../../admin/data/rate_chart_repository.dart';
import '../../admin/models/rate_chart.dart';
import '../data/milk_entry_service.dart';
import '../models/milk_entry.dart';
import '../../farmers/data/farmer_repository.dart';
import '../widgets/digital_milk_slip_dialog.dart';

class MilkEntriesScreen extends StatefulWidget {
  const MilkEntriesScreen({super.key});

  @override
  State<MilkEntriesScreen> createState() => _MilkEntriesScreenState();
}

class _MilkEntriesScreenState extends State<MilkEntriesScreen> {
  final _milkEntryService = MilkEntryService();
  final _farmerService = FarmerService();
  final _batchService = BatchService();
  final _rateRepo = RateChartRepository.instance;

  List<Farmer> _farmers = [];
  List<MilkEntry> _recentEntries = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  String _shift = 'Morning (AM)';
  MilkType _selectedMilkType = MilkType.cow;
  String? _selectedFarmerId;
  final _litresController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _tempController = TextEditingController(text: '4.0');

  double _calculatedRate = 0.0;
  double _calculatedAmount = 0.0;
  RateCalculationResult _calcResult = RateCalculationResult.empty;

  @override
  void initState() {
    super.initState();
    _loadData();
    _rateRepo.addListener(_onRateChanged);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final farmers = await _farmerService.getFarmers();
      final entries = await _milkEntryService.getEntriesForCenter('C-BHN-001');
      if (!mounted) return;
      setState(() {
        _farmers = farmers;
        if (_farmers.isNotEmpty) {
          if (_selectedFarmerId == null ||
              !_farmers.any((f) => f.id == _selectedFarmerId)) {
            _selectedFarmerId = _farmers.first.id;
          }
        } else {
          _selectedFarmerId = null;
        }
        _recentEntries = entries;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _farmers = FarmerRepository.instance.farmers;
        if (_farmers.isNotEmpty) {
          if (_selectedFarmerId == null ||
              !_farmers.any((f) => f.id == _selectedFarmerId)) {
            _selectedFarmerId = _farmers.first.id;
          }
        } else {
          _selectedFarmerId = null;
        }
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _rateRepo.removeListener(_onRateChanged);
    _litresController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _tempController.dispose();
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

  Future<void> _saveEntry() async {
    final qty = double.tryParse(_litresController.text);
    final fat = double.tryParse(_fatController.text);
    final snf = double.tryParse(_snfController.text);

    if (_selectedFarmerId == null || qty == null || fat == null || snf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all entry fields accurately.')),
      );
      return;
    }

    final temp = double.tryParse(_tempController.text) ?? 4.0;
    final isQualityGood = _calcResult.isQualityAcceptable && temp <= 10.0;
    final status = isQualityGood ? 'ACCEPTED' : 'REJECTED';
    final reason = !isQualityGood
        ? (_calcResult.warningMessage ??
            (temp > 10.0
                ? 'High Temperature (${temp.toStringAsFixed(1)}°C > 10°C)'
                : 'Quality below threshold'))
        : null;

    final farmer = _farmers.firstWhere((f) => f.id == _selectedFarmerId);
    final entry = MilkEntry(
      id: 'ENT-${DateTime.now().millisecondsSinceEpoch % 10000}',
      farmerId: _selectedFarmerId!,
      farmerName: farmer.name,
      farmerCode: farmer.id,
      collectorId: 'C-BHN-001',
      centerId: farmer.center.isNotEmpty ? farmer.center : 'Jaipur Center',
      shift: _shift,
      date: DateTime.now(),
      milkType: _selectedMilkType.name,
      quantityLitres: qty,
      fatPercentage: fat,
      snfPercentage: snf,
      temperature: temp,
      qualityStatus: status,
      qualityGrade: _calcResult.qualityGrade,
      rejectionReason: reason,
      ratePerLitre: _calculatedRate,
      totalAmount: _calculatedAmount,
    );

    setState(() => _isSaving = true);

    try {
      await _milkEntryService.createEntry(entry);
      await _loadData();

      _litresController.clear();
      _fatController.clear();
      _snfController.clear();
      _tempController.text = '4.0';
      setState(() {
        _calcResult = RateCalculationResult.empty;
        _calculatedRate = 0.0;
        _calculatedAmount = 0.0;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Saved entry for ${entry.farmerName}: ${entry.quantityLitres} L @ ₹${entry.ratePerLitre}/L • $status (${entry.qualityGrade})'),
          backgroundColor:
              isQualityGood ? AppTheme.brandGreen : Colors.orange.shade800,
        ),
      );

      // Display the Digital Milk Slip modal receipt
      DigitalMilkSlipDialog.show(context, entry);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save entry: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showDispatchBatchDialog() async {
    final unbatched =
        await _milkEntryService.getUnbatchedEntries('Jaipur Center');
    if (!mounted) return;

    if (unbatched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No unbatched collections available to dispatch.'),
        ),
      );
      return;
    }

    final totalLitres =
        unbatched.fold<double>(0.0, (sum, e) => sum + e.quantityLitres);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: AppTheme.brandGreen),
            SizedBox(width: 8),
            Text('Dispatch Tanker Batch',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Ready to package ${unbatched.length} collections into a single dispatch batch.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Volume:'),
                  Text('${totalLitres.toStringAsFixed(1)} L',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.brandGreenDark)),
                ],
              ),
            ),
          ],
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
              Navigator.pop(dialogCtx);
              final batch = await _batchService.createBatch(
                centerId: 'Jaipur Center',
                centerName: 'Central Valley Center',
                shift: _shift,
                entries: unbatched,
              );
              await _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Batch ${batch.id} dispatched successfully!'),
                  backgroundColor: AppTheme.brandGreen,
                ),
              );
            },
            child: const Text('Confirm Dispatch'),
          ),
        ],
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
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
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
                    value: (_selectedFarmerId != null &&
                            _farmers.any((f) => f.id == _selectedFarmerId))
                        ? _selectedFarmerId
                        : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Farmer',
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colors.grey.shade600, size: 20),
                    ),
                    hint: Text(
                      _loadError != null
                          ? 'Error loading farmers'
                          : (_farmers.isEmpty
                              ? 'No farmers available'
                              : 'Select Farmer'),
                      style: TextStyle(
                        fontSize: 13,
                        color: _loadError != null
                            ? Colors.red.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                    disabledHint: Text(
                      _loadError != null
                          ? 'Failed to load farmers (Permission denied)'
                          : 'No registered farmers found',
                      style: TextStyle(
                        fontSize: 13,
                        color: _loadError != null
                            ? Colors.red.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                    items: _farmers.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(
                          '${f.name} (${f.id} • ${f.village})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _farmers.isEmpty
                        ? null
                        : (val) => setState(() => _selectedFarmerId = val),
                  ),
                  if (_loadError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Firestore permissions blocked farmer query. Ensure Email/Password provider is enabled in Firebase Console.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _loadData,
                            child: const Text('Retry', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_farmers.isEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No registered farmers found for this center.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => context.push(AppRoutes.addFarmer),
                            child: const Text('Add Farmer', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Quantity and Temperature side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _tempController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Temp (°C)',
                            hintText: 'e.g. 4.0',
                            prefixIcon: Icon(Icons.thermostat_outlined,
                                color: Colors.grey.shade600, size: 20),
                          ),
                        ),
                      ),
                    ],
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
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        _isSaving ? 'Saving Entry...' : 'Save Entry',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSaving ? null : _saveEntry,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Collection Entries List Header & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Recorded Entries',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push(AppRoutes.dairyBatches),
                      icon: const Icon(Icons.history, size: 14),
                      label: const Text('Batches',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showDispatchBatchDialog,
                      icon: const Icon(Icons.local_shipping_outlined, size: 13),
                      label: const Text('Dispatch Batch',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Builder(
              builder: (context) {
                return Column(
                  children: _recentEntries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => DigitalMilkSlipDialog.show(context, entry),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
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
                                        '${entry.shift} • Fat ${entry.fatPercentage}% | SNF ${entry.snfPercentage}% | ${entry.temperature}°C',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey.shade600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: entry.isAccepted
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: entry.isAccepted
                                                    ? Colors.green.shade200
                                                    : Colors.red.shade200,
                                              ),
                                            ),
                                            child: Text(
                                              entry.qualityStatus,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: entry.isAccepted
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                          if (entry.qualityGrade.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              entry.qualityGrade,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ],
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
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 18,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        ),
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
