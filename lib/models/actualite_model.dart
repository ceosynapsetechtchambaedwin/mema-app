import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;
class News {
  final String id;
  final String titreFr;
  final String titreEn;
  final String descriptionFr;
  final String descriptionEn;
  final DateTime createdAt;
  final String imageUrl;
  final DateTime? scheduledAt;

  News({
    required this.id,
    required this.titreFr,
    required this.titreEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.createdAt,
    required this.imageUrl,
    this.scheduledAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titre_fr': titreFr,
        'titre_en': titreEn,
        'description_fr': descriptionFr,
        'description_en': descriptionEn,
        'created_at': Timestamp.fromDate(createdAt),
        'image_url': imageUrl,
        'scheduled_at': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      };

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return News(
      id: data['id'],
      titreFr: data['titre_fr'],
      titreEn: data['titre_en'],
      descriptionFr: data['description_fr'],
      descriptionEn: data['description_en'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      imageUrl: data['image_url'],
      scheduledAt: data['scheduled_at'] != null ? (data['scheduled_at'] as Timestamp).toDate() : null,
    );
  }
}

