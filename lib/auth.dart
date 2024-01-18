import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      // Anonymous sign-in successful, handle user navigation here
      // You can access the anonymous user using userCredential.user
    } catch (e) {
      // Handle sign-in errors
      print('Failed to sign in anonymously: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = getCurrentUserId();
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('userData').doc(userId).get();
        return userDoc.data() as Map<String, dynamic>?;
      } catch (e) {
        print('Error fetching user profile: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
  bool isUserAnonymous() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null && user.isAnonymous;
  }
}