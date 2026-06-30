import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Anonim giriş (hızlı başlangıç için)
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // Email/şifre ile kayıt
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kullanıcı profilini güncelle
    await credential.user?.updateDisplayName(displayName);

    // Firestore'da kullanıcı belgesi oluştur
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'photoUrl': '',
    });

    return credential;
  }

  // Email/şifre ile giriş
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Çıkış
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı adı güncelle
  Future<void> updateDisplayName(String displayName) async {
    await currentUser?.updateDisplayName(displayName);
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'displayName': displayName,
      });
    }
  }

  // Kullanıcı bilgilerini Firestore'dan al
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
