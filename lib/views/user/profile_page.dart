import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mema/core/services/user_service.dart';
import 'package:mema/models/user_model.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _profileImageUrl = '';
  File? _imageFile;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;


  // Choisir une image à partir de la galerie ou de la caméra
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Sauvegarder l'image dans Firebase Storage et récupérer l'URL
  Future<String> _uploadImageToFirebase() async {
    if (_imageFile == null) {
      return '';
    }

    try {
      // Générer un nom unique pour l'image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _firebaseStorage.ref().child('profile_images/$fileName');

      // Télécharger l'image dans Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      // Obtenir l'URL de l'image après le téléversement
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _createUser() async {
  if (_formKey.currentState?.validate() ?? false) {
    try {
      // Téléverse l'image de profil et récupère l'URL
      String profileImageUrl = await _uploadImageToFirebase();

      // Générer un ID unique pour l'utilisateur
      String userId = FirebaseFirestore.instance.collection('users').doc().id;

      // Créer l'objet utilisateur
      User user = User(
        userId: userId,
        name: _name,
        email: _email,
        phone: _phone,
        profileImage: profileImageUrl,
        createdAt: DateTime.now(),
        role: "user", // 
      );

      // Enregistrement dans Firestore via UserService
      await UserService().createUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Utilisateur créé avec succès')),
      );
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de la création de l\'utilisateur')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Action pour modifier les informations de l'utilisateur
              // Afficher une modal ou une nouvelle page pour l'édition des informations
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Image de profil
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : AssetImage('assets/default_profile.png')) as ImageProvider,
                ),
              ),
              SizedBox(height: 20),

              // Champ pour le nom
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nom est requis';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Champ pour l'email
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Entrez votre email',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email est requis';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(value)) {
                    return 'Entrez un email valide';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Champ pour le téléphone
              TextFormField(
                initialValue: _phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  hintText: 'Entrez votre numéro de téléphone',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Numéro de téléphone est requis';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _phone = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _createUser,
                child: Text('Enregistrer les informations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
