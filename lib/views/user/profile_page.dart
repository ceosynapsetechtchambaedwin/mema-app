import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _email = user.email ?? '';
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_imageFile == null) return '';

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _firebaseStorage.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erreur d\'upload: $e');
      return '';
    }
  }

  Future<void> _createUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String profileImageUrl = await _uploadImageToFirebase();
        String userId = FirebaseFirestore.instance.collection('users').doc().id;

        User user = User(
          userId: userId,
          name: _name,
          email: _email,
          phone: _phone,
          profileImage: profileImageUrl,
          createdAt: DateTime.now(),
          role: "user",
        );

        await UserService().createUser(user);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Utilisateur enregistré')),
        );
      } catch (e) {
        print('Erreur création user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Une erreur s\'est produite')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image dans conteneur stylé
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : AssetImage('assets/default_profile.png')) as ImageProvider,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _email.isNotEmpty ? 'Connecté : $_email' : 'Email non disponible',
                style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                label: "Nom",
                hint: "Entrez votre nom",
                icon: Icons.person,
                initialValue: _name,
                validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
                onChanged: (val) => setState(() => _name = val),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Téléphone",
                hint: "Entrez votre numéro",
                icon: Icons.phone,
                initialValue: _phone,
                validator: (val) => val == null || val.isEmpty ? 'Téléphone requis' : null,
                onChanged: (val) => setState(() => _phone = val),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Enregistrer', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue.shade600,
                ),
                onPressed: _createUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String initialValue,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
