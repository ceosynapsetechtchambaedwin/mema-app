import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? userId;
  String name;
  String email;
  String phone;
  String profileImage;
  DateTime createdAt;
  String role;

  User({
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.createdAt,
    required this.role,
  });

  // Convertir un utilisateur Firestore en objet User
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profile_image'] ?? '',
      createdAt: (data['create_at'] as Timestamp).toDate(),
      role: data['role'] ?? '',
    );
  }

  // Convertir un objet User en données pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'create_at': createdAt,
      'role': role,
    };
  }
}





