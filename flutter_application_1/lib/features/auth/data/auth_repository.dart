import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
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

class _DemoAccount {
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

  const _DemoAccount({
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

typedef _Account = _DemoAccount;

class AuthRepository extends ChangeNotifier {
  AuthRepository._() {
    try {
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    } catch (_) {}
  }

  static final AuthRepository instance = AuthRepository._();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isAdmin2FAVerified = false;
  bool get isAdmin2FAVerified => _isAdmin2FAVerified;

  AppUser? _pending2FAUser;
  AppUser? get pending2FAUser => _pending2FAUser;

  String _current2FAOtp = '246810';
  String get current2FAOtp => _current2FAOtp;

  Map<String, _DemoAccount> get _accounts => _demoAccounts;

  static final Map<String, _DemoAccount> _demoAccounts = {
    // Enterprise Dairy Admin (HQ) - 2FA Enforced with Mobile & Email
    '9999999999': const _DemoAccount(
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
    'dairyadmin': const _DemoAccount(
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
    // Collectors
    '123456': const _DemoAccount(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '123456',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    '8888888888': const _DemoAccount(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '8888888888',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    // Farmers (pre-seeded from FarmerRepository with default PIN 123456)
    '9876543210': const _DemoAccount(
      id: 'F001',
      name: 'Ram Singh',
      identifier: '9876543210',
      password: '123456',
      role: UserRole.farmer,
      center: 'Jaipur Center',
      collectorId: 'C-BHN-001',
    ),
    '9123456780': const _DemoAccount(
      id: 'F002',
      name: 'Rahul Kumar',
      identifier: '9123456780',
      password: '123456',
      role: UserRole.farmer,
      center: 'Ajmer Center',
      collectorId: 'C-BHN-001',
    ),
    '9988776655': const _DemoAccount(
      id: 'F003',
      name: 'Sita Devi',
      identifier: '9988776655',
      password: '123456',
      role: UserRole.farmer,
      center: 'Sikar Center',
      collectorId: 'C-BHN-001',
    ),
    '9812345678': const _DemoAccount(
      id: 'F004',
      name: 'Mohan Singh',
      identifier: '9812345678',
      password: '123456',
      role: UserRole.farmer,
      center: 'Jaipur Center',
      collectorId: 'C-BHN-001',
    ),
    '9765432109': const _DemoAccount(
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
    _demoAccounts[phone.trim()] = _DemoAccount(
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
  bool get isAuthenticated => _currentUser != null;

  String _formatEmail(String identifier) {
    final clean = identifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return '$clean@dairy.com';
  }

  UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'collector':
        return UserRole.collector;
      case 'farmer':
      default:
        return UserRole.farmer;
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    await _loadUserProfile(firebaseUser);
  }

  Future<void> _loadUserProfile(User firebaseUser, {_DemoAccount? fallbackDemo}) async {
    try {
      final profile = await _userService.getUserProfile(firebaseUser.uid);
      if (profile != null) {
        final email = (profile['email'] as String?) ?? firebaseUser.email ?? '';
        final phone = (profile['phone'] as String?) ?? email.split('@').first;
        _currentUser = AppUser(
          id: (profile['customId'] as String?) ?? firebaseUser.uid,
          name: (profile['name'] as String?) ?? 'User',
          phone: phone,
          role: _parseRole(profile['role'] as String?),
          center: (profile['center'] as String?) ?? 'Central Valley Collection Center',
          collectorId: profile['collectorId'] as String?,
        );
        notifyListeners();
        return;
      }
    } catch (_) {
      // Fall through to fallback if Firestore read fails
    }

    if (fallbackDemo != null) {
      _currentUser = AppUser(
        id: fallbackDemo.id,
        name: fallbackDemo.name,
        phone: fallbackDemo.identifier,
        role: fallbackDemo.role,
        center: fallbackDemo.center,
        collectorId: fallbackDemo.collectorId,
      );
    } else {
      final email = firebaseUser.email ?? '';
      _currentUser = AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? email.split('@').first,
        phone: email.split('@').first,
        role: UserRole.farmer,
      );
    }
    notifyListeners();
  }

  Future<String?> registerFarmer({
    required String name,
    required String phone,
    required String password,
    String? referralCollectorId,
  }) async {
    final cleanPhone = phone.trim();
    final farmerId = cleanPhone.length >= 4
        ? 'F-${cleanPhone.substring(cleanPhone.length - 4)}'
        : 'F-$cleanPhone';

    // Synchronize locally / fallback
    _demoAccounts[cleanPhone] = _DemoAccount(
      id: farmerId,
      name: name.trim(),
      identifier: cleanPhone,
      password: password,
      role: UserRole.farmer,
      center: 'Central Valley Collection Center',
      collectorId: referralCollectorId ?? 'C-BHN-001',
    );

    // Synchronize to FarmerRepository so collector and admin portals immediately reflect the new farmer
    FarmerRepository.instance.add(
      name: name.trim(),
      phone: cleanPhone,
      village: 'Central Valley',
      center: 'Central Valley Collection Center',
      collectorId: referralCollectorId ?? 'C-BHN-001',
    );

    try {
      final email = _formatEmail(cleanPhone);
      final credential = await _authService.registerUser(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _userService.createUserProfile(
          uid: uid,
          name: name.trim(),
          email: email,
          role: UserRole.farmer.name,
          phone: cleanPhone,
          center: 'Central Valley Collection Center',
          collectorId: referralCollectorId ?? 'C-BHN-001',
          customId: farmerId,
        );
      }

      await _authService.logoutUser();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This phone number is already registered. Please log in.';
      }
      if (e.code == 'weak-password') {
        return 'Password should be at least 6 characters.';
      }
      return e.message ?? 'Registration failed';
    } catch (_) {
      // If offline, registration succeeded locally in demo store
      return null;
    }
  }

  Future<String?> registerCollector({
    required String name,
    required String phone,
    required String password,
    required String center,
    String? location,
  }) async {
    final cleanPhone = phone.trim();
    final collectorId =
        'C-COL-${cleanPhone.length >= 4 ? cleanPhone.substring(cleanPhone.length - 4) : cleanPhone}';
    final accountCenter =
        center.trim().isEmpty ? 'Central Valley Collection Center' : center.trim();

    final account = _DemoAccount(
      id: collectorId,
      name: name.trim(),
      identifier: cleanPhone,
      password: password,
      role: UserRole.collector,
      center: accountCenter,
    );
    _demoAccounts[cleanPhone] = account;
    _demoAccounts[collectorId] = account;

    // Synchronize to CollectorRepository so admin sees this collector immediately
    CollectorRepository.instance.addCollector(
      id: collectorId,
      name: name.trim(),
      phone: cleanPhone,
      center: accountCenter,
      location: location ?? accountCenter,
    );

    try {
      final email = _formatEmail(cleanPhone);
      final credential = await _authService.registerUser(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _userService.createUserProfile(
          uid: uid,
          name: name.trim(),
          email: email,
          role: UserRole.collector.name,
          phone: cleanPhone,
          center: accountCenter,
          customId: collectorId,
        );
      }

      await _authService.logoutUser();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This phone number is already registered. Please log in.';
      }
      if (e.code == 'weak-password') {
        return 'Password should be at least 6 characters.';
      }
      return e.message ?? 'Registration failed';
    } catch (_) {
      return null;
    }
  }

  Future<String?> registerAdmin({
    required String name,
    required String identifier,
    required String password,
    required String plantName,
    String? phone,
  }) async {
    final cleanId = identifier.trim();
    final adminId =
        'ADM-${cleanId.length >= 4 ? cleanId.substring(cleanId.length - 4) : cleanId}';
    final plant =
        plantName.trim().isEmpty ? 'Jaipur Cooperative Dairy Plant' : plantName.trim();

    final account = _DemoAccount(
      id: adminId,
      name: name.trim(),
      identifier: cleanId,
      password: password,
      role: UserRole.admin,
      center: plant,
    );
    _demoAccounts[cleanId] = account;
    if (phone != null && phone.trim().isNotEmpty) {
      _demoAccounts[phone.trim()] = account;
    }

    try {
      final email = _formatEmail(cleanId);
      final credential = await _authService.registerUser(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _userService.createUserProfile(
          uid: uid,
          name: name.trim(),
          email: email,
          role: UserRole.admin.name,
          phone: phone?.trim().isNotEmpty == true ? phone!.trim() : cleanId,
          center: plant,
          customId: adminId,
        );
      }

      await _authService.logoutUser();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This username/phone is already registered. Please log in.';
      }
      if (e.code == 'weak-password') {
        return 'Password should be at least 6 characters.';
      }
      return e.message ?? 'Registration failed';
    } catch (_) {
      return null;
    }
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
    final cleanId = identifier.trim();
    final email = _formatEmail(cleanId);
    final demoAccount = _demoAccounts[cleanId];

    try {
      final credential = await _authService.loginUser(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _loadUserProfile(credential.user!, fallbackDemo: demoAccount);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // If using a built-in demo credential that hasn't been provisioned in Firebase yet,
      // auto-provision it in Firebase Auth and Firestore.
      if (demoAccount != null && demoAccount.password == password) {
        try {
          final regCred = await _authService.registerUser(
            email: email,
            password: password,
          );
          final uid = regCred.user?.uid;
          if (uid != null) {
            await _userService.createUserProfile(
              uid: uid,
              name: demoAccount.name,
              email: email,
              role: demoAccount.role.name,
              phone: demoAccount.identifier,
              center: demoAccount.center,
              collectorId: demoAccount.collectorId,
              customId: demoAccount.id,
            );
            await _loadUserProfile(regCred.user!, fallbackDemo: demoAccount);
            return null;
          }
        } catch (_) {
          // If Firebase provisioning fails (e.g. offline), allow demo session locally
          _currentUser = AppUser(
            id: demoAccount.id,
            name: demoAccount.name,
            phone: demoAccount.identifier,
            role: demoAccount.role,
            center: demoAccount.center,
            collectorId: demoAccount.collectorId,
          );
          notifyListeners();
          return null;
        }
      }

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Invalid credentials. Please check and try again.';
      }
      return e.message ?? 'Authentication failed.';
    } catch (_) {
      // Offline fallback for demo accounts
      if (demoAccount != null && demoAccount.password == password) {
        _currentUser = AppUser(
          id: demoAccount.id,
          name: demoAccount.name,
          phone: demoAccount.identifier,
          role: demoAccount.role,
          center: demoAccount.center,
          collectorId: demoAccount.collectorId,
        );
        notifyListeners();
        return null;
      }
      return 'An error occurred while signing in.';
    }
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

  Future<void> logout() async {
    _currentUser = null;
    _pending2FAUser = null;
    _isAdmin2FAVerified = false;
    notifyListeners();
    try {
      await _authService.logoutUser();
    } catch (_) {}
  }
}
