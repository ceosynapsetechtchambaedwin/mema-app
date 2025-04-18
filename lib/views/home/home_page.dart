import 'package:flutter/material.dart';
import 'package:mema/core/services/audio_service.dart';
import 'package:mema/core/services/stream_service.dart';
import 'package:mema/core/utils/share.dart';
import 'package:mema/models/actualite_model.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/models/video_model.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:provider/provider.dart';

class HomePagePrincipal extends StatefulWidget {
  const HomePagePrincipal({super.key});

  @override
  State<HomePagePrincipal> createState() => _HomePagePrincipalState();
}

class _HomePagePrincipalState extends State<HomePagePrincipal> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tags = ["Foi", "Jeunesse", "Guérison", "Prière"];
  final Color primaryBlue = const Color.fromARGB(255, 68, 138, 255);

  // Initialisation de la variable de langue (par exemple, via SharedPreferences)
  // Ou vous pouvez récupérer cette valeur dans un fichier de configuration ou SharedPreferences.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SizedBox(height: 16),
            _buildSearchBarWithTags(_searchController.text),
            const SizedBox(height: 24),
            _buildSectionHeader(
              isFrench,
              isFrench ? "Actualités" : "News",
              onPressed: () {
                Navigator.pushNamed(context, "/newsList");
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<News>>(
              stream: StreamService().getNewsStreamLimit(3),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      isFrench
                          ? "Aucune donnée disponible"
                          : "No data available",
                    ),
                  );
                }
                return Column(
                  children:
                      snapshot.data!
                          .map((news) => _buildNewsCard(isFrench, news))
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              isFrench,
              isFrench ? "Podcasts" : "Podcasts",
              onPressed: () {
                Navigator.pushNamed(context, "/podcastList");
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Predication>>(
              stream: StreamService().getPredicationsStreamLimit(2),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      isFrench
                          ? "Aucune donnée disponible"
                          : "No data available",
                    ),
                  );
                }
                return Column(
                  children:
                      snapshot.data!
                          .map(
                            (podcast) => _buildPodcastItem(isFrench, podcast),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              isFrench,
              isFrench ? "Témoignages" : "Testimonies",
              onPressed: () {
                Navigator.pushNamed(context, "/testimonyList");
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Video>>(
              stream: StreamService().getVideosStreamLimit(4),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      isFrench
                          ? "Aucune donnée disponible"
                          : "No data available",
                    ),
                  );
                }
                return _buildHorizontalList(
                  items:
                      snapshot.data!
                          .map(
                            (video) => _buildVideoCard(
                              isFrench,
                              "testimony.title",
                              "testimony.date",
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarWithTags(String tag) {
    return Text("à faire");
    // identique
  }

  Widget _buildSectionHeader(
    bool isFrench,
    String title, {
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: primaryBlue),
          child: Text(isFrench ? "Voir plus" : "See more"),
        ),
      ],
    );
  }

  Widget _buildNewsCard(bool isFrench, News news) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                news.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isFrench ? news.titreFr : news.titreEn,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isFrench ? news.descriptionFr : news.descriptionEn,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 ${news.createdAt}",
                  style: const TextStyle(fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed:
                      () => shareContent(
                        "${isFrench ? news.titreFr : news.titreEn}\nTéléchargez ici: ---",
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastItem(bool isFrench, Predication podcast) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryBlue.withOpacity(0.9),
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.headphones, color: Colors.white),
        ),
        title: Text(
          isFrench ? podcast.titreFr : podcast.titreEn,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(podcast.createdAt as String),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'partager') {
              if (podcast.id != null) {
                PredicationService().incrementShareCount(podcast.id!);
              } else {
                // Handle the case where podcast.id is null, if necessary
                debugPrint("Podcast ID is null");
              }
              shareContent(
                "${isFrench ? podcast.titreFr : podcast.titreEn}\nTéléchargez l'aplication ici: ---",
              );
            } else if (value == 'telecharger') {
              PredicationService().incrementDownloadCount(podcast.id!);
              // implémenter téléchargement ici
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'partager',
                  child: Text(isFrench ? "Partager" : "Share"),
                ),
                PopupMenuItem(
                  value: 'telecharger',
                  child: Text(isFrench ? "Télécharger" : "Download"),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(bool isFrench, String title, String date) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.ondemand_video, size: 40, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(
              isFrench ? title : title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("📅 $date", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList({required List<Widget> items}) {
    return SizedBox(
      height: 180,
      child: ListView(scrollDirection: Axis.horizontal, children: items),
    );
  }
}
