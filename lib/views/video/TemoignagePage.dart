import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mema/views/video/TemoignageDetail.dart';
import 'package:mema/views/video/video_player_page.dart'; // <-- Import du lecteur interne
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Pour extraire l’ID et gérer les thumbnails

class TemoignagesListPage extends StatelessWidget {
  final List<Map<String, dynamic>> temoignages = [
    {
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "title": "Dieu m'a sauvé",
      "date": DateTime(2025, 4, 12),
    },
    {
      "url": "https://www.youtube.com/watch?v=ysz5S6PUM-U",
      "title": "Guérison miraculeuse",
      "date": DateTime(2025, 4, 10),
    },
    {
      "url": "https://www.youtube.com/watch?v=jNQXAC9IVRw",
      "title": "Un appel divin",
      "date": DateTime(2025, 4, 8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
   
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: temoignages.length,
        itemBuilder: (context, index) {
          final temoignage = temoignages[index];
          return _buildTemoignageCard(context, temoignage);
        },
      ),
    );
  }

  Widget _buildTemoignageCard(BuildContext context, Map<String, dynamic> temoignage) {
    final title = temoignage["title"];
    final url = temoignage["url"];
    final date = temoignage["date"];
    final videoId = YoutubePlayer.convertUrlToId(url);

    return Container(
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
          // Bloc vidéo cliquable avec miniature
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(videoUrl: url),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: videoId != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          'https://img.youtube.com/vi/$videoId/0.jpg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Icon(
                          Icons.play_circle_fill,
                          size: 60,
                          color: Colors.white70,
                        ),
                      ],
                    )
                  : Container(
                      height: 120,
                      color: const Color(0xFFE0F7FA),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, size: 42, color: Color(0xFF00BCD4)),
                      ),
                    ),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // Footer : date + actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 20, color: Colors.grey),
                      tooltip: "Partager",
                      onPressed: () {
                        Share.share("Regarde ce témoignage: $title\n$url");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                      tooltip: "Détails",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemoignageDetailPage(
                              title: title,
                              description:
                                  "Ce témoignage raconte une expérience de foi, de guérison spirituelle et de transformation personnelle.",
                              date: date,
                              url: url,
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
}
