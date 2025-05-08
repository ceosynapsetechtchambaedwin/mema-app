import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../view_models/langue_view_model.dart';
import '../../view_models/setting_provider.dart';
import '../../view_models/theme_provider.dart';
import '../donations/donation_page.dart';
import '../home/app_bar.dart';
import '../user/PrivacyPolicyPage.dart';
import '../user/profile_page.dart';
import '../user/transaction_history_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isFrench = languageProvider.isFrench;

    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settings, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56.0),
            child: ModernAppBar(
              context,
              title: isFrench ? 'Paramètres' : 'Settings',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(
                context,
                isFrench
                    ? "Apparence & Préférences"
                    : "Appearance & Preferences",
              ),

              _animatedCard(
                child: SwitchListTile(
                  title: Text(isFrench ? 'Mode sombre' : 'Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  secondary: Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              _animatedCard(
                child: SwitchListTile(
                  title: Text(isFrench ? 'Notifications' : 'Notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotifications,
                  secondary: Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              _animatedCard(
                child: ListTile(
                  leading: Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(isFrench ? 'Langue' : 'Language'),
                  subtitle: Text(
                    isFrench ? 'Choisir la langue' : 'Choose your language',
                  ),
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

              const SizedBox(height: 20),
              _sectionTitle(
                context,
                isFrench ? "Compte & Sécurité" : "Account & Security",
              ),

              _buildMenuItem(
                context,
                icon: Icons.person,
                text: isFrench ? 'Gérer mon compte' : 'Manage My Account',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfilePage()),
                    ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.privacy_tip,
                text:
                    isFrench
                        ? 'Politique de confidentialité'
                        : 'Privacy Policy',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    ),
              ),

              const SizedBox(height: 20),
              _sectionTitle(context, isFrench ? "Activités" : "Activities"),

              _buildMenuItem(
                context,
                icon: Icons.card_giftcard,
                text: isFrench ? 'Faire un don' : 'Make a Donation',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonationPage()),
                    ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.history,
                text:
                    isFrench
                        ? 'Historique des transactions'
                        : 'Transaction History',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryPage(),
                      ),
                    ),
              ),

              const SizedBox(height: 20),
              _sectionTitle(context, isFrench ? "Informations" : "Information"),

              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                text: isFrench ? 'À propos' : 'About',
                subtitle:
                    isFrench
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

              const SizedBox(height: 30),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await AuthService().signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          isFrench ? 'Se déconnecter' : 'Log out',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return _animatedCard(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(text),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _animatedCard({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
