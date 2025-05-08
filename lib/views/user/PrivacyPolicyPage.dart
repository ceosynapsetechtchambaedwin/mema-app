import 'package:flutter/material.dart';
import 'package:mema/views/home/app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ModernAppBar(context, title: 'Politique'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('🔒 Introduction', textColor),
            _sectionCard(
              textColor,
              'Votre vie privée est importante pour nous. Cette politique explique comment nous collectons, utilisons et protégeons vos données.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📊 Données collectées', textColor),
            _sectionCard(
              textColor,
              'Nous recueillons des informations telles que votre numéro de téléphone, vos préférences linguistiques, et votre historique d\'utilisation de l\'application.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🎯 Utilisation des données', textColor),
            _sectionCard(
              textColor,
              'Les données sont utilisées pour améliorer votre expérience, personnaliser l\'interface et assurer un meilleur suivi des transactions.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('🔐 Sécurité', textColor),
            _sectionCard(
              textColor,
              'Nous mettons en place des mesures techniques et organisationnelles pour protéger vos données contre tout accès non autorisé.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📤 Partage des données', textColor),
            _sectionCard(
              textColor,
              'Vos informations ne seront jamais vendues. Elles peuvent être partagées uniquement avec des partenaires de confiance, dans le respect de la loi.',
            ),

            const SizedBox(height: 16),
            _sectionTitle('📅 Mises à jour', textColor),
            _sectionCard(
              textColor,
              'Cette politique peut être mise à jour. Nous vous informerons via l\'application en cas de changements majeurs.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                'Dernière mise à jour : 18 Avril 2025',
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
