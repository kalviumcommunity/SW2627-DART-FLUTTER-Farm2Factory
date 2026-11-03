import 'package:flutter/foundation.dart';
import '../../admin/data/collector_repository.dart';
import '../../farmers/data/farmer_repository.dart';

enum UserRole { farmer, collector, admin, manager }

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String center;
  final String? collectorId;
  final bool twoFactorEnabled;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.role,
    this.center = 'Central Valley Collection Center',
    this.collectorId,
    this.twoFactorEnabled = false,
  });
}

class _Account {
  final String id;
  final String name;
  final String identifier; // phone or username
  final String phone;
  final String email;
  final String password;
  final UserRole role;
  final String center;
  final String? collectorId;
  final bool twoFactorEnabled;

  const _Account({
    required this.id,
    required this.name,
    required this.identifier,
    this.phone = '',
    this.email = '',
    required this.password,
    required this.role,
    this.center = 'Central Valley Collection Center',
    this.collectorId,
    this.twoFactorEnabled = false,
  });
}

class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  bool _isAdmin2FAVerified = false;
  bool get isAdmin2FAVerified => _isAdmin2FAVerified;

  AppUser? _pending2FAUser;
  AppUser? get pending2FAUser => _pending2FAUser;

  String _current2FAOtp = '246810';
  String get current2FAOtp => _current2FAOtp;

  final Map<String, _Account> _accounts = {
    // Enterprise Dairy Admin (HQ) - 2FA Enforced with Mobile & Email
    '9999999999': const _Account(
      id: 'ADM-001',
      name: 'Demo Admin',
      identifier: '9999999999',
      phone: '9999999999',
      email: 'admin.controller@farm2factory.in',
      password: '123456',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy (HQ)',
      twoFactorEnabled: true,
    ),
    'dairyadmin': const _Account(
      id: 'ADM-001',
      name: 'Dairy Plant Admin',
      identifier: 'dairyadmin',
      phone: '9999999999',
      email: 'admin.controller@farm2factory.in',
      password: 'admin123',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy (HQ)',
      twoFactorEnabled: true,
    ),
    // Center Manager (Branch Operations)
    '7777777777': const _Account(
      id: 'MGR-001',
      name: 'Vikram Patel',
      identifier: '7777777777',
      phone: '7777777777',
      email: 'manager.tonk@farm2factory.in',
      password: '123456',
      role: UserRole.manager,
      center: 'Tonk Chilling Center #3',
      twoFactorEnabled: false,
    ),
    'centermanager': const _Account(
      id: 'MGR-001',
      name: 'Vikram Patel',
      identifier: 'centermanager',
      phone: '7777777777',
      email: 'manager.tonk@farm2factory.in',
      password: '123456',
      role: UserRole.manager,
      center: 'Tonk Chilling Center #3',
      twoFactorEnabled: false,
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

  Future<String?> registerManager({
    required String name,
    required String identifier,
    required String password,
    required String centerName,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final cleanId = identifier.trim();
    if (_accounts.containsKey(cleanId)) {
      return 'This username/phone is already registered. Please log in.';
    }
    final mgrId =
        'MGR-${cleanId.length >= 4 ? cleanId.substring(cleanId.length - 4) : cleanId}';
    final center =
        centerName.trim().isEmpty ? 'Tonk Chilling Center #3' : centerName.trim();
    final account = _Account(
      id: mgrId,
      name: name.trim(),
      identifier: cleanId,
      password: password,
      role: UserRole.manager,
      center: center,
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

    final loggedInUser = AppUser(
      id: account.id,
      name: account.name,
      phone: account.phone.isNotEmpty ? account.phone : account.identifier,
      email: account.email.isNotEmpty ? account.email : 'admin.controller@farm2factory.in',
      role: account.role,
      center: account.center,
      collectorId: account.collectorId,
      twoFactorEnabled: account.twoFactorEnabled,
    );

    if (account.role == UserRole.admin && account.twoFactorEnabled) {
      _pending2FAUser = loggedInUser;
      _current2FAOtp = '246810';
      _isAdmin2FAVerified = false;
      _currentUser = null; // Requires 2FA verification to unlock session
      notifyListeners();
      return null;
    }

    _currentUser = loggedInUser;
    notifyListeners();
    return null;
  }

  void prepareAdmin2FA(AppUser user) {
    _pending2FAUser = user;
    _current2FAOtp = '246810';
    _isAdmin2FAVerified = false;
    notifyListeners();
  }

  void resendAdmin2FAOtp() {
    _current2FAOtp = '246810';
    notifyListeners();
  }

  bool verifyAdmin2FA(String otp) {
    if (otp.trim() == _current2FAOtp) {
      if (_pending2FAUser != null) {
        _currentUser = _pending2FAUser;
      }
      _isAdmin2FAVerified = true;
      _pending2FAUser = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockAdminSession() {
    _isAdmin2FAVerified = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _pending2FAUser = null;
    _isAdmin2FAVerified = false;
    notifyListeners();
  }
}

