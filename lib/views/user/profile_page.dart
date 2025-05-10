import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mema/models/user_model.dart';
import 'package:mema/core/services/user_service.dart';

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
  bool _isLoading = false;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  late bool isFrench;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Détection de la langue de l'appareil
    isFrench = Localizations.localeOf(context).languageCode == 'fr';
  }

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
      Reference storageRef =
          _firebaseStorage.ref().child('profile_images/$fileName');
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
        setState(() => _isLoading = true);

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
          SnackBar(
            content: Text(isFrench
                ? '✅ Profil enregistré avec succès'
                : '✅ Profile saved successfully'),
          ),
        );
      } catch (e) {
        print('Erreur création: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFrench
                ? '❌ Une erreur s\'est produite'
                : '❌ An error occurred'),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          isFrench ? "Mon Profil" : "My Profile",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : const AssetImage('assets/default_profile.png'))
                      as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _email.isNotEmpty ? _email : (isFrench ? "Email non défini" : "Email not set"),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildModernTextField(
                          label: isFrench ? "Nom" : "Name",
                          icon: Icons.person,
                          initialValue: _name,
                          onChanged: (val) => setState(() => _name = val),
                          validator: (val) =>
                              val == null || val.isEmpty ? (isFrench ? 'Nom requis' : 'Name required') : null,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          label: isFrench ? "Téléphone" : "Phone",
                          icon: Icons.phone,
                          initialValue: _phone,
                          onChanged: (val) => setState(() => _phone = val),
                          validator: (val) => val == null || val.isEmpty
                              ? (isFrench ? 'Téléphone requis' : 'Phone required')
                              : null,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                onPressed: _createOrUpdateUser,
                                icon: const Icon(Icons.save),
                                label: Text(isFrench ? "Enregistrer" : "Save"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                        const SizedBox(height: 20),
                        if (!_isExistingUser)
                          Text(
                            isFrench
                                ? "⚠️ Vos informations ne sont pas encore complètes."
                                : "⚠️ Your information is not yet complete.",
                            style: TextStyle(
                              color: Colors.redAccent.shade200,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
