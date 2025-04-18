import 'package:flutter/material.dart';
import 'package:mema/view_models/setting_provider.dart';
import 'package:mema/view_models/theme_provider.dart';
import 'package:mema/views/donations/donation_page.dart';
import 'package:mema/views/user/PrivacyPolicyPage.dart';
import 'package:mema/views/user/profile_page.dart';
import 'package:mema/views/user/transaction_history_page.dart';
import 'package:provider/provider.dart';


import '../../view_models/langue_view_model.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isFrench = languageProvider.isFrench;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? 'Paramètres' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Mode sombre
          SwitchListTile(
            title: Text(isFrench ? 'Mode sombre' : 'Dark mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          // Notifications
          SwitchListTile(
            title: Text(isFrench ? 'Notifications' : 'Notifications'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.setNotifications(value);
            },
            secondary: const Icon(Icons.notifications_active),
          ),

          const Divider(),

          // Langue
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(isFrench ? 'Langue' : 'Language'),
            subtitle: Text(isFrench ? 'Choisir la langue' : 'Choose your language'),
            trailing: DropdownButton<String>(
              value: isFrench ? 'fr' : 'en',
              onChanged: (String? lang) {
                if (lang != null) {
                  languageProvider.setLanguage(lang == 'fr');
                }
              },
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),

          const Divider(),

          // Gérer mon compte
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(isFrench ? 'Gérer mon compte' : 'Manage my account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  UserProfilePage()),
              );
            },
          ),

          // Politique de confidentialité
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(isFrench ? 'Politique de confidentialité' : 'Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              );
            },
          ),

          // Faire un don
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Text(isFrench ? 'Faire un don' : 'Make a Donation'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationPage()),
              );
            },
          ),

          // Historique des transactions
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(isFrench ? 'Historique des transactions' : 'Transaction History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
              );
            },
          ),

          const Divider(),

          // À propos
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(isFrench ? 'À propos' : 'About'),
            subtitle: Text(isFrench
                ? 'Version 1.0.0 - Développée avec Synapse Tech❤️'
                : 'Version 1.0.0 - Made with Mema❤️'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Mema',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Synapse Tech',
              );
            },
          ),
        ],
      ),
    );
  }
}
