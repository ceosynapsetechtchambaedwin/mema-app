import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioDetailScreen extends StatefulWidget {
  final String audioPath;

  const AudioDetailScreen({super.key, required this.audioPath});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioPath));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void stop() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.audioPath.split('/').last;

    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_video, size: 100, color: Colors.indigo),
                const SizedBox(height: 20),
                Text(fileName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: togglePlay, icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow), iconSize: 40),
                    IconButton(onPressed: stop, icon: const Icon(Icons.stop), iconSize: 40),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
