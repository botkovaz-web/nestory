import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sledovanie stavu prihlásenia
  Stream<User?> get user => _auth.authStateChanges();

  // Prihlásenie
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Registrácia + vytvorenie profilu vo Firestore
  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Vytvorenie dokumentu používateľa
    await _db.collection('users').doc(result.user!.uid).set({
      'uid': result.user!.uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return result;
  }

  // Odhlásenie
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Získanie ID aktuálneho používateľa
  String? get currentUserId => _auth.currentUser?.uid;
}
