import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mema/view_models/audio_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/audio_card.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  final String audioDirectory = '/storage/emulated/0/Download/Audios';

  @override
  void initState() {
    super.initState();
    Provider.of<AudioProvider>(context, listen: false).loadAudios(audioDirectory);
  }

  @override
  Widget build(BuildContext context) {
    final audios = Provider.of<AudioProvider>(context).audios;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Audios')),
      body: audios.isEmpty
          ? const Center(child: Text("Aucun audio trouvé"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: audios.length,
              itemBuilder: (ctx, i) {
                return AudioCard(audioFile: audios[i]);
              },
            ),
    );
  }
}
