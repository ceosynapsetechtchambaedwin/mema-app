import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mema/views/audio/local_audio_player.dart';
import 'package:mema/views/home/app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:mema/view_models/langue_view_model.dart';

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
        SnackBar(content: Text(context.read<LanguageProvider>().isFrench ? "Fichier supprimé avec succès" : "File successfully deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${context.read<LanguageProvider>().isFrench ? "Erreur lors de la suppression" : "Error deleting file"} : $e")),
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
    final isFrench = context.watch<LanguageProvider>().isFrench;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench ? 'Audios Sauvegardés' : 'Saved Audios'),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _audioFiles.isEmpty
          ? Center(
              child: Text(
                isFrench ? "Aucun fichier audio trouvé." : "No audio file found.",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${isFrench ? "Mémoire utilisée" : "Memory used"} : ${_totalSizeMB.toStringAsFixed(2)} MB",
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.05),
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
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${isFrench ? "Durée" : "Duration"} : ${_formatDuration(duration)}",
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(isFrench ? "Confirmer la suppression" : "Confirm deletion"),
                                      content: Text(isFrench ? "Supprimer ce fichier ?" : "Delete this file?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(isFrench ? "Annuler" : "Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteFile(file);
                                          },
                                          child: Text(isFrench ? "Supprimer" : "Delete"),
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
