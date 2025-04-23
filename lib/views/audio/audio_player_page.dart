import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPage extends StatefulWidget {
  final String filePath;
  final String title;

  AudioPlayerPage({required this.filePath, required this.title});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setSourceDeviceFile(widget.filePath);
  }

  void togglePlay() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 80,
            color: Colors.blue,
          ),
          onPressed: togglePlay,
        ),
      ),
    );
  }
}
