import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/premium_paywall.dart';
import '../widgets/app_bar_actions.dart';

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
                labelText: 'Zadajte heslo pre potvrdenie',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    const SnackBar(content: Text('Chybné heslo alebo chyba pri mazaní')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(email, style: const TextStyle(color: Colors.grey)),
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
                  color: isPremium ? null : Colors.white.withAlpha(150),
                  borderRadius: BorderRadius.circular(20),
                  border: isPremium ? null : Border.all(color: AppColors.accent.withAlpha(100)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPremium ? Icons.stars : Icons.star_outline, 
                          color: isPremium ? Colors.white : AppColors.accent, 
                          size: 32
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premiumStatus, 
                              style: TextStyle(
                                color: isPremium ? Colors.white : Colors.black87, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              )
                            ),
                            Text(
                              isPremium ? l10n.premiumActive : 'Free Verzia', 
                              style: TextStyle(
                                color: isPremium ? Colors.white70 : Colors.grey.shade600, 
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
                          backgroundColor: AppColors.accent,
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
              const SizedBox(height: 32),
              
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: l10n.termsAndConditions,
                onTap: () => _launchUrl('https://sites.google.com/view/nestoryhome/terms-conditions'),
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () => _launchUrl('https://sites.google.com/view/nestoryhome/privacy-policy'),
              ),
              const Divider(height: 40),
              
              _buildSettingsTile(
                icon: Icons.logout,
                title: l10n.logout,
                color: Colors.black87,
                onTap: () => _showLogoutConfirmation(context),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
