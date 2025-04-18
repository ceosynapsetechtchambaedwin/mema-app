/// Classe représentant chaque slide d'intro
class OnboardingInfo {
  final String title;
  final String description;
  final String imageUrl; // ✅ Nouveau champ : lien vers image distante

  OnboardingInfo({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

/// Liste de slides avec images distantes
final List<OnboardingInfo> onboardingPages = [
  OnboardingInfo(
    title: "Bienvenue",
    description: "Découvrez une app pour grandir dans la prière et la méditation quotidienne.",
    imageUrl: "https://example.com/images/onboarding1.png",
  ),
  OnboardingInfo(
    title: "Prédications",
    description: "Écoutez ou téléchargez des prédications inspirantes à tout moment.",
    imageUrl: "https://example.com/images/onboarding2.png",
  ),
  OnboardingInfo(
    title: "Partage",
    description: "Partagez la bonne nouvelle avec vos proches facilement.",
    imageUrl: "https://example.com/images/onboarding3.png",
  ),
];
