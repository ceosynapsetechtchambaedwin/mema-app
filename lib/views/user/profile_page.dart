import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mema/models/user_model.dart';
import 'package:mema/core/services/user_service.dart';
import 'package:mema/views/home/app_bar.dart';

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
  bool _isExistingUser = false;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _email = firebaseUser.email ?? '';
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userSnapshot.exists) {
        final userData = User.fromFirestore(userSnapshot);
        setState(() {
          _isExistingUser = true;
          _name = userData.name;
          _phone = userData.phone;
          _profileImageUrl = userData.profileImage;
        });
      } else {
        setState(() {
          _profileImageUrl = firebaseUser.photoURL ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_imageFile == null) return _profileImageUrl;
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

  Future<void> _createOrUpdateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String profileImageUrl = await _uploadImageToFirebase();
        final currentUser = _auth.currentUser;
        if (currentUser == null) return;

        User user = User(
          userId: currentUser.uid,
          name: _name,
          email: _email,
          phone: _phone,
          profileImage: profileImageUrl,
          createdAt: DateTime.now(),
          role: "membre",
        );

        await UserService().createOrUpdateUser(user);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Profil enregistré avec succès')),
        );
      } catch (e) {
        print('Erreur création: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Une erreur s\'est produite')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Mon Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                : AssetImage('assets/default_profile.png')) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _email.isNotEmpty ? _email : "Email non défini",
                      style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),

                    _buildModernTextField(
                      label: "Nom",
                      icon: Icons.person,
                      initialValue: _name,
                      onChanged: (val) => setState(() => _name = val),
                      validator: (val) => val == null || val.isEmpty ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildModernTextField(
                      label: "Téléphone",
                      icon: Icons.phone,
                      initialValue: _phone,
                      onChanged: (val) => setState(() => _phone = val),
                      validator: (val) => val == null || val.isEmpty ? 'Téléphone requis' : null,
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton.icon(
                      onPressed: _createOrUpdateUser,
                      icon: Icon(Icons.save),
                      label: Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 12),
                    if (!_isExistingUser)
                      Text(
                        "⚠️ Vos informations ne sont pas encore complètes.",
                        style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
