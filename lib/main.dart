import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marquee/marquee.dart';
import 'package:mema/views/audio/audio_page_list.dart';


import 'package:mema/views/video/TemoignagePage.dart';
import 'package:mema/core/services/auth_service.dart';
import 'package:mema/themes/app_theme.dart';
import 'package:mema/view_models/audio_provider.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/view_models/theme_provider.dart' show ThemeProvider;
import 'package:mema/views/audio/audio_list_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => AuthService(),),
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
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      
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
        '/podcastList': (_) => const AudioListScreen(),
        '/newsList': (_) => const SignupPage(),
        '/testimonyList': (_) => const SignupPage(),
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
    AudioListScreen(),
    TemoignagesListPage(),
     AudioListPage(),
    const SettingsPage(),
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
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true,
appBar: AppBar(
  elevation: 4,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black87,
  automaticallyImplyLeading: false,

  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Logo à gauche
      Image.asset(
        'assets/logo.png', // Remplace par le chemin réel de ton logo
        height: 36,
      ),

      const SizedBox(width: 10),

      // Titre mis en valeur à droite
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              _labels[_pageIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0.5, 0.5),
                    blurRadius: 1.0,
                    color: Colors.black, // Bordure noire très fine
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
  ),
),


    body: Stack(
      children: [
        SafeArea(child: _pages[_pageIndex]),
        if (_showDonationPanel) _buildActionPanel(),
      ],
    ),
    // floatingActionButton: Padding(
    //   padding: const EdgeInsets.only(right: 10, bottom: 10),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       shape: BoxShape.circle,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.orange.withOpacity(0.6),
    //           blurRadius: 12,
    //           spreadRadius: 2,
    //         ),
    //       ],
    //     ),
    //     child: FloatingActionButton(
    //       onPressed: _toggleDonationPanel,
    //       backgroundColor: const Color.fromARGB(255, 68, 138, 255),
    //       elevation: 10,
    //       child: const Icon(Icons.forum, size: 28, color: Colors.white),
    //     ),
    //   ),
    // ),
    bottomNavigationBar: CurvedNavigationBar(
      index: _pageIndex,
      height: 65,
      backgroundColor: Colors.transparent,
      color: Colors.white,
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
  );
}

}
