import 'package:flutter/material.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String descriptionFr;
  final String descriptionEn;

  const VideoPlayerPage({super.key, required this.videoUrl,required this.descriptionEn,required this.descriptionFr});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;
    return Scaffold(
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench?'Lecture':'Play'), // Use the appropriate title based on the language
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Column(
            children: [
              player,
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  isFrench?widget.descriptionFr:widget.descriptionEn,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
