import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/tool_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../services/database_service.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _dbService = DatabaseService();

  String _getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'Stroje': return l10n.catMachines;
      case 'Ručné náradie': return l10n.catHandTools;
      case 'Meradlá': return l10n.catMeasuring;
      case 'Organizéry': return l10n.catOrganizers;
      case 'Iné': return l10n.catOther;
      default: return category;
    }
  }

  String _getLocalizedCondition(BuildContext context, String condition) {
    final l10n = AppLocalizations.of(context)!;
    switch (condition) {
      case 'Výborný': return l10n.condExcellent;
      case 'Potrebuje údržbu': return l10n.condMaintenance;
      case 'Nefunkčný': return l10n.condBroken;
      default: return condition;
    }
  }

  void _showDetailSheet(ToolModel tool) {
    final l10n = AppLocalizations.of(context)!;
    
    Color conditionColor;
    switch (tool.condition) {
      case 'Výborný': conditionColor = Colors.green; break;
      case 'Potrebuje údržbu': conditionColor = Colors.orange; break;
      case 'Nefunkčný': conditionColor = Colors.red; break;
      default: conditionColor = Colors.grey;
    }

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
                Expanded(
                  child: Text(tool.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Icons.edit, color: AppColors.accent), onPressed: () {
                  Navigator.pop(context);
                  _showAddToolDialog(tool);
                }),
              ],
            ),
            Text(_getLocalizedCategory(context, tool.category), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            const Divider(height: 32),
            _buildDetailRow(Icons.info_outline, l10n.status, _getLocalizedCondition(context, tool.condition), conditionColor),
            if (tool.location.isNotEmpty)
              _buildDetailRow(Icons.location_on, l10n.location, tool.location),
            if (tool.note.isNotEmpty)
              _buildDetailRow(Icons.note, l10n.note, tool.note),
            if (tool.updatedAt != null)
              _buildDetailRow(Icons.update, 'Aktualizované', DateFormat('dd.MM.yyyy HH:mm').format(tool.updatedAt!)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor)),
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

            if (tool == null) {
              await _dbService.addTool(data);
            } else {
              await _dbService.updateTool(tool.id, data);
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
                items: ['Stroje', 'Ručné náradie', 'Meradlá', 'Organizéry', 'Iné'].map((cat) => DropdownMenuItem(value: cat, child: Text(_getLocalizedCategory(context, cat)))).toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: InputDecoration(labelText: l10n.status),
                items: ['Výborný', 'Potrebuje údržbu', 'Nefunkčný'].map((cond) => DropdownMenuItem(value: cond, child: Text(_getLocalizedCondition(context, cond)))).toList(),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'tools_fab_unique',
        onPressed: () => _showAddToolDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<ToolModel>>(
        stream: _dbService.tools,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/nesti_watching.png', height: 150), const SizedBox(height: 16), Text(l10n.noTools, style: const TextStyle(color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tool = snapshot.data![index];
              
              Color conditionColor;
              switch (tool.condition) {
                case 'Výborný': conditionColor = Colors.green; break;
                case 'Potrebuje údržbu': conditionColor = Colors.orange; break;
                case 'Nefunkčný': conditionColor = Colors.red; break;
                default: conditionColor = Colors.grey;
              }

              return NestoryCard(
                title: tool.name,
                subtitle: Text(_getLocalizedCategory(context, tool.category)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: conditionColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: conditionColor)),
                      child: Text(_getLocalizedCondition(context, tool.condition), style: TextStyle(fontSize: 12, color: conditionColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () {
                      showDialog(context: context, builder: (c) => AlertDialog(title: Text(l10n.deleteConfirmation), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)), TextButton(onPressed: () { _dbService.deleteTool(tool.id); Navigator.pop(c); }, child: Text(l10n.yes, style: const TextStyle(color: Colors.red)))]));
                    }),
                  ],
                ),
                onTap: () => _showDetailSheet(tool),
              );
            },
          );
        },
      ),
    );
  }
}
