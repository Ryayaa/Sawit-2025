import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Get current user state
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _db.child('users/${user.uid}/role').get();
      return snapshot.value as String?;
    }
    return null;
  }

  Stream<String> getUserDisplayName() async* {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Updated path to include "User" node
        Stream<DatabaseEvent> stream = _db.child('User/${user.uid}').onValue;

        await for (final event in stream) {
          if (event.snapshot.exists) {
            final userData = event.snapshot.value as Map<dynamic, dynamic>;
            // Check role value and set appropriate name
            if (userData['role'] == 1) {
              yield "${userData['name']} ";
            } else {
              yield "${userData['name']} ";
            }
          } else {
            yield user.displayName ?? 'User';
          }
        }
      } else {
        yield 'User';
      }
    } catch (e) {
      print('Error getting user display name: $e');
      yield 'User';
    }
  }

  Future<void> createUserProfile(String uid, String name, String email,
      {int role = 2}) async {
    try {
      // Updated path to include "User" node
      await _db.child('User/$uid').set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Stream<Map<String, dynamic>> getUserData() async* {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Updated path to include "User" node
        Stream<DatabaseEvent> stream = _db.child('User/${user.uid}').onValue;

        await for (final event in stream) {
          if (event.snapshot.exists) {
            final userData = event.snapshot.value as Map<dynamic, dynamic>;
            print('Fetched user data: $userData'); // Debug print
            yield {
              'name': userData['name'],
              'role': userData['role'],
              'email': userData['email']
            };
          }
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
      yield {'name': 'User', 'role': 2, 'email': ''};
    }
  }
}
