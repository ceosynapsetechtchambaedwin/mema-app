import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mema/core/services/audio_service.dart';
import 'package:mema/core/services/stream_service.dart';
import 'package:mema/core/utils/share.dart';
import 'package:mema/models/actualite_model.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/models/video_model.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/audio/audio_player_page2.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:mema/views/video/video_player_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomePagePrincipal extends StatefulWidget {
  const HomePagePrincipal({super.key});

  @override
  State<HomePagePrincipal> createState() => _HomePagePrincipalState();
}

class _HomePagePrincipalState extends State<HomePagePrincipal> {
  final TextEditingController _searchController = TextEditingController();
  
  final Color primaryBlue = const Color.fromARGB(255, 68, 138, 255);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;
    final List<String> _tags = ["Foi", "Jeunesse", "Guérison", "Prière"];
    

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench?'Accueil':'Home'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            
            _buildSearchBarWithTags(isFrench),
            const SizedBox(height: 24),
            _buildSectionHeader(
              isFrench,
              isFrench ? "Actualités" : "News",
              onPressed: () => Navigator.pushNamed(context, "/newsList"),
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
              onPressed: () => Navigator.pushNamed(context, "/podcastList"),
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
                            (podcast) => InkWell(
                              child: _buildPodcastItem(isFrench, podcast),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AudioPlayerPage(
                                          predication: podcast,
                                        ),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              isFrench,
              isFrench ? "Témoignages" : "Testimonies",
              onPressed: () => Navigator.pushNamed(context, "/testimonyList"),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Video>>(
              stream: StreamService().getVideosStreamLimit(3),
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
                            (video) => InkWell(
                              child: _buildVideoCard(
                                isFrench,

                                truncateWithEllipsis2(video.descriptionEn),
                                truncateWithEllipsis2(video.descriptionFr),
                                 "📅 ${"Date:${truncateWithEllipsis("${video.createdAt.toDate()}")}"}",
                                 video.youtubeUrl,  
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => VideoPlayerPage(
                                          videoUrl: video.youtubeUrl,
                                          descriptionEn: video.descriptionEn,
                                          descriptionFr: video.descriptionFr,
                                        ),
                                  ),
                                );
                              },
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

  /// 🔍 BARRE DE RECHERCHE + TAGS
  Widget _buildSearchBarWithTags(bool isFr) {
    var _tags=isFr? ["Foi", "Jeunesse", "Guérison", "Prière"]:
    ["Faith", "Youth", "Healing", "Prayer"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintText: isFr?"Rechercher..." : "Search...",
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                _tags.map((tag) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90CAF9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = tag;
                        setState(() {});
                      },
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// 🔖 EN-TÊTE DE SECTION
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

  /// 📰 CARTE D’ACTUALITÉ
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
              child: CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 140,
                        width: 280,
                        color: Colors.white,
                      ),
                    ),
                errorWidget:
                    (context, url, error) =>
                        Image.asset('assets/background.jpg', fit: BoxFit.cover),
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
              style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 ${"Date:${truncateWithEllipsis("${news.scheduledAt?.toDate()}")}"}",
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

  /// 🎧 ITEM PODCAST
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
        subtitle: Text(
          "📅 ${"Date:${truncateWithEllipsis("${podcast.createdAt.toDate()}")}"}",
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'partager') {
              if (podcast.audioUrl != null) {
                PredicationService().incrementShareCount(podcast.audioUrl!);
              }
              shareContent(
                "${isFrench ? podcast.titreFr : podcast.titreEn}\nAudio: ${podcast.audioUrl}",
              );
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'partager', child: Text("Partager")),
              ],
        ),
      ),
    );
  }

Widget _buildVideoCard(
  bool isFrench,
  String descriptionEn,
  String descriptionFr,
  String date,
  String youtubeUrl,
) {
  String getYouTubeThumbnail(String url) {
    final Uri uri = Uri.parse(url);
    String? videoId;

    if (uri.host.contains("youtu.be")) {
      videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    } else {
      videoId = uri.queryParameters["v"];
    }

    if (videoId == null) return "";

    return "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
  }

  return Container(
    margin: const EdgeInsets.only(right: 12),
    width: 250,
    child: Column(
      mainAxisSize: MainAxisSize.min, // 🔑 important pour ne pas forcer la hauteur
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9, // 🖼️ maintient un bon ratio pour la miniature
            child: CachedNetworkImage(
              imageUrl: getYouTubeThumbnail(youtubeUrl),
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, size: 40, color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isFrench ? descriptionFr : descriptionEn,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}



  /// HORIZONTAL SCROLL
Widget _buildHorizontalList({required List<Widget> items}) {
  return SizedBox(
    height: 200,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 200, // ✅ contraint chaque item à respecter la hauteur
                child: item,
              ),
            ),
          )
          .toList(),
    ),
  );
}


  String truncateWithEllipsis(String text, {int cutoff = 16}) {
    if (text.length <= cutoff) return text;
    return '${text.substring(0, cutoff)}';
  }

    String truncateWithEllipsis2(String text, {int cutoff = 30}) {
    if (text.length <= cutoff) return text;
    return '${text.substring(0, cutoff)}...';
  }
}

AppBar _buildModernAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,

    elevation: 0.8,
    centerTitle: true,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.png', // 🔁 Ton logo local
          height: 28,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
  );
}
            
