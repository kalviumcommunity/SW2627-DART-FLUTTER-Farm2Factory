import 'package:flutter/foundation.dart';

class AppUser {
  final String name;
  final String phone;

  const AppUser({required this.name, required this.phone});
}

class _Account {
  final String name;
  final String password;

  const _Account({required this.name, required this.password});
}

/// DEMO login (in memory, lost when the app restarts).
/// Later, Firebase Auth replaces this class: it stores passwords safely.
/// Never save a real password in plain text on the phone.
///
/// Demo account you can always use:  9999999999  /  123456
class AuthRepository extends ChangeNotifier {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Map<String, _Account> _accounts = {
    '9999999999': const _Account(name: 'Demo Admin', password: '123456'),
  };

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  /// Returns null when it worked, otherwise an error message to show.
  Future<String?> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // fake network
    if (_accounts.containsKey(phone)) {
      return 'This mobile number is already registered. Please log in.';
    }
    _accounts[phone] = _Account(name: name.trim(), password: password);
    return null;
  }

  /// Returns null when it worked, otherwise an error message to show.
  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // fake network
    final account = _accounts[phone];
    // One message for both cases, so nobody can guess which numbers exist.
    if (account == null || account.password != password) {
      return 'Wrong mobile number or password';
    }
    _currentUser = AppUser(name: account.name, phone: phone);
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
