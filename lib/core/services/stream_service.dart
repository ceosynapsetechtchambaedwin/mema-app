import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/models/actualite_model.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/models/video_model.dart';
import 'package:mema/models/donation_model.dart';

class StreamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔁 Stream des prédications planifiées ou déjà disponibles
  Stream<List<Predication>> getPredicationsStream() {
    return _db
        .collection('predications')
        .where('scheduledAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Predication.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des news déjà publiées //Ok 1
  Stream<List<News>> getNewsStream() {
    return _db
        .collection('news')
        .where('scheduledAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => News.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des vidéos (pas de scheduledAt ici)
  Stream<List<Video>> getVideosStream() {
    return _db
        .collection('videos')
        .orderBy('createdAt', descending: true) // ou autre champ si besoin
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Video.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des dons (si on veut les voir en temps réel)
  Stream<List<Donation>> getDonationsStream() {
    return _db
        .collection('dons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Donation.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des 4 prédications les plus récentes planifiées ou déjà disponibles
  Stream<List<Predication>> getPredicationsStreamLimit(int i) {
    return _db
        .collection('predications')
        .where('createdAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('createdAt', descending: true)
        .limit(i) // Limite à 4 prédictions les plus récentes
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Predication.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des 4 actualités les plus récentes déjà publiées
  Stream<List<News>> getNewsStreamLimit(int i) {
    return _db
        .collection('news')
        .where('scheduledAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('scheduledAt', descending: true)
        .limit(i) // Limite à 4 actualités les plus récentes
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => News.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des 4 vidéos les plus récentes (pas de scheduledAt ici)
  Stream<List<Video>> getVideosStreamLimit(int i) {
    return _db
        .collection('videos')
        .orderBy('createdAt', descending: true) // Vous pouvez modifier ce critère si nécessaire
        .limit(i) // Limite à 4 vidéos les plus récentes
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Video.fromFirestore(doc)).toList());
  }

  /// 🔁 Stream des 4 derniers dons effectués
  Stream<List<Donation>> getDonationsStreamLimit(int i) {
    return _db
        .collection('dons')
        .orderBy('createAt', descending: true)
        .limit(i) // Limite à 4 dons les plus récents
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Donation.fromFirestore(doc)).toList());
  }
}
