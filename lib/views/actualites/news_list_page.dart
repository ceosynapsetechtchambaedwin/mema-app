


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mema/models/actualite_model.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/core/services/stream_service.dart';
import 'package:mema/core/utils/share.dart';
import 'package:provider/provider.dart';

class NewsListPage extends StatelessWidget {
  NewsListPage({super.key});
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<News>> getNewsStreamOk() async* {
    try {
      yield* _db.collection('news').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return News.fromFirestore(doc);
              } catch (e) {
                debugPrint("Erreur de conversion : $e");
                return null;
              }
            })
            .whereType<News>()
            .toList();
      });
    } catch (e, stack) {
      debugPrint("Erreur dans getNewsStream : $e");
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench ? 'Actualités' : 'News'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<News>>(
        stream: getNewsStreamOk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isFrench ? "Aucune actualité disponible" : "No news available",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          final newsList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return _buildNewsCard(context, isFrench, news);
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, bool isFrench, News news) {
    final date = news.createdAt.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (news.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 200, width: double.infinity, color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/background.jpg', fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFrench ? news.titreFr : news.titreEn,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isFrench ? news.descriptionFr : news.descriptionEn,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📅 $formattedDate",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        shareContent(
                          "${isFrench ? news.titreFr : news.titreEn}\nTéléchargez l'application ici : [Lien]",
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
