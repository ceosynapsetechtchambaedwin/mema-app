import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'audio_player_page.dart';

class AudioListPage extends StatefulWidget {
  @override
  _AudioListPageState createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  List<FileSystemEntity> audioFiles = [];
  final String directoryPath = '/storage/emulated/0/Eglise';

  @override
  void initState() {
    super.initState();
    requestPermissionAndLoadFiles();
  }

  Future<void> requestPermissionAndLoadFiles() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      loadAudioFiles();
    } else {
      print("Permission refusée");
    }
  }

  void loadAudioFiles() async {
    final dir = Directory(directoryPath);
    if (await dir.exists()) {
      final files = dir
          .listSync()
          .where((f) => f.path.toLowerCase().endsWith(".mp3"))
          .toList();
      setState(() {
        audioFiles = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: audioFiles.isEmpty
          ? Center(child: Text("Aucun fichier trouvé."))
          : ListView.builder(
              itemCount: audioFiles.length,
              itemBuilder: (context, index) {
                final file = audioFiles[index];
                final fileName = file.path.split("/").last;
                return ListTile(
                  leading: Icon(Icons.audiotrack),
                  title: Text(fileName),
                  trailing: Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerPage(
                          filePath: file.path,
                          title: fileName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
