import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mema/core/services/audio_service.dart';


class AudioProvider with ChangeNotifier {
  List<FileSystemEntity> _audios = [];

  List<FileSystemEntity> get audios => _audios;

  Future<void> loadAudios(String path) async {
    _audios = await PredicationService.getAudioFiles(path);
    notifyListeners();
  }

  Future<void> deleteAudio(String path) async {
    await PredicationService.deleteAudio(path);
    _audios.removeWhere((f) => f.path == path);
    notifyListeners();
  }
}
