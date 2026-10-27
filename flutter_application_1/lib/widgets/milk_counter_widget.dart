import 'package:flutter/material.dart';

/// Interactive Stateful Widget that manages mutable milk collection state.
///
/// Demonstrates the StatefulWidget lifecycle, storing mutable data in a State
/// object, and triggering UI rebuilds using setState().
class MilkCounterWidget extends StatefulWidget {
  final double initialLitres;
  final ValueChanged<double>? onQuantityChanged;

  const MilkCounterWidget({
    super.key,
    this.initialLitres = 10.0,
    this.onQuantityChanged,
  });

  @override
  State<MilkCounterWidget> createState() => _MilkCounterWidgetState();
}

class _MilkCounterWidgetState extends State<MilkCounterWidget> {
  // Mutable state variables that persist across rebuilds
  late double _litres;
  late int _canCount;
  bool _isBuffaloMilk = false;
  int _entriesLogged = 0;

  // Rate constants (₹ per Litre)
  static const double _cowRate = 45.50;
  static const double _buffaloRate = 65.00;

  @override
  void initState() {
    super.initState();
    _litres = widget.initialLitres;
    _canCount = (_litres / 40.0).ceil().clamp(1, 100);
  }

  double get _currentRate => _isBuffaloMilk ? _buffaloRate : _cowRate;
  double get _estimatedPayout => _litres * _currentRate;

  /// Increments quantity inside setState to schedule a UI rebuild.
  void _increment(double amount) {
    setState(() {
      _litres += amount;
      _canCount = (_litres / 40.0).ceil().clamp(1, 100);
    });
    widget.onQuantityChanged?.call(_litres);
  }

  /// Decrements quantity safely inside setState without falling below zero.
  void _decrement(double amount) {
    setState(() {
      if (_litres - amount >= 0.5) {
        _litres -= amount;
      } else {
        _litres = 0.0;
      }
      _canCount = (_litres / 40.0).ceil().clamp(1, 100);
    });
    widget.onQuantityChanged?.call(_litres);
  }

  /// Toggles milk type and recalculates payout inside setState.
  void _toggleMilkType(bool isBuffalo) {
    setState(() {
      _isBuffaloMilk = isBuffalo;
    });
  }

  /// Resets mutable state to initial baseline.
  void _resetCounter() {
    setState(() {
      _litres = widget.initialLitres;
      _canCount = (_litres / 40.0).ceil().clamp(1, 100);
    });
    widget.onQuantityChanged?.call(_litres);
  }

  /// Records an entry locally and increments logged count inside setState.
  void _recordEntry() {
    setState(() {
      _entriesLogged++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recorded entry #$_entriesLogged: ${_litres.toStringAsFixed(1)}L of ${_isBuffaloMilk ? "Buffalo" : "Cow"} milk (₹${_estimatedPayout.toStringAsFixed(2)})',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with live counter indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Color(0xFF15803D),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Live Milk Counter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_entriesLogged Logged',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Interactive Litre Counter Display
          Center(
            child: Column(
              children: [
                Text(
                  '${_litres.toStringAsFixed(1)} L',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_canCount standard dairy ${_canCount == 1 ? "can" : "cans"} (~40L capacity)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary Step Controls (- / +)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                iconSize: 28,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF0F172A),
                ),
                icon: const Icon(Icons.remove),
                tooltip: 'Decrease 0.5L',
                onPressed: _litres > 0.0 ? () => _decrement(0.5) : null,
              ),
              const SizedBox(width: 20),
              IconButton.filled(
                iconSize: 28,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                tooltip: 'Increase 0.5L',
                onPressed: () => _increment(0.5),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Increment Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionChip(
                label: const Text('+1 L'),
                onPressed: () => _increment(1.0),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('+5 L'),
                onPressed: () => _increment(5.0),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('+10 L'),
                onPressed: () => _increment(10.0),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                onPressed: _resetCounter,
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Milk Type Toggle Selection
          const Text(
            'Select Milk Variety',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Cow Milk (₹45.50/L)')),
                  selected: !_isBuffaloMilk,
                  onSelected: (selected) {
                    if (selected) _toggleMilkType(false);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Buffalo Milk (₹65.00/L)')),
                  selected: _isBuffaloMilk,
                  onSelected: (selected) {
                    if (selected) _toggleMilkType(true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Live Summary Metrics Display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED PAYOUT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${_estimatedPayout.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Log Collection'),
                  onPressed: _litres > 0 ? _recordEntry : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
