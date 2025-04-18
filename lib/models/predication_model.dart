
// lib/models/predication_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Predication {
  final String? id;
  final String titreFr;
  final String titreEn;
  final String descriptionFr;
  final String descriptionEn;
  final String audioUrl;
  final DateTime createdAt;
  final int downloadCount;
  final int shareCount;
  final String tagFr;
  final String tagEn;
  final DateTime? scheduledAt;

  Predication({
     this.id,
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
  
        'titre_fr': titreFr,
        'titre_en': titreEn,
        'description_fr': descriptionFr,
        'description_en': descriptionEn,
        'audio_url': audioUrl,
        'created_at': Timestamp.fromDate(createdAt),
        'download_count': downloadCount,
        'share_count': shareCount,
        'tag_fr': tagFr,
        'tag_en': tagEn,
        'scheduled_at': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      };

  factory Predication.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Predication(
      id: data['id'],
      titreFr: data['titre_fr'],
      titreEn: data['titre_en'],
      descriptionFr: data['description_fr'],
      descriptionEn: data['description_en'],
      audioUrl: data['audio_url'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      downloadCount: data['download_count'] ?? 0,
      shareCount: data['share_count'] ?? 0,
      tagFr: data['tag_fr'],
      tagEn: data['tag_en'],
      scheduledAt: data['scheduled_at'] != null ? (data['scheduled_at'] as Timestamp).toDate() : null,
    );
  }
}


