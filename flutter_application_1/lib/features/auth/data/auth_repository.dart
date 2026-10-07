import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class AppUser {
  final String name;
  final String phone;

  const AppUser({required this.name, required this.phone});
}

class AuthRepository extends ChangeNotifier {
  AuthRepository._() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = AppUser(
          name: user.displayName ?? 'User', 
          phone: user.email?.replaceAll('@dairy.com', '') ?? ''
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }
  static final AuthRepository instance = AuthRepository._();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<String?> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      final email = '$phone@dairy.com';
      final credential = await _authService.registerUser(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _userService.createUserProfile(
          uid: credential.user!.uid,
          name: name.trim(),
          email: email,
          role: 'farmer',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This mobile number is already registered. Please log in.';
      }
      return e.message ?? 'Registration failed';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final email = '$phone@dairy.com';
      await _authService.loginUser(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException {
      return 'Wrong mobile number or password';
    } catch (_) {
      return 'An error occurred';
    }
  }

  Future<void> logout() async {
    await _authService.logoutUser();
  }
}


