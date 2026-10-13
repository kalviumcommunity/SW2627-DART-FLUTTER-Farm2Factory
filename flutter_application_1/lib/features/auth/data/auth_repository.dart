import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

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

class _DemoAccount {
  final String id;
  final String name;
  final String identifier;
  final String password;
  final UserRole role;
  final String center;
  final String? collectorId;

  const _DemoAccount({
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
  AuthRepository._() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  static final AuthRepository instance = AuthRepository._();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  static const Map<String, _DemoAccount> _demoAccounts = {
    '9999999999': _DemoAccount(
      id: 'ADM-001',
      name: 'Demo Admin',
      identifier: '9999999999',
      password: '123456',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy Plant',
    ),
    'dairyadmin': _DemoAccount(
      id: 'ADM-001',
      name: 'Dairy Plant Admin',
      identifier: 'dairyadmin',
      password: 'admin123',
      role: UserRole.admin,
      center: 'Jaipur Cooperative Dairy Plant',
    ),
    '123456': _DemoAccount(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '123456',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    '8888888888': _DemoAccount(
      id: 'C-BHN-001',
      name: 'Ramesh Kumar',
      identifier: '8888888888',
      password: '123456',
      role: UserRole.collector,
      center: 'Central Valley Collection Center',
    ),
    '9876543210': _DemoAccount(
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

  String _formatEmail(String identifier) {
    final clean = identifier.trim();
    if (clean.contains('@')) return clean;
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
    try {
      final cleanPhone = phone.trim();
      final email = _formatEmail(cleanPhone);
      final credential = await _authService.registerUser(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        final farmerId = cleanPhone.length >= 4
            ? 'F-${cleanPhone.substring(cleanPhone.length - 4)}'
            : 'F-$cleanPhone';
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
      return 'An unexpected error occurred during registration.';
    }
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
      return 'An error occurred while signing in.';
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    try {
      await _authService.logoutUser();
    } catch (_) {}
  }
}


