
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mema/models/video_model.dart';
import 'package:mema/views/video/TemoignageDetail.dart';
import 'package:mema/views/video/video_player_page.dart';

class TemoignagesListPage extends StatefulWidget {
  const TemoignagesListPage({super.key});

  @override
  State<TemoignagesListPage> createState() => _TemoignagesListPageState();
}

class _TemoignagesListPageState extends State<TemoignagesListPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Video>> getVideosStream() {
    return _db
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Video.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench?'Témoignages':'testimonials'),
      ),
      body: StreamBuilder<List<Video>>(
        stream: getVideosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(isFrench?"Aucun témoignage pour le moment.":"No testimonials for now."));
          }

          final videos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildTemoignageCard(context, video,isFrench);
            },
          );
        },
      ),
    );
  }

  Widget _buildTemoignageCard(BuildContext context, Video video,bool isFrench) {
    final videoId = YoutubePlayer.convertUrlToId(video.youtubeUrl);

    final imageUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/0.jpg'
        : null;

    return AnimatedContainer(
      
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de la vidéo ou placeholder
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(videoUrl: video.youtubeUrl,descriptionEn: video.descriptionEn,descriptionFr: video.descriptionFr,),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/news_placeholder.jpeg',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/news_placeholder.jpeg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              isFrench?video.descriptionFr:video.descriptionEn,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 ${"Date:${truncateWithEllipsis("${video.createdAt.toDate()}")}"}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 22, color: Colors.grey),
                      tooltip: isFrench?"Partager":"share",
                      onPressed: () {
                        Share.share(
                          isFrench?"Regarde ce témoignage : ${video.descriptionFr}\n${video.youtubeUrl}":"Check out this testimony: ${video.descriptionFr}\n${video.youtubeUrl}",
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 22, color: Colors.grey),
                      tooltip: isFrench?"Détails":"Details",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemoignageDetailPage(
                              title: video.descriptionFr,
                              description: video.descriptionEn,
                              date: video.createdAt,
                              url: video.youtubeUrl,
                            ),
                          ),
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  
  String truncateWithEllipsis(String text, {int cutoff = 16}) {
    if (text.length <= cutoff) return text;
    return '${text.substring(0, cutoff)}';
  }
}
