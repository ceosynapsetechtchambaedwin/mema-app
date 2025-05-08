import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;
class News {
  final String titreFr;
  final String titreEn;
  final String descriptionFr;
  final String descriptionEn;
  final Timestamp createdAt;
  final String imageUrl;
  final Timestamp? scheduledAt;

  News({
    required this.titreFr,
    required this.titreEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.createdAt,
    required this.imageUrl,
    this.scheduledAt,
  });

  Map<String, dynamic> toMap() => {
        'titreFr': titreFr,
        'titreEn': titreEn,
        'descriptionFr': descriptionFr,
        'descriptionEn': descriptionEn,
        'createdAt': createdAt,
        'imageUrl': imageUrl,
        'scheduledAt': scheduledAt ,
      };

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return News(
      titreFr: data['titreFr']??'',
      titreEn: data['titreEn']??'',
      descriptionFr: data['descriptionFr']??'',
      descriptionEn: data['descriptionEn']??'',
      createdAt: data['createdAt'] ,
      imageUrl: data['imageUrl']??'',
      scheduledAt: data['scheduledAt'] ,
    );
  }
}

