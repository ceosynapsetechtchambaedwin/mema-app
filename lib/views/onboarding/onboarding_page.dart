import 'package:flutter/material.dart';
import 'package:mema/views/widgets/dot_indicator.dart';

import 'onboarding_data.dart';

/// Page d'accueil de l'application avec slides de présentation.
/// Utilise un `PageView` pour défiler entre les différentes pages.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController(); // Contrôle le défilement
  int _currentIndex = 0; // Index actuel du slide

  /// Fonction appelée quand on clique sur le bouton suivant
  void _nextPage() {
    if (_currentIndex < onboardingPages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      // Rediriger vers la page de connexion 
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Nettoyage du contrôleur
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = onboardingPages;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Partie supérieure : les slides
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final item = pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Affichage de l'image distante
                      SizedBox(
                        height: 250,
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Titre du slide
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description du slide
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Indicateurs de position (petits cercles)
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => DotIndicator(isActive: index == _currentIndex),
            ),
          ),

          // Bouton "suivant"
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
