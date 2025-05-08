// import 'package:flutter/material.dart';
// import 'package:mema/models/actualite_model.dart';
// import 'package:mema/view_models/langue_view_model.dart';
// import 'package:mema/core/services/stream_service.dart';
// import 'package:mema/core/utils/share.dart';
// import 'package:provider/provider.dart';

// class NewsListPage extends StatelessWidget {
//   const NewsListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isFrench = Provider.of<LanguageProvider>(context).isFrench;
//     final primaryColor = const Color(0xFF1A237E);

//     return Scaffold(
//       body: StreamBuilder<List<News>>(
//         stream: StreamService().getNewsStream(), // Remplace par ton stream réel
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Text(
//                 isFrench ? "Aucune actualité disponible" : "No news available",
//                 style: const TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           final newsList = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: newsList.length,
//             itemBuilder: (context, index) {
//               final news = newsList[index];
//               return _buildNewsCard(context, isFrench, news);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNewsCard(BuildContext context, bool isFrench, News news) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (news.imageUrl.isNotEmpty)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   news.imageUrl,
//                   height: 160,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             const SizedBox(height: 10),
//             Text(
//               isFrench ? news.titreFr : news.titreEn,
//               style: const TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               isFrench ? news.descriptionFr : news.descriptionEn,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "📅 ${news.createdAt}",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.share),
//                   onPressed: () {
//                     shareContent(
//                       "${isFrench ? news.titreFr : news.titreEn}\nTéléchargez l'application ici : [Lien]",
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


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
                debugPrint("Erreur de conversion du document actualité : $e");
                return null;
              }
            })
            .whereType<News>()
            .toList();
      });
    } catch (e, stack) {
      debugPrint("Erreur dans getNewsStream : $e");
      debugPrint("Stacktrace : $stack");
      yield [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;
    final primaryColor = const Color(0xFF1A237E);

    return Scaffold(
       appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Actualités'),
      ),
      backgroundColor: const Color(0xFFF4F6FA),
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
                style: const TextStyle(fontSize: 16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                errorWidget:
                    (context, url, error) =>
                        Image.asset('assets/background.jpg', fit: BoxFit.cover),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isFrench ? news.titreFr : news.titreEn,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Colors.blue, size: 18), // publication certifiée
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isFrench ? news.descriptionFr : news.descriptionEn,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "📅 $formattedDate",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
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

  String _formatDate(DateTime dateTime) {
    try {
      return timeago.format(dateTime, locale: 'fr'); // ou 'en' si anglais
    } catch (e) {
      return dateTime.toString();
    }
  }
}
