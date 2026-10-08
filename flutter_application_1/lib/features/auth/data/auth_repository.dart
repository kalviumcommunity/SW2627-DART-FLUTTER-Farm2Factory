import 'package:flutter/foundation.dart';

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
    // Farmer
    '9876543210': const _Account(
      id: 'F-BHN-0123',
      name: 'Ram Singh',
      identifier: '9876543210',
      password: '123456',
      role: UserRole.farmer,
      center: 'Central Valley Collection Center',
      collectorId: 'C-BHN-001',
    ),
  };

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

