import '../features/farmers/data/farmer_repository.dart';
import '../models/farmer.dart';

/// Service adapter providing CRUD operations for Farmers.
/// Delegates directly to [FarmerRepository.instance] to ensure unified state,
/// shared in-memory caching, and reactive UI notifications across all screens.
class FarmerService {
  final FarmerRepository _repository;

  FarmerService({FarmerRepository? repository})
      : _repository = repository ?? FarmerRepository.instance;

  /// Create a new farmer document in Firestore and notify all listeners.
  Future<void> createFarmer(Farmer farmer) async {
    await _repository.saveFarmer(farmer);
  }

  /// Retrieve all farmers from Firestore.
  Future<List<Farmer>> getFarmers() async {
    return await _repository.getFarmers();
  }

  /// Retrieve a farmer by ID from Firestore (with local cache fallback).
  Future<Farmer?> getFarmerById(String id) async {
    return await _repository.getFarmerById(id);
  }

  /// Update an existing farmer document in Firestore.
  Future<void> updateFarmer(Farmer farmer) async {
    await _repository.updateFarmer(farmer);
  }

  /// Delete a farmer by ID.
  Future<void> deleteFarmer(String id) async {
    await _repository.deleteFarmer(id);
  }
}
