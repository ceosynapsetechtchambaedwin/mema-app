import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mema/models/predication_model.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AudioPlayerPage extends StatefulWidget {
  final Predication predication;

  const AudioPlayerPage({required this.predication, Key? key})
    : super(key: key);

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.predication.audioUrl);
      _player.play();

      _player.durationStream.listen((d) {
        setState(() => _duration = d ?? Duration.zero);
      });

      _player.positionStream.listen((p) {
        setState(() => _position = p);
      });

      _player.playerStateStream.listen((state) {
        setState(() => _isPlaying = state.playing);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du chargement de l'audio.")),
      );
    }
  }

  Future<void> _downloadAudio(String url, String fileName) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() => _isDownloading = true);
      final savePath = '/storage/emulated/0/Download/$fileName.mp3';
      try {
        await Dio().download(url, savePath);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Téléchargement terminé")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du téléchargement")),
        );
      } finally {
        setState(() => _isDownloading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission de stockage refusée")),
      );
    }
  }

  void _togglePlay() => _isPlaying ? _player.pause() : _player.play();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.predication;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Ecoute de la parole'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.church, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.blue.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SpinKitThreeBounce(color: Colors.blueAccent, size: 30),
                      const SizedBox(height: 20),
                      Text(
                        p.titreFr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.descriptionFr,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value:
                              _duration.inSeconds > 0
                                  ? _position.inSeconds / _duration.inSeconds
                                  : 0,
                          minHeight: 8,
                          backgroundColor: Colors.blue.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            "-${_formatDuration(_duration - _position)}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, size: 30),
                            onPressed:
                                () => _player.seek(
                                  _position - const Duration(seconds: 10),
                                ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.6),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 36,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlay,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.forward_10, size: 30),
                            onPressed:
                                () => _player.seek(
                                  _position + const Duration(seconds: 10),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:
                            _isDownloading
                                ? null
                                : () => _downloadAudio(p.audioUrl, p.titreFr),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: StadiumBorder(),
                          elevation: 6,
                          shadowColor: Colors.black54,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.lightBlueAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            alignment: Alignment.center,
                            child:
                                _isDownloading
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.download,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Télécharger",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
