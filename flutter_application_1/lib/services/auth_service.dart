import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Login
  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  // Register
  Future<UserCredential?> registerUser(String email, String password, String name, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store user role and name in Firestore
      if (userCredential.user != null) {
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          role: role,
        );
        
        await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
      }
      
      return userCredential;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
