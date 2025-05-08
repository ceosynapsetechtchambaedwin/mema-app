
// lib/models/predication_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Predication {
  final String titreFr;
  final String titreEn;
  final String descriptionFr;
  final String descriptionEn;
  final String audioUrl;
  final Timestamp createdAt;
  final int downloadCount;
  final int shareCount;
  final String tagFr;
  final String tagEn;
  final Timestamp? scheduledAt;

  Predication({
    required this.titreFr,
    required this.titreEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.audioUrl,
    required this.createdAt,
    this.downloadCount = 0,
    this.shareCount = 0,
    required this.tagFr,
    required this.tagEn,
     this.scheduledAt,
  });

  Map<String, dynamic> toMap() => {
        'titreFr': titreFr,
        'titreEn': titreEn,
        'descriptionFr': descriptionFr,
        'descriptionEn': descriptionEn,
        'audioUrl': audioUrl,
        'createdAt': createdAt,
        'downloadCount': downloadCount,
        'shareCount': shareCount,
        'tagFr': tagFr,
        'tagEn': tagEn,
        'scheduledAt': scheduledAt ,
      };

  factory Predication.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Predication(
      titreFr: data['titreFr']??"test",
      titreEn: data['titreEn']??"test",
      descriptionFr: data['descriptionFr']??"test",
      descriptionEn: data['descriptionEn']??"test",
      audioUrl: data['audioUrl']??"test",
      createdAt: data['createdAt'] ,
      downloadCount: data['downloadCount'] ?? 0,
      shareCount: data['shareCount'] ?? 0,
      tagFr: data['tagFr']??"test",
      tagEn: data['tagEn']??"test",
      scheduledAt: data['scheduledAt'] ,
    );
  }
}


