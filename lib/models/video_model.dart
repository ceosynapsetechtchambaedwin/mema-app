// lib/models/video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String youtubeUrl;

  Video({required this.id, required this.youtubeUrl});

  Map<String, dynamic> toMap() => {
        'id': id,
        'youtube_url': youtubeUrl,
      };

  factory Video.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Video(
      id: data['id'],
      youtubeUrl: data['youtube_url'],
    );
  }
}

