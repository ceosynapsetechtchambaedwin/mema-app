import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/audio/audio_player_page2.dart';
import 'package:intl/intl.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PredicationResultsPage extends StatelessWidget {
  final String tag;

  PredicationResultsPage({Key? key, required this.tag}) : super(key: key);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// On ne filtre plus que sur `tagFr` côté Firestore.
  Stream<List<Predication>> getFilteredPredications(String tag) {
    return _db
        .collection('predications')
        .where('tagFr', isEqualTo: tag)
        .snapshots()
        .map((snapshot) {
      // Convertit en liste de modèles
      var list = snapshot.docs
          .map((doc) => Predication.fromFirestore(doc))
          .toList();

      // Filtrer les entrées dont createdAt <= maintenant
      list = list
          .where((p) => p.createdAt.toDate().isBefore(DateTime.now()))
          .toList();

      // Trier en mémoire par createdAt descendant
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return list;
    });
  }

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String savePath = '${dir.path}/$fileName.mp3';

      await Dio().download(url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fichier téléchargé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de téléchargement")),
      );
      debugPrint('❌ Erreur de téléchargement : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ModernAppBar(
          context,
          title: isFrench ? 'Résultats' : 'Results',
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F6),
      body: StreamBuilder<List<Predication>>(
        stream: getFilteredPredications(tag),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child:
                  Text(snapshot.error?.toString() ?? 'Une erreur est survenue'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final predications = snapshot.data!;
          if (predications.isEmpty) {
            return Center(
              child: Text(isFrench
                  ? 'Aucune prédication trouvée pour "$tag"'
                  : 'No sermon found for "$tag"'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: predications.length,
            itemBuilder: (context, index) {
              final p = predications[index];
              final date = p.createdAt.toDate();
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(date);

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
                          isFrench ? p.titreFr : p.titreEn,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black87),
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
                        isFrench ? p.descriptionFr : p.descriptionEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
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
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              AudioPlayerPage(predication: p)),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'partager') {
                        Share.share(p.audioUrl, subject: p.titreFr);
                      } else if (value == 'télécharger') {
                        _downloadFile(p.audioUrl, p.titreFr, context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'partager',
                        child: Text(isFrench ? "Partager" : "Share"),
                      ),
                      PopupMenuItem(
                        value: 'télécharger',
                        child: Text(isFrench ? "Télécharger" : "Download"),
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
