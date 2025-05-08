import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mema/views/audio/local_audio_player.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class LocalAudioListPage extends StatefulWidget {
  const LocalAudioListPage({Key? key}) : super(key: key);

  @override
  State<LocalAudioListPage> createState() => _LocalAudioListPageState();
}

class _LocalAudioListPageState extends State<LocalAudioListPage> {
  List<FileSystemEntity> _audioFiles = [];
  double _totalSizeMB = 0.0;
  Map<String, Duration> _durations = {};

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  Future<void> _loadAudioFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync();
    final audioFiles = files.where((file) => file.path.endsWith(".mp3")).toList();

    double totalBytes = 0;
    Map<String, Duration> tempDurations = {};

    for (var file in audioFiles) {
      final stat = await File(file.path).stat();
      totalBytes += stat.size;

      try {
        final player = AudioPlayer();
        await player.setFilePath(file.path);
        tempDurations[file.path] = player.duration ?? Duration.zero;
        await player.dispose();
      } catch (_) {
        tempDurations[file.path] = Duration.zero;
      }
    }

    setState(() {
      _audioFiles = audioFiles;
      _totalSizeMB = totalBytes / (1024 * 1024);
      _durations = tempDurations;
    });
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      await File(file.path).delete();
      await _loadAudioFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fichier supprimé avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  String _getFileName(String path) {
    return path.split('/').last.replaceAll(".mp3", "");
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _openAudioPlayer(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalAudioPlayerPage(audioFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Audios Sauvegardés'),
      ),
      body: _audioFiles.isEmpty
          ? const Center(child: Text("Aucun fichier audio trouvé."))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Mémoire utilisée : ${_totalSizeMB.toStringAsFixed(2)} MB",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _audioFiles.length,
                    itemBuilder: (context, index) {
                      final file = _audioFiles[index];
                      final duration = _durations[file.path] ?? Duration.zero;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: InkWell(
                          onTap: () => _openAudioPlayer(File(file.path)),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.music_note, size: 30, color: Colors.blueAccent),
                              ),
                              title: Text(
                                _getFileName(file.path),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text("Durée : ${_formatDuration(duration)}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirmer la suppression"),
                                      content: const Text("Supprimer ce fichier ?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Annuler"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteFile(file);
                                          },
                                          child: const Text("Supprimer"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
