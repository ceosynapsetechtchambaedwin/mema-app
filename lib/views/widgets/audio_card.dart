import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mema/view_models/audio_provider.dart';
import 'package:mema/views/audio/audio_detail_screen.dart';
import 'package:provider/provider.dart';


class AudioCard extends StatelessWidget {
  final FileSystemEntity audioFile;

  const AudioCard({super.key, required this.audioFile});

  @override
  Widget build(BuildContext context) {
    final fileName = audioFile.path.split('/').last;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Colors.indigo),
        title: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            Provider.of<AudioProvider>(context, listen: false).deleteAudio(audioFile.path);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AudioDetailScreen(audioPath: audioFile.path)),
          );
        },
      ),
    );
  }
}
