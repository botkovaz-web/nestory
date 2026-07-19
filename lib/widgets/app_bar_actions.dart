import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class NestoryAppBarActions extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const NestoryAppBarActions({super.key, this.onNavigate});

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onNavigate != null)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 22),
            onPressed: () => onNavigate!(5),
          ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.grey, size: 22),
          onPressed: () => _showLogoutConfirmation(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
