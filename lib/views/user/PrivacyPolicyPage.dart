import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mema/view_models/langue_view_model.dart';
import 'package:mema/views/home/app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isFrench = Provider.of<LanguageProvider>(context).isFrench;

    final lastUpdate = isFrench ? "Dernière mise à jour : 18 Avril 2025" : "Last updated: April 18, 2025";

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: ModernAppBar(context, title: isFrench ? 'Politique' : 'Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('🔒 ${isFrench ? "Introduction" : "Introduction"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Votre vie privée est importante pour nous. Cette politique explique comment nous collectons, utilisons et protégeons vos données.'
                  : 'Your privacy is important to us. This policy explains how we collect, use, and protect your data.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📊 ${isFrench ? "Données collectées" : "Collected Data"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Nous recueillons des informations telles que votre numéro de téléphone, vos préférences linguistiques, et votre historique d\'utilisation de l\'application.'
                  : 'We collect information such as your phone number, language preferences, and your app usage history.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🎯 ${isFrench ? "Utilisation des données" : "Use of Data"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Les données sont utilisées pour améliorer votre expérience, personnaliser l\'interface et assurer un meilleur suivi des transactions.'
                  : 'The data is used to enhance your experience, personalize the interface, and ensure better tracking of interactions.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🔐 ${isFrench ? "Sécurité" : "Security"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Nous mettons en place des mesures techniques et organisationnelles pour protéger vos données contre tout accès non autorisé.'
                  : 'We implement technical and organizational measures to protect your data from unauthorized access.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📤 ${isFrench ? "Partage des données" : "Data Sharing"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Vos informations ne seront jamais vendues. Elles peuvent être partagées uniquement avec des partenaires de confiance, dans le respect de la loi.'
                  : 'Your information will never be sold. It may be shared only with trusted partners, in accordance with the law.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📅 ${isFrench ? "Mises à jour" : "Updates"}', textColor),
            _sectionCard(
              textColor,
              isFrench
                  ? 'Cette politique peut être mise à jour. Nous vous informerons via l\'application en cas de changements majeurs.'
                  : 'This policy may be updated. We will notify you through the app in case of major changes.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                lastUpdate,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _sectionCard(Color color, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(fontSize: 16, color: color),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
