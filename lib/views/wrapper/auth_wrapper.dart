import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mema/core/services/auth_service.dart';
import 'package:mema/views/home/home_page.dart';
import 'package:mema/views/auth/login_page.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // 🌀 page de chargement
        }
        if (snapshot.hasData) {
          return const HomePagePrincipal(); // Utilisateur connecté
        } else {
          return const LoginPage(); // Utilisateur non connecté
        }
      },
    );
  }
}
