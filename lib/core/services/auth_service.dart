// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream pour écouter les changements d'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;

  /// Vérifie si un utilisateur est connecté
  bool get isLoggedIn => _auth.currentUser != null;

  /// Inscription avec email & mot de passe
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credentials.user;
    } catch (e) {
      final message = getMessageFromError(e);
      throw Exception(message);
    }
  }

  /// Connexion avec email & mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return credentials.user;
    } catch (e) {
      final message = getMessageFromError(e);
      throw Exception(message);
    }
  }



 /// Connexion avec Google
Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("Connexion annulée par l'utilisateur.");
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    notifyListeners();
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    final message = getMessageFromFirebaseErrorCode(e.code);
    throw Exception(message);
  } catch (e) {
    throw Exception("Une erreur est survenue : ${e.toString()}");
  }
}



  /// Déconnexion de tous les fournisseurs
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners();
    } catch (e) {
      final message = getMessageFromError(e);
      throw Exception(message);
    }
  }

  /// Envoie de l'e-mail de vérification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Met à jour le nom d'affichage de l'utilisateur
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload(); // Recharge pour que le changement soit pris en compte
      notifyListeners();
    }
  }

  /// Gestion des erreurs lisibles pour l'utilisateur
  String getMessageFromError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return "L'adresse e-mail est invalide.";
        case 'user-disabled':
          return "Ce compte a été désactivé.";
        case 'user-not-found':
          return "Aucun utilisateur trouvé avec cet e-mail.";
        case 'wrong-password':
          return "Mot de passe incorrect.";
        case 'email-already-in-use':
          return "Cet e-mail est déjà utilisé.";
        case 'weak-password':
          return "Le mot de passe est trop faible.";
        case 'operation-not-allowed':
          return "Cette opération n'est pas autorisée.";
        default:
          return "Erreur : ${error.message}";
      }
    }
    return "Une erreur inconnue est survenue.";
  }
}



String getMessageFromFirebaseErrorCode(String code) {
  switch (code) {
    case 'account-exists-with-different-credential':
      return "Un compte existe déjà avec une autre méthode de connexion.";
    case 'invalid-credential':
      return "Les identifiants Google sont invalides.";
    case 'user-disabled':
      return "Ce compte a été désactivé.";
    case 'user-not-found':
      return "Aucun utilisateur trouvé avec cet identifiant.";
    case 'wrong-password':
      return "Mot de passe incorrect.";
    default:
      return "Une erreur inconnue est survenue.";
  }
}

