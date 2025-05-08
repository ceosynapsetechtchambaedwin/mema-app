import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:mema/models/predication_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PredicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Méthode pour incrémenter le nombre de téléchargements
  Future<void> incrementDownloadCount(String predicationId) async {
    try {
      var predicationRef = _db.collection('predications').doc(predicationId);

      await _db.runTransaction((transaction) async {
        var snapshot = await transaction.get(predicationRef);
        if (snapshot.exists) {
          var predication = Predication.fromFirestore(snapshot);
          transaction.update(predicationRef, {
            'download_count': predication.downloadCount! + 1,
          });
        }
      });
    } catch (e) {
      print('Erreur lors de l\'incrémentation du téléchargement: $e');
    }
  }

  // Méthode pour incrémenter le nombre de partages
  Future<void> incrementShareCount(String predicationId) async {
    try {
      var predicationRef = _db.collection('predications').doc(predicationId);

      await _db.runTransaction((transaction) async {
        var snapshot = await transaction.get(predicationRef);
        if (snapshot.exists) {
          var predication = Predication.fromFirestore(snapshot);
          transaction.update(predicationRef, {
            'share_count': predication.shareCount! + 1,
          });
        }
      });
    } catch (e) {
      print('Erreur lors de l\'incrémentation du partage: $e');
    }
  }

  // Méthode pour récupérer les prédications par tag
  Future<List<Predication>> getPredicationsByTag(String tag) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('predications')
          .where('tag_fr', isEqualTo: tag)
          .get();

      List<Predication> predications = [];
      querySnapshot.docs.forEach((doc) {
        predications.add(Predication.fromFirestore(doc));
      });

      return predications;
    } catch (e) {
      print('Erreur lors de la récupération des prédications: $e');
      return [];
    }
  }

  // Nouvelle méthode : Télécharger et sauvegarder l'audio localement
  Future<String?> downloadAndSaveAudioLocally(String url, String fileName) async {
    try {
      // Demande de permission (Android)
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Permission refusée");
        return null;
      }

      Directory? appDir;
      if (Platform.isAndroid) {
        appDir = Directory('/storage/emulated/0/Eglise'); // Dossier "Eglise"
      } else {
        appDir = await getApplicationDocumentsDirectory(); // iOS fallback
      }

      if (!(await appDir.exists())) {
        await appDir.create(recursive: true);
      }

      String filePath = '${appDir.path}/$fileName.mp3';

      Dio dio = Dio();
      await dio.download(url, filePath);

      print('Audio sauvegardé dans : $filePath');
      return filePath;
    } catch (e) {
      print("Erreur de téléchargement : $e");
      return null;
    }
  }


  static Future<void> deleteAudio(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

static Future<List<FileSystemEntity>> getAudioFiles(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];
    return dir.listSync().where((file) => file.path.endsWith('.mp3')).toList();
  }  
}
