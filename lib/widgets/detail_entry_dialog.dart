import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';

class DetailEntryDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DetailEntryDialog({
    super.key,
    required this.title,
    required this.children,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 22),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: () {
                  // Vnútorný potvrdzovací dialóg pre bezpečnosť
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(l10n.deleteConfirmation),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(c); // Zavrie potvrdenie
                            Navigator.pop(context); // Zavrie detail
                            onDelete(); // Vykoná zmazanie
                          },
                          child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel.replaceFirst(l10n.cancel[0], l10n.cancel[0].toUpperCase())), // "Zavrieť" alebo podobne
        ),
      ],
    );
  }

  // Pomocný widget pre riadok s informáciou, ktorý budeme volať z obrazoviek
  static Widget buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
