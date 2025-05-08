// lib/models/video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String youtubeUrl;
  final String descriptionFr;
  final String descriptionEn;
  final Timestamp createdAt;
  final int shareCount;
  final String? titre;

  Video({ required this.youtubeUrl, required this.descriptionFr, required this.descriptionEn, required this.createdAt, this.shareCount = 0,this.titre});

  Map<String, dynamic> toMap() => {
        'youtubeUrl': youtubeUrl,
        'descriptionFr': descriptionFr,
        'descriptionEn': descriptionEn,
        'createdAt': createdAt,
        'shareCount': shareCount,
        'titre': titre,
      };

  factory Video.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Video(
      youtubeUrl: data['youtubeUrl'],
      descriptionFr: data['descriptionFr'],
      descriptionEn: data['descriptionEn'],
      createdAt: data['createdAt'] ,
      shareCount: data['shareCount'] ?? 0,
      titre: data['titre'],
    );  
  }
}

