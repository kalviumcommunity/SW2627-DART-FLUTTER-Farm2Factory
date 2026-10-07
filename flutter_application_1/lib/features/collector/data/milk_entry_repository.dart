import 'package:flutter/foundation.dart';

import '../models/milk_entry.dart';

class MilkEntryRepository extends ChangeNotifier {
  MilkEntryRepository._();
  static final MilkEntryRepository instance = MilkEntryRepository._();

  final List<MilkEntry> _entries = [
    MilkEntry(
      id: 'ENT-001',
      farmerId: 'F001',
      farmerName: 'John Doe',
      farmerCode: 'F001',
      collectorId: 'C-BHN-001',
      shift: 'Morning (AM)',
      date: DateTime.now(),
      quantityLitres: 12.5,
      fatPercentage: 4.2,
      snfPercentage: 8.5,
      ratePerLitre: 42.0,
      totalAmount: 525.0,
    ),
    MilkEntry(
      id: 'ENT-002',
      farmerId: 'F001',
      farmerName: 'John Doe',
      farmerCode: 'F001',
      collectorId: 'C-BHN-001',
      shift: 'Evening (PM)',
      date: DateTime.now(),
      quantityLitres: 11.0,
      fatPercentage: 4.0,
      snfPercentage: 8.4,
      ratePerLitre: 40.5,
      totalAmount: 445.5,
    ),
    MilkEntry(
      id: 'ENT-003',
      farmerId: 'F002',
      farmerName: 'Rahul Kumar',
      farmerCode: 'F002',
      collectorId: 'C-BHN-001',
      shift: 'Morning (AM)',
      date: DateTime.now(),
      quantityLitres: 18.0,
      fatPercentage: 4.5,
      snfPercentage: 8.6,
      ratePerLitre: 44.0,
      totalAmount: 792.0,
    ),
    MilkEntry(
      id: 'ENT-004',
      farmerId: 'F003',
      farmerName: 'Sita Devi',
      farmerCode: 'F003',
      collectorId: 'C-BHN-001',
      shift: 'Morning (AM)',
      date: DateTime.now(),
      quantityLitres: 24.0,
      fatPercentage: 5.2,
      snfPercentage: 8.8,
      ratePerLitre: 48.0,
      totalAmount: 1152.0,
    ),
  ];

  List<MilkEntry> get entries => List.unmodifiable(_entries);

  double get todayTotalLitres {
    return _entries.fold(1248.0, (sum, e) => sum); // baseline 1,248 L from design
  }

  int get activeFarmersCount => 84;
  double get todayPayout => 21340.0;
  int get totalEntriesCount => 320;

  List<MilkEntry> getEntriesForFarmer(String farmerId) {
    return _entries.where((e) => e.farmerId == farmerId).toList();
  }

  void addEntry(MilkEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }
}
