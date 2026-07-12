import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/material_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../services/database_service.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final _dbService = DatabaseService();

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Priadze': return l10n.catYarns;
      case 'Korálky': return l10n.catBeads;
      case 'Papiere': return l10n.catPapers;
      case 'Látky': return l10n.catFabrics;
      case 'Iné': return l10n.catOther;
      default: return category;
    }
  }

  String _getLocalizedUnit(BuildContext context, String unit) {
    final l10n = AppLocalizations.of(context)!;
    switch (unit) {
      case 'ks': return l10n.unitPcs;
      case 'g': return l10n.unitGrams;
      case 'kg': return l10n.unitKg;
      case 'm': return l10n.unitMeters;
      case 'klbka': return l10n.unitBalls;
      case 'hárky': return l10n.unitSheets;
      case 'balenia': return l10n.unitPacks;
      default: return unit;
    }
  }

  void _showAddMaterialDialog([MaterialModel? material]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: material?.name ?? '');
    final quantityController = TextEditingController(text: material?.quantity.toString() ?? '');
    final locationController = TextEditingController(text: material?.location ?? '');
    final noteController = TextEditingController(text: material?.note ?? '');
    String category = material?.category ?? 'Priadze';
    String unit = material?.unit ?? 'ks';

    final List<String> _units = ['ks', 'g', 'kg', 'm', 'klbka', 'hárky', 'balenia'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: material == null ? '${l10n.add} ${l10n.material.toLowerCase()}' : '${l10n.edit} ${l10n.material.toLowerCase()}',
          onSave: () async {
            if (nameController.text.trim().isEmpty) return;
            final data = MaterialModel(
              id: material?.id ?? '',
              name: nameController.text.trim(),
              category: category,
              quantity: double.tryParse(quantityController.text) ?? 0,
              unit: unit,
              location: locationController.text.trim(),
              note: noteController.text.trim(),
            ).toMap();

            if (material == null) {
              await _dbService.addMaterial(data);
            } else {
              await _dbService.updateMaterial(material.id, data);
            }
            if (mounted) Navigator.pop(context);
          },
          content: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: ['Priadze', 'Korálky', 'Papiere', 'Látky', 'Iné'].map((cat) => DropdownMenuItem(value: cat, child: Text(_getLocalizedCategory(context, cat)))).toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: quantityController, decoration: InputDecoration(labelText: l10n.quantity), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: unit,
                    decoration: InputDecoration(labelText: l10n.unit, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(_getLocalizedUnit(context, u), style: const TextStyle(fontSize: 14)))).toList(),
                    onChanged: (val) => setDialogState(() => unit = val!),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: locationController, decoration: InputDecoration(labelText: l10n.location)),
              const SizedBox(height: 16),
              TextField(controller: noteController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(MaterialModel material) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: AppColors.background,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(material.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.edit, color: AppColors.accent), onPressed: () {
                  Navigator.pop(context);
                  _showAddMaterialDialog(material);
                }),
              ],
            ),
            Text(_getLocalizedCategory(context, material.category), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            const Divider(height: 32),
            _buildDetailRow(Icons.inventory, l10n.quantity, '${material.quantity} ${_getLocalizedUnit(context, material.unit)}'),
            if (material.location.isNotEmpty) _buildDetailRow(Icons.location_on, l10n.location, material.location),
            if (material.note.isNotEmpty) _buildDetailRow(Icons.note, l10n.note, material.note),
            if (material.updatedAt != null) _buildDetailRow(Icons.update, 'Aktualizované', DateFormat('dd.MM.yyyy HH:mm').format(material.updatedAt!)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'material_fab_unique',
        onPressed: () => _showAddMaterialDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<MaterialModel>>(
        stream: _dbService.materials,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/nesti_watching.png', height: 150), const SizedBox(height: 16), Text(l10n.noMaterial, style: const TextStyle(color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final material = snapshot.data![index];
              return NestoryCard(
                title: material.name,
                subtitle: Text(_getLocalizedCategory(context, material.category)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${material.quantity} ${_getLocalizedUnit(context, material.unit)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () {
                      showDialog(context: context, builder: (c) => AlertDialog(title: Text(l10n.deleteConfirmation), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)), TextButton(onPressed: () { _dbService.deleteMaterial(material.id); Navigator.pop(c); }, child: Text(l10n.yes, style: const TextStyle(color: Colors.red)))]));
                    }),
                  ],
                ),
                onTap: () => _showDetailSheet(material),
              );
            },
          );
        },
      ),
    );
  }
}
