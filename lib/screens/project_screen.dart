import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/project_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../widgets/nestory_fab.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/nestory_chip_selection.dart';
import '../widgets/premium_paywall.dart';
import '../widgets/detail_entry_dialog.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _dbService = DatabaseService();
  final _storageService = StorageService();

  void _showDetailDialog(ProjectModel project) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor = project.status == 'Vo výrobe' ? Colors.orange : (project.status == 'Hotovo' ? Colors.green : Colors.grey);

    showDialog(
      context: context,
      builder: (context) => DetailEntryDialog(
        title: project.name,
        onEdit: () {
          Navigator.pop(context);
          _showAddProjectDialog(project);
        },
        onDelete: () => _dbService.deleteProject(project.id),
        children: [
          if (project.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(project.imageUrl!, width: double.infinity, height: 150, fit: BoxFit.cover),
              ),
            ),
          DetailEntryDialog.buildDetailRow(Icons.info_outline, l10n.status, project.getLocalizedStatus(l10n), valueColor: statusColor),
          if (project.isForCustomer) ...[
            DetailEntryDialog.buildDetailRow(Icons.person_outline, l10n.customerName, project.customerName ?? ''),
            DetailEntryDialog.buildDetailRow(Icons.euro_outlined, l10n.price, '${project.price.toStringAsFixed(2)} €'),
            DetailEntryDialog.buildDetailRow(Icons.check_circle_outline, l10n.paid, project.isPaid ? l10n.yes : l10n.no, valueColor: project.isPaid ? Colors.green : Colors.red),
          ],
          if (project.deadline != null)
            DetailEntryDialog.buildDetailRow(Icons.calendar_today_outlined, l10n.deadline, DateFormat('dd.MM.yyyy').format(project.deadline!)),
          if (project.requiredMaterials.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.inventory_2_outlined, l10n.material, project.requiredMaterials.join(', ')),
          if (project.requiredTools.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.build_outlined, l10n.tools, project.requiredTools.join(', ')),
          if (project.description.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.notes_outlined, l10n.note, project.description),
          if (project.updatedAt != null)
            DetailEntryDialog.buildDetailRow(Icons.history, 'Naposledy', DateFormat('dd.MM.yyyy HH:mm').format(project.updatedAt!)),
        ],
      ),
    );
  }

  Future<void> _showAddProjectDialog([ProjectModel? project]) async {
    final l10n = AppLocalizations.of(context)!;
    if (project == null) {
      final isPremium = await _dbService.isPremium.first;
      final projects = await _dbService.projects.first;
      if (!isPremium && projects.length >= 10) {
        if (mounted) showPremiumPaywall(context);
        return;
      }
    }

    final nameController = TextEditingController(text: project?.name ?? '');
    final descController = TextEditingController(text: project?.description ?? '');
    final customerController = TextEditingController(text: project?.customerName ?? '');
    final priceController = TextEditingController(text: project != null ? project.price.toString() : '');
    
    String status = project?.status ?? 'V pláne';
    bool isForCustomer = project?.isForCustomer ?? false;
    bool isPaid = project?.isPaid ?? false;
    DateTime? deadline = project?.deadline;
    List<String> selectedMaterials = List.from(project?.requiredMaterials ?? []);
    List<String> selectedTools = List.from(project?.requiredTools ?? []);
    File? imageFile;
    String? imageUrl = project?.imageUrl;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: project == null ? '${l10n.add} ${l10n.projects.toLowerCase()}' : '${l10n.edit} ${l10n.projects.toLowerCase()}',
          isSaving: isSaving,
          onSave: () async {
            if (nameController.text.isEmpty) return;
            setDialogState(() => isSaving = true);
            try {
              String? finalUrl = imageUrl;
              if (imageFile != null) finalUrl = await _storageService.uploadProjectImage(imageFile!);

              final data = ProjectModel(
                id: project?.id ?? '',
                name: nameController.text.trim(),
                description: descController.text.trim(),
                status: status,
                deadline: deadline,
                imageUrl: finalUrl,
                requiredMaterials: selectedMaterials,
                requiredTools: selectedTools,
                isForCustomer: isForCustomer,
                customerName: isForCustomer ? customerController.text.trim() : null,
                price: double.tryParse(priceController.text) ?? 0.0,
                isPaid: isPaid,
              ).toMap();

              project == null ? await _dbService.addProject(data) : await _dbService.updateProject(project.id, data);
              if (mounted) Navigator.pop(context);
            } finally {
              if (mounted) setDialogState(() => isSaving = false);
            }
          },
          content: Column(
            children: [
              _buildImagePicker(imageFile, imageUrl, () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                if (picked != null) setDialogState(() => imageFile = File(picked.path));
              }),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: l10n.status),
                items: ['V pláne', 'Príprava', 'Vo výrobe', 'Hotovo'].map((s) => DropdownMenuItem(value: s, child: Text(ProjectModel(id: '', name: '', status: s).getLocalizedStatus(l10n)))).toList(),
                onChanged: (val) => status = val!,
              ),
              const SizedBox(height: 16),
              _buildCustomerToggle(l10n, isForCustomer, (val) => setDialogState(() => isForCustomer = val)),
              if (isForCustomer) _buildCustomerFields(l10n, customerController, priceController, isPaid, (val) => setDialogState(() => isPaid = val)),
              ListTile(
                title: Text(deadline == null ? l10n.deadline : DateFormat('dd.MM.yyyy').format(deadline!)),
                trailing: const Icon(Icons.calendar_today, size: 20),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: deadline ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (picked != null) setDialogState(() => deadline = picked);
                },
                contentPadding: EdgeInsets.zero,
              ),
              TextField(controller: descController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
              const SizedBox(height: 16),
              _buildSelection(l10n.material, _dbService.materials, selectedMaterials, (list) => setDialogState(() => selectedMaterials = list)),
              const SizedBox(height: 8),
              _buildSelection(l10n.tools, _dbService.tools, selectedTools, (list) => setDialogState(() => selectedTools = list)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(File? file, String? url, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12),
          image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : (url != null ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null),
        ),
        child: file == null && url == null ? const Icon(Icons.add_a_photo, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildCustomerToggle(AppLocalizations l10n, bool isForCustomer, Function(bool) onChanged) {
    return Row(children: [
      Expanded(child: ChoiceChip(label: Text(l10n.forStock), selected: !isForCustomer, onSelected: (val) => onChanged(!val))),
      const SizedBox(width: 8),
      Expanded(child: ChoiceChip(label: Text(l10n.forCustomer), selected: isForCustomer, onSelected: (val) => onChanged(val))),
    ]);
  }

  Widget _buildCustomerFields(AppLocalizations l10n, TextEditingController name, TextEditingController price, bool isPaid, Function(bool) onPaidChanged) {
    return Column(children: [
      const SizedBox(height: 8),
      TextField(controller: name, decoration: InputDecoration(labelText: l10n.customerName)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: price, decoration: InputDecoration(labelText: '${l10n.price} (€)'), keyboardType: TextInputType.number)),
        const SizedBox(width: 16),
        Column(children: [Text(l10n.paid, style: const TextStyle(fontSize: 12)), Checkbox(value: isPaid, onChanged: (val) => onPaidChanged(val ?? false))]),
      ]),
    ]);
  }

  Widget _buildSelection(String title, Stream<List<dynamic>> stream, List<String> selected, Function(List<String>) onChanged) {
    return StreamBuilder<List<dynamic>>(
      stream: stream,
      builder: (context, snapshot) {
        return NestoryChipSelection(
          title: title,
          allItems: snapshot.hasData ? snapshot.data!.map((e) => e.name as String).toList() : [],
          selectedItems: selected,
          onChanged: onChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: NestoryFAB(heroTag: 'proj_fab', onPressed: () => _showAddProjectDialog()),
      body: StreamBuilder<List<ProjectModel>>(
        stream: _dbService.projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return NestoryEmptyState(imagePath: 'assets/nesti_organizing.png', message: l10n.noProjects);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              Color statusColor = project.status == 'Vo výrobe' ? Colors.orange : (project.status == 'Hotovo' ? Colors.green : Colors.grey);
              return NestoryCard(
                leading: _buildCardLeading(project),
                title: project.name,
                subtitle: _buildCardSubtitle(context, project, statusColor),
                trailing: _buildCardTrailing(l10n, project),
                onTap: () => _showDetailDialog(project),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardLeading(ProjectModel project) {
    return project.imageUrl != null 
      ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(project.imageUrl!, width: 50, height: 50, fit: BoxFit.cover))
      : Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.palette_outlined, color: Colors.grey));
  }

  Widget _buildCardSubtitle(BuildContext context, ProjectModel project, Color statusColor) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(project.getLocalizedStatus(l10n), style: TextStyle(color: statusColor, fontSize: 12)),
      if (project.isForCustomer) Text('👤 ${project.customerName ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
    ]);
  }

  Widget _buildCardTrailing(AppLocalizations l10n, ProjectModel project) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (project.isForCustomer) Padding(padding: const EdgeInsets.only(right: 8.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${project.price.toStringAsFixed(2)} €'),
        Icon(project.isPaid ? Icons.check_circle : Icons.error_outline, size: 14, color: project.isPaid ? Colors.green : Colors.red),
      ])),
    ]);
  }
}
