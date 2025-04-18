// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream pour écouter les changements d'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inscription avec email & mot de passe
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user;
    } catch (e) {
      print('Erreur inscription: $e');
      rethrow;
    }
  }

  /// Connexion avec email & mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user;
    } catch (e) {
      print('Erreur connexion email: $e');
      rethrow;
    }
  }

  /// Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Erreur connexion Google: $e');
      rethrow;
    }
  }

  /// Déconnexion de tous les fournisseurs
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Erreur déconnexion: $e');
      rethrow;
    }
  }

  /// Récupérer l'utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;
}
