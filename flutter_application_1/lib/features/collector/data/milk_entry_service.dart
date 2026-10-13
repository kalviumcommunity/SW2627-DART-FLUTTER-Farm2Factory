import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milk_entry.dart';

class MilkEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _entries => _firestore.collection('milk_entries');

  Future<void> createEntry(MilkEntry entry) async {
    await _entries.doc(entry.id).set({
      ...entry.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MilkEntry>> getEntriesForFarmer(String farmerId) async {
    final snapshot = await _entries
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }
  
  Future<List<MilkEntry>> getEntriesForCenter(String centerId) async {
    // Note: If you want to filter by center, you either need centerId in MilkEntry
    // or you need to fetch farmers by center, then fetch their entries.
    final snapshot = await _entries
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map(
          (doc) => MilkEntry.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Dashboard Aggregations for today
  Future<Map<String, dynamic>> getTodayDashboardStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final snapshot = await _entries
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .get();
        
    double totalLitres = 0;
    double todayPayout = 0;
    final Set<String> activeFarmers = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final entry = MilkEntry.fromMap(doc.id, data);
      
      totalLitres += entry.quantityLitres;
      todayPayout += entry.totalAmount;
      activeFarmers.add(entry.farmerId);
    }
    
    return {
      'todayTotalLitres': totalLitres,
      'activeFarmersCount': activeFarmers.length,
      'todayPayout': todayPayout,
      'totalEntriesCount': snapshot.docs.length,
    };
  }
}
