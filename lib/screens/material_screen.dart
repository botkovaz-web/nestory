import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/material_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../widgets/detail_entry_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/nestory_fab.dart';
import '../services/database_service.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final _dbService = DatabaseService();

  void _showDetailDialog(MaterialModel material) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => DetailEntryDialog(
        title: material.name,
        onEdit: () {
          Navigator.pop(context);
          _showAddMaterialDialog(material);
        },
        onDelete: () => _dbService.deleteMaterial(material.id),
        children: [
          DetailEntryDialog.buildDetailRow(Icons.category_outlined, l10n.category, material.getLocalizedCategory(l10n)),
          DetailEntryDialog.buildDetailRow(Icons.inventory_2_outlined, l10n.quantity, '${material.quantity} ${material.getLocalizedUnit(l10n)}', valueColor: AppColors.accent),
          if (material.location.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.location_on_outlined, l10n.location, material.location),
          if (material.note.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.notes_outlined, l10n.note, material.note),
          if (material.updatedAt != null)
            DetailEntryDialog.buildDetailRow(Icons.history, 'Naposledy', DateFormat('dd.MM.yyyy HH:mm').format(material.updatedAt!)),
        ],
      ),
    );
  }

  void _showAddMaterialDialog([MaterialModel? material]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: material?.name ?? '');
    final quantityController = TextEditingController(text: material?.quantity.toString() ?? '');
    final locationController = TextEditingController(text: material?.location ?? '');
    final noteController = TextEditingController(text: material?.note ?? '');
    String category = material?.category ?? 'Priadze';
    String unit = material?.unit ?? 'ks';

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

            material == null ? await _dbService.addMaterial(data) : await _dbService.updateMaterial(material.id, data);
            if (mounted) Navigator.pop(context);
          },
          content: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: ['Priadze', 'Korálky', 'Papiere', 'Látky', 'Iné'].map((cat) => DropdownMenuItem(value: cat, child: Text(MaterialModel(id: '', name: '', category: cat, quantity: 0, unit: '', location: '').getLocalizedCategory(l10n)))).toList(),
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
                    items: ['ks', 'g', 'kg', 'm', 'klbka', 'hárky', 'balenia'].map((u) => DropdownMenuItem(value: u, child: Text(MaterialModel(id: '', name: '', category: '', quantity: 0, unit: u, location: '').getLocalizedUnit(l10n), style: const TextStyle(fontSize: 14)))).toList(),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: NestoryFAB(heroTag: 'material_fab', onPressed: () => _showAddMaterialDialog()),
      body: StreamBuilder<List<MaterialModel>>(
        stream: _dbService.materials,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return NestoryEmptyState(imagePath: 'assets/nesti_watching.png', message: l10n.noMaterial);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final material = snapshot.data![index];
              return NestoryCard(
                title: material.name,
                subtitle: Text(material.getLocalizedCategory(l10n)),
                trailing: Text('${material.quantity} ${material.getLocalizedUnit(l10n)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
                onTap: () => _showDetailDialog(material),
              );
            },
          );
        },
      ),
    );
  }
}
