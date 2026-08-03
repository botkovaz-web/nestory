import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../app_colors.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class PremiumPaywall extends StatefulWidget {
  const PremiumPaywall({super.key});

  @override
  State<PremiumPaywall> createState() => _PremiumPaywallState();
}

class _PremiumPaywallState extends State<PremiumPaywall> {
  bool _isPurchasing = false;

  Future<void> _handlePurchase() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isPurchasing = true);
    final dbService = DatabaseService();

    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.monthly != null) {
        
        final result = await Purchases.purchasePackage(offerings.current!.monthly!);
        final customerInfo = result.customerInfo;
        
        if (customerInfo.entitlements.all['NestyCraftPro']?.isActive ?? false) {
          await dbService.updatePremiumStatus(true);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.purchaseSuccess)),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Chyba pri nákupe: $e');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isPurchasing = true);
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.all['NestyCraftPro']?.isActive ?? false;
      await DatabaseService().updatePremiumStatus(isPremium);
      
      if (mounted) {
        if (isPremium) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.restoreSuccess)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noActiveSubscription)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/nesti_happy.png', height: 120),
          const SizedBox(height: 24),
          Text(
            l10n.becomePremiumTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.becomePremiumDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _isPurchasing 
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  ElevatedButton(
                    onPressed: _handlePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: Text(l10n.activatePremiumButton, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _restorePurchases,
                    child: Text(l10n.restorePurchases, style: const TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.maybeLater, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

void showPremiumPaywall(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (context) => const PremiumPaywall(),
  );
}
