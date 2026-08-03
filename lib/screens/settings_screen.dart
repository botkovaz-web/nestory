import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/premium_paywall.dart';
import '../widgets/app_bar_actions.dart';
import '../main.dart'; // Kvôli themeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = AuthService();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile, style: const TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.deleteProfileWarning),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.enterPasswordToConfirm,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.no)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (passwordController.text.isEmpty) return;
              try {
                await authService.deleteAccount(passwordController.text);
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deleteAccountError)),
                  );
                }
              }
            },
            child: Text(l10n.yes, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = DatabaseService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: const [
          NestoryAppBarActions(),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: dbService.userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final name = userData?['name'] ?? l10n.creator;
          final email = userData?['email'] ?? '';
          final isPremium = userData?['isPremium'] ?? false;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // User Info Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.brightness == Brightness.dark ? AppColors.accentDark : AppColors.accent,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(email, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Premium Status Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isPremium 
                    ? const LinearGradient(colors: [Colors.amber, Colors.orange])
                    : null,
                  color: isPremium ? null : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isPremium ? null : Border.all(color: theme.colorScheme.primary.withAlpha(theme.brightness == Brightness.dark ? 50 : 100)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPremium ? Icons.stars : Icons.star_outline, 
                          color: isPremium ? Colors.white : theme.colorScheme.primary, 
                          size: 32
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premiumStatus, 
                              style: TextStyle(
                                color: isPremium ? Colors.white : theme.colorScheme.onSurface, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              )
                            ),
                            Text(
                              isPremium ? l10n.premiumActive : l10n.freeVersion, 
                              style: TextStyle(
                                color: isPremium ? Colors.white70 : theme.colorScheme.onSurface.withAlpha(150), 
                                fontSize: 12
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!isPremium) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => showPremiumPaywall(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.brightness == Brightness.dark ? AppColors.accentDark : AppColors.oliveDark,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.getPremium, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme Switcher Section
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(l10n.theme, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, currentMode, _) {
                    return Row(
                      children: [
                        _buildThemeOption(context, ThemeMode.system, Icons.brightness_auto, l10n.system, currentMode),
                        _buildThemeOption(context, ThemeMode.light, Icons.light_mode, l10n.light, currentMode),
                        _buildThemeOption(context, ThemeMode.dark, Icons.dark_mode, l10n.dark, currentMode),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSettingsTile(
                context: context,
                icon: Icons.description_outlined,
                title: l10n.termsAndConditions,
                onTap: () => _launchUrl('https://sites.google.com/view/nestoryhome/terms-conditions'),
              ),
              _buildSettingsTile(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () => _launchUrl('https://sites.google.com/view/nestoryhome/privacy-policy'),
              ),
              const Divider(height: 40),
              
              _buildSettingsTile(
                context: context,
                icon: Icons.logout,
                title: l10n.logout,
                onTap: () => _showLogoutConfirmation(context),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context: context,
                icon: Icons.delete_forever,
                title: l10n.deleteProfile,
                color: Colors.red,
                onTap: () => _confirmDeleteAccount(context),
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'NestyCraft v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, IconData icon, String label, ThemeMode currentMode) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);
    final activeColor = theme.brightness == Brightness.dark ? AppColors.accentDark : AppColors.oliveDark;

    return Expanded(
      child: GestureDetector(
        onTap: () => themeNotifier.value = mode,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withAlpha(100), size: 20),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface.withAlpha(150),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color ?? defaultColor),
      title: Text(title, style: TextStyle(color: color ?? defaultColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
