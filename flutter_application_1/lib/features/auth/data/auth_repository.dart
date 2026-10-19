import 'package:flutter/foundation.dart';
import '../../admin/data/collector_repository.dart';
import '../../farmers/data/farmer_repository.dart';

enum UserRole { farmer, collector, admin }

class AppUser {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String center;
  final String? collectorId;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.center = 'Central Valley Collection Center',
    this.collectorId,
  });
}

class _Account {
  final String id;
  final String name;
  final String identifier; // phone or username
  final String password;
  final UserRole role;
  final String center;
  final String? collectorId;

  const _Account({
    required this.id,
    required this.name,
    required this.identifier,
    required this.password,
    required this.role,
    this.center = 'Central Valley Collection Center',
    this.collectorId,
  });
}

class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Map<String, _Account> _accounts = {
    // Dairy Admin
    '9999999999': const _Account(
      id: 'ADM-001',
      name: 'Demo Admin',
      identifier: '9999999999',
      password: '123456',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy Plant',
    ),
    'dairyadmin': const _Account(
      id: 'ADM-001',
      name: 'Dairy Plant Admin',
      identifier: 'dairyadmin',
      password: 'admin123',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy Plant',
    ),
    // Collector
    '123456': const _Account(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '123456',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    '8888888888': const _Account(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '8888888888',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    // Farmers (pre-seeded from FarmerRepository with default PIN 123456)
    '9876543210': const _Account(
      id: 'F001',
      name: 'Ram Singh',
      identifier: '9876543210',
      password: '123456',
      role: UserRole.farmer,
      center: 'Jaipur Center',
      collectorId: 'C-BHN-001',
    ),
    '9123456780': const _Account(
      id: 'F002',
      name: 'Rahul Kumar',
      identifier: '9123456780',
      password: '123456',
      role: UserRole.farmer,
      center: 'Ajmer Center',
      collectorId: 'C-BHN-001',
    ),
    '9988776655': const _Account(
      id: 'F003',
      name: 'Sita Devi',
      identifier: '9988776655',
      password: '123456',
      role: UserRole.farmer,
      center: 'Sikar Center',
      collectorId: 'C-BHN-001',
    ),
    '9812345678': const _Account(
      id: 'F004',
      name: 'Mohan Singh',
      identifier: '9812345678',
      password: '123456',
      role: UserRole.farmer,
      center: 'Jaipur Center',
      collectorId: 'C-BHN-001',
    ),
    '9765432109': const _Account(
      id: 'F005',
      name: 'Priya Sharma',
      identifier: '9765432109',
      password: '123456',
      role: UserRole.farmer,
      center: 'Ajmer Center',
      collectorId: 'C-BHN-001',
    ),
  };

  void addFarmerAccount({
    required String id,
    required String name,
    required String phone,
    String password = '123456',
    String center = 'Central Valley Collection Center',
    String? collectorId,
  }) {
    _accounts[phone.trim()] = _Account(
      id: id,
      name: name.trim(),
      identifier: phone.trim(),
      password: password,
      role: UserRole.farmer,
      center: center,
      collectorId: collectorId ?? 'C-BHN-001',
    );
  }

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<String?> registerFarmer({
    required String name,
    required String phone,
    required String password,
    String? referralCollectorId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_accounts.containsKey(phone)) {
      return 'This phone number is already registered. Please log in.';
    }
    final farmerId = 'F-${phone.substring(phone.length - 4)}';
    final account = _Account(
      id: farmerId,
      name: name.trim(),
      identifier: phone.trim(),
      password: password,
      role: UserRole.farmer,
      center: 'Central Valley Collection Center',
      collectorId: referralCollectorId ?? 'C-BHN-001',
    );
    _accounts[phone] = account;

    // Synchronize to FarmerRepository so collector and admin portals immediately reflect the new farmer
    FarmerRepository.instance.add(
      name: name.trim(),
      phone: phone.trim(),
      village: 'Central Valley',
      center: 'Central Valley Collection Center',
      collectorId: referralCollectorId ?? 'C-BHN-001',
    );

    return null;
  }

  Future<String?> registerCollector({
    required String name,
    required String phone,
    required String password,
    required String center,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanPhone = phone.trim();
    if (_accounts.containsKey(cleanPhone)) {
      return 'This phone number is already registered. Please log in.';
    }
    final collectorId =
        'C-COL-${cleanPhone.length >= 4 ? cleanPhone.substring(cleanPhone.length - 4) : cleanPhone}';
    final accountCenter =
        center.trim().isEmpty ? 'Central Valley Collection Center' : center.trim();
    final account = _Account(
      id: collectorId,
      name: name.trim(),
      identifier: cleanPhone,
      password: password,
      role: UserRole.collector,
      center: accountCenter,
    );
    _accounts[cleanPhone] = account;
    // Also allow logging in with the Collector ID
    _accounts[collectorId] = account;

    // Synchronize to CollectorRepository so admin sees this collector immediately
    CollectorRepository.instance.addCollector(
      id: collectorId,
      name: name.trim(),
      phone: cleanPhone,
      center: accountCenter,
      location: location ?? accountCenter,
    );

    return null;
  }

  Future<String?> registerAdmin({
    required String name,
    required String identifier,
    required String password,
    required String plantName,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanId = identifier.trim();
    if (_accounts.containsKey(cleanId)) {
      return 'This username/phone is already registered. Please log in.';
    }
    final adminId =
        'ADM-${cleanId.length >= 4 ? cleanId.substring(cleanId.length - 4) : cleanId}';
    final plant =
        plantName.trim().isEmpty ? 'Jaipur Cooperative Dairy Plant' : plantName.trim();
    final account = _Account(
      id: adminId,
      name: name.trim(),
      identifier: cleanId,
      password: password,
      role: UserRole.admin,
      center: plant,
    );
    _accounts[cleanId] = account;
    if (phone != null && phone.trim().isNotEmpty && !_accounts.containsKey(phone.trim())) {
      _accounts[phone.trim()] = account;
    }

    return null;
  }

  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanId = identifier.trim();
    final account = _accounts[cleanId];

    if (account == null || account.password != password) {
      return 'Invalid credentials. Please check and try again.';
    }

    _currentUser = AppUser(
      id: account.id,
      name: account.name,
      phone: account.identifier,
      role: account.role,
      center: account.center,
      collectorId: account.collectorId,
    );
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

