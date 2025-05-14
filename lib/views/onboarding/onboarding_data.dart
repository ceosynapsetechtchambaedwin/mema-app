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
    imageUrl: "https://firebasestorage.googleapis.com/v0/b/mema-app-mobile.firebasestorage.app/o/onBroading%2Fslide1.png?alt=media&token=4761bc1f-3cee-49ce-80cc-bd12cd90d6bf",
  ),
  OnboardingInfo(
    title: "Prédications",
    description: "Écoutez ou téléchargez des prédications inspirantes à tout moment.",
    imageUrl: "https://firebasestorage.googleapis.com/v0/b/mema-app-mobile.firebasestorage.app/o/onBroading%2Fslide2.jpg?alt=media&token=2174765d-ad91-4c10-8522-b47b7699dfbb",
  ),
  OnboardingInfo(
    title: "Partage",
    description: "Partagez la bonne nouvelle avec vos proches facilement.",
    imageUrl: "https://firebasestorage.googleapis.com/v0/b/mema-app-mobile.firebasestorage.app/o/onBroading%2Fslide3.png?alt=media&token=5503bd3c-f812-407b-afc7-23d310dcde4d",
  ),
];
