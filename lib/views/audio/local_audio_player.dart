import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class LocalAudioPlayerPage extends StatefulWidget {
  final File audioFile;

  const LocalAudioPlayerPage({required this.audioFile, Key? key}) : super(key: key);

  @override
  State<LocalAudioPlayerPage> createState() => _LocalAudioPlayerPageState();
}

class _LocalAudioPlayerPageState extends State<LocalAudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setSourceDeviceFile(widget.audioFile.path);
      await _player.resume();

      _player.onDurationChanged.listen((d) {
        setState(() => _duration = d);
      });

      _player.onPositionChanged.listen((p) {
        setState(() => _position = p);
      });

      _player.onPlayerStateChanged.listen((state) {
        setState(() => _isPlaying = state == PlayerState.playing);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du chargement de l'audio local.")),
      );
    }
  }

  void _togglePlay() => _isPlaying ? _player.pause() : _player.resume();

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
    final filename = widget.audioFile.path.split("/").last;
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench ? 'Ecoute de la parole' : "Listening to speech"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.library_music, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.blue.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SpinKitThreeBounce(color: Colors.blueAccent, size: 30),
                    const SizedBox(height: 20),
                    Text(
                      filename,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isFrench ? "Fichier local" : "Local file",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _duration.inSeconds > 0
                            ? _position.inSeconds / _duration.inSeconds
                            : 0,
                        minHeight: 8,
                        backgroundColor: Colors.blue.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
                          onPressed: () {
                            final newPos = _position - const Duration(seconds: 10);
                            _player.seek(newPos > Duration.zero ? newPos : Duration.zero);
                          },
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
                          onPressed: () {
                            final newPos = _position + const Duration(seconds: 10);
                            if (newPos < _duration) {
                              _player.seek(newPos);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
