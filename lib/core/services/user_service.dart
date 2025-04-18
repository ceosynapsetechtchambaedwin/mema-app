import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer un nouvel utilisateur
  Future<void> createUser(User user) async {
    try {
      await _db.collection('users').doc(user.userId).set(user.toMap());
    } catch (e) {
      print('Erreur création utilisateur: $e');
    }
  }

  // Récupérer un utilisateur par son ID
  Future<User?> getUserById(String userId) async {
    try {
      var doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur récupération utilisateur: $e');
      return null;
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    try {
      await _db.collection('users').doc(user.userId).update(user.toMap());
    } catch (e) {
      print('Erreur mise à jour utilisateur: $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      print('Erreur suppression utilisateur: $e');
    }
  }
}
