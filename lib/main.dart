import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';


import 'package:mema/views/actualites/news_list_page.dart';
import 'package:mema/views/audio/audio_player_list_local.dart';
import 'package:mema/views/audio/prediation_list_page.dart';

import 'package:mema/views/video/TemoignagePage.dart';
import 'package:mema/core/services/auth_service.dart';
import 'package:mema/themes/app_theme.dart';
import 'package:mema/view_models/audio_provider.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/view_models/theme_provider.dart' show ThemeProvider;

import 'package:mema/views/auth/login_page.dart';
import 'package:mema/views/auth/signup_page.dart';
import 'package:mema/views/home/home_page.dart' show HomePagePrincipal;
import 'package:mema/views/onboarding/onboarding_page.dart';
import 'package:mema/views/settings/setting_page.dart';
import 'package:provider/provider.dart';

import 'view_models/setting_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mema',
     themeMode: themeProvider.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,

      // Utilisation d'un StreamBuilder pour écouter l'état de connexion de l'utilisateur
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          return StreamBuilder<User?>(
            stream: authService.authStateChanges,
            builder: (context, snapshot) {
              // Si l'état de l'utilisateur est encore en cours de chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Si l'utilisateur est connecté, on affiche la HomePage
              if (snapshot.hasData) {
                return const HomePage();
              }

              // Si l'utilisateur n'est pas connecté, on affiche la page d'onboarding?/newsList?/podcastList?/testimonyList
              return const OnboardingPage();
            },
          );
        },
      ),
      routes: {
        '/home': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/podcastList': (_) => PredicationListPage(),
        '/newsList': (_) => NewsListPage(),
        '/testimonyList': (_) => TemoignagesListPage(),
        '/downloadlist': (_) => LocalAudioListPage(),
        '/setting': (_) => SettingsPage(),
      },
    );
  }
}

class TelechargementView extends StatelessWidget {
  const TelechargementView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Téléchargements", style: TextStyle(fontSize: 24)),
    );
  }
}

// ------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _pageIndex = 0;
  bool _showDonationPanel = false;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePagePrincipal(),
    PredicationListPage(),
    TemoignagesListPage(),
    LocalAudioListPage(),
    SettingsPage(),
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.library_music,
    Icons.video_library,
    Icons.download, // icône pour Téléchargement
    Icons.settings,
  ];

  final List<String> _labels = [
    "Accueil",
    "Podcasts",
    "Témoignages",
    "Téléchargement",
    "Paramètres",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDonationPanel() {
    setState(() => _showDonationPanel = !_showDonationPanel);
    _showDonationPanel
        ? _animationController.forward()
        : _animationController.reverse();
  }

  void _handleAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Action : $action")));
  }

  Widget _buildActionPanel() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FadeTransition(
        opacity: _animationController,
        child: ScaleTransition(
          scale: _animationController,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPanelButton("Discuter maintenant", Icons.message),
                const SizedBox(height: 10),
                _buildPanelButton("Partager", Icons.share),
                const SizedBox(height: 10),
                _buildPanelButton("Assistance", Icons.support_agent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelButton(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        _handleAction(text);
        _toggleDonationPanel();
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  return Container(
    color: const Color(0xFFF0F0F0), // ✅ Couleur d’arrière-plan un peu grise
    child: Scaffold(
      backgroundColor: Colors.transparent, // ⬅️ Important pour voir le fond
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(child: _pages[_pageIndex]),
          if (_showDonationPanel) _buildActionPanel(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 65,
        backgroundColor: Colors.transparent, // ✅ Rend le footer "flottant"
        color: Colors.white, // ✅ Couleur du footer lui-même
        buttonBackgroundColor: const Color.fromARGB(255, 68, 138, 255),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        items: List.generate(_icons.length, (index) {
          return Icon(
            _icons[index],
            color: _pageIndex == index ? Colors.white : Colors.grey,
          );
        }),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    ),
  );
}

}
