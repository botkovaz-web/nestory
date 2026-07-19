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
    
    await _db.collection('users').doc(result.user!.uid).set({
      'uid': result.user!.uid,
      'name': name,
      'email': email,
      'isPremium': false, // Nový používateľ je v základe free
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

  // HLBOKÉ vymazanie používateľa a všetkých jeho dát
  Future<void> deleteAccount(String password) async {
    final currentUser = _auth.currentUser;
    final uid = currentUser?.uid;
    if (uid == null || currentUser?.email == null) return;

    try {
      // 1. Re-autentifikácia (nevyhnutné pre produkciu)
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);

      // 2. Zoznam všetkých podkolekcií, ktoré treba vyčistiť
      final subcollections = ['materials', 'tools', 'projects', 'events'];

      for (var collName in subcollections) {
        final snap = await _db.collection('users').doc(uid).collection(collName).get();
        for (var doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // 3. Vymazanie hlavného profilu
      await _db.collection('users').doc(uid).delete();

      // 4. Vymazanie samotného Auth konta
      await currentUser.delete();
      
    } catch (e) {
      print('Chyba pri hĺbkovom mazaní účtu: $e');
      rethrow;
    }
  }
}
