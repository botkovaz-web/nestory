import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/tool_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../widgets/detail_entry_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/nestory_fab.dart';
import '../services/database_service.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _dbService = DatabaseService();

  void _showDetailDialog(ToolModel tool) {
    final l10n = AppLocalizations.of(context)!;
    Color conditionColor;
    switch (tool.condition) {
      case 'Výborný': conditionColor = Colors.green; break;
      case 'Potrebuje údržbu': conditionColor = Colors.orange; break;
      case 'Nefunkčný': conditionColor = Colors.red; break;
      default: conditionColor = Colors.grey;
    }

    showDialog(
      context: context,
      builder: (context) => DetailEntryDialog(
        title: tool.name,
        onEdit: () {
          Navigator.pop(context);
          _showAddToolDialog(tool);
        },
        onDelete: () => _dbService.deleteTool(tool.id),
        children: [
          DetailEntryDialog.buildDetailRow(Icons.category_outlined, l10n.category, tool.getLocalizedCategory(l10n)),
          DetailEntryDialog.buildDetailRow(Icons.info_outline, l10n.status, tool.getLocalizedCondition(l10n), valueColor: conditionColor),
          if (tool.location.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.location_on_outlined, l10n.location, tool.location),
          if (tool.note.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.notes_outlined, l10n.note, tool.note),
          if (tool.updatedAt != null)
            DetailEntryDialog.buildDetailRow(Icons.history, 'Naposledy', DateFormat('dd.MM.yyyy HH:mm').format(tool.updatedAt!)),
        ],
      ),
    );
  }

  void _showAddToolDialog([ToolModel? tool]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: tool?.name ?? '');
    final noteController = TextEditingController(text: tool?.note ?? '');
    final locationController = TextEditingController(text: tool?.location ?? '');
    String category = tool?.category ?? 'Ručné náradie';
    String condition = tool?.condition ?? 'Výborný';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: tool == null ? '${l10n.add} ${l10n.tools.toLowerCase()}' : '${l10n.edit} ${l10n.tools.toLowerCase()}',
          onSave: () async {
            if (nameController.text.trim().isEmpty) return;
            final data = ToolModel(
              id: tool?.id ?? '',
              name: nameController.text.trim(),
              category: category,
              condition: condition,
              note: noteController.text.trim(),
              location: locationController.text.trim(),
            ).toMap();

            tool == null ? await _dbService.addTool(data) : await _dbService.updateTool(tool.id, data);
            if (mounted) Navigator.pop(context);
          },
          content: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: ['Stroje', 'Ručné náradie', 'Meradlá', 'Organizéry', 'Iné'].map((cat) => DropdownMenuItem(value: cat, child: Text(ToolModel(id: '', name: '', category: cat, condition: '').getLocalizedCategory(l10n)))).toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: InputDecoration(labelText: l10n.status),
                items: ['Výborný', 'Potrebuje údržbu', 'Nefunkčný'].map((cond) => DropdownMenuItem(value: cond, child: Text(ToolModel(id: '', name: '', category: '', condition: cond).getLocalizedCondition(l10n)))).toList(),
                onChanged: (val) => condition = val!,
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
      floatingActionButton: NestoryFAB(heroTag: 'tools_fab', onPressed: () => _showAddToolDialog()),
      body: StreamBuilder<List<ToolModel>>(
        stream: _dbService.tools,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return NestoryEmptyState(imagePath: 'assets/nesti_watching.png', message: l10n.noTools);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tool = snapshot.data![index];
              return NestoryCard(
                title: tool.name,
                subtitle: Text(tool.getLocalizedCategory(l10n)),
                trailing: Text(tool.getLocalizedCondition(l10n), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
                onTap: () => _showDetailDialog(tool),
              );
            },
          );
        },
      ),
    );
  }
}
