import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
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


  Future<void> createOrUpdateUser(User user) async {
    try {
      final docRef = _userCollection.doc(user.userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Mettre à jour les champs (sans écraser createdAt ou role s’ils ne changent pas)
        await docRef.update({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'profile_image': user.profileImage,
        });
      } else {
        // Créer un nouvel utilisateur
        await docRef.set(user.toMap());
      }
    } catch (e) {
      print("Erreur lors de la création/mise à jour de l'utilisateur : $e");
      rethrow;
    }
  }
}
