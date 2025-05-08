// // lib/pages/predication_list_page.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mema/models/predication_model.dart';
// import 'package:mema/views/audio/audio_player_page2.dart';
// import 'audio_player_page.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:dio/dio.dart';

// class PredicationListPage extends StatelessWidget {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   Stream<List<Predication>> getPredicationsStream() {
//     return _db
//         .collection('predications')
//         .where('scheduledAt', isLessThanOrEqualTo: Timestamp.now())
//         .orderBy('scheduledAt', descending: true)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.docs.map((doc) => Predication.fromFirestore(doc)).toList());
//   }

//   Future<void> _downloadFile(String url, String fileName) async {
//     final status = await Permission.storage.request();
//     if (status.isGranted) {
//       final savePath = '/storage/emulated/0/Download/$fileName.mp3';
//       await Dio().download(url, savePath);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: StreamBuilder<List<Predication>>(
//         stream: getPredicationsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) return Center(child: Text('Erreur : ${snapshot.error}'));
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

//           final predications = snapshot.data!;
//           return ListView.builder(
//             itemCount: predications.length,
//             itemBuilder: (context, index) {
//               final p = predications[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: ListTile(
//                   contentPadding: EdgeInsets.all(16),
//                   title: Text(p.titreFr, style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Text(p.descriptionFr, maxLines: 2, overflow: TextOverflow.ellipsis),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AudioPlayerPage(predication: p),
//                       ),
//                     );
//                   },
//                   trailing: PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'partager') {
//                         Share.share(p.audioUrl, subject: p.titreFr);
//                       } else if (value == 'télécharger') {
//                         _downloadFile(p.audioUrl, p.titreFr);
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       PopupMenuItem(value: 'partager', child: Text("Partager")),
//                       PopupMenuItem(value: 'télécharger', child: Text("Télécharger")),
//                     ],
//                     icon: Icon(Icons.more_vert),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/views/audio/audio_player_page2.dart';
import 'package:intl/intl.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PredicationListPage extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Predication>> getPredicationsStream2() {
    return _db
        .collection('predications')
        .where('createdAt', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Predication.fromFirestore(doc))
                  .toList(),
        );
  }

  Stream<List<Predication>> getPredicationsStream() async* {
    try {
      yield* _db.collection('predications').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return Predication.fromFirestore(doc);
              } catch (e) {
                debugPrint("Erreur de conversion du document prédication : $e");
                return null;
              }
            })
            .whereType<Predication>()
            .toList();
      });
    } catch (e, stack) {
      debugPrint("Erreur dans getPredicationsStream : $e");
      debugPrint("Stacktrace : $stack");
      yield [];
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      // Obtenir le dossier privé de l'application
      final Directory dir = await getApplicationDocumentsDirectory();
      final String savePath = '${dir.path}/$fileName.mp3';

      Dio dio = Dio();
      await dio.download(url, savePath);

      print('✅ Fichier téléchargé avec succès : $savePath');
      // Optionnel : montrer un snackbar pour confirmer le téléchargement
    } catch (e) {
      print('❌ Erreur de téléchargement : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Podcasts'),
      ),
      backgroundColor: const Color(0xFFF2F4F6),
      
      body: StreamBuilder<List<Predication>>(
        stream: getPredicationsStream2(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error?.toString() ?? 'Une erreur est survenue',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final predications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: predications.length,
            itemBuilder: (context, index) {
              final p = predications[index];
              final date = p.createdAt.toDate();
              final formattedDate = "Date : ${DateFormat('dd/MM/yyyy HH:mm').format(date)}";
          

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.audiotrack,
                      color: Color(0xFF1976D2),
                      size: 28,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.titreFr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blueAccent,
                        size: 18,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        p.descriptionFr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AudioPlayerPage(predication: p),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'partager') {
                        Share.share(p.audioUrl, subject: p.titreFr);
                      } else if (value == 'télécharger') {
                        _downloadFile(p.audioUrl, p.titreFr);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'partager',
                            child: Text("Partager"),
                          ),
                          const PopupMenuItem(
                            value: 'télécharger',
                            child: Text("Télécharger"),
                          ),
                        ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
