import 'package:flutter/material.dart';
import 'package:mema/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:mema/view_models/setting_provider.dart';
import 'package:mema/view_models/theme_provider.dart';
import 'package:mema/views/donations/donation_page.dart';
import 'package:mema/views/user/PrivacyPolicyPage.dart';
import 'package:mema/views/user/profile_page.dart';
import 'package:mema/views/user/transaction_history_page.dart';
import '../../view_models/langue_view_model.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isFrench = languageProvider.isFrench;

    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settings, child) {
        return Scaffold(
          
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 3,
                child: SwitchListTile(
                  title: Text(isFrench ? 'Mode sombre' : 'Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  secondary: const Icon(Icons.dark_mode),
                ),
              ),

              Card(
                elevation: 3,
                child: SwitchListTile(
                  title: Text(isFrench ? 'Notifications' : 'Notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotifications,
                  secondary: const Icon(Icons.notifications),
                ),
              ),

              Card(
                elevation: 3,
                child: ListTile(
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
              ),

              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                icon: Icons.person,
                text: isFrench ? 'Gérer mon compte' : 'Manage my account',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage())),
              ),
              _buildMenuItem(
                context,
                icon: Icons.privacy_tip,
                text: isFrench ? 'Politique de confidentialité' : 'Privacy Policy',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
              ),
              _buildMenuItem(
                context,
                icon: Icons.card_giftcard,
                text: isFrench ? 'Faire un don' : 'Make a Donation',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationPage())),
              ),
              _buildMenuItem(
                context,
                icon: Icons.history,
                text: isFrench ? 'Historique des transactions' : 'Transaction History',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryPage())),
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                text: isFrench ? 'À propos' : 'About',
                subtitle: isFrench
                    ? 'Version 1.0.0 - Développée avec Synapse Tech ❤️'
                    : 'Version 1.0.0 - Made with Mema ❤️',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Mema',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 Synapse Tech',
                  );
                },
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(isFrench ? 'Se déconnecter' : 'Log out'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await AuthService().signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String text,
      String? subtitle,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(text),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
