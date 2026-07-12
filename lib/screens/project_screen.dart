import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/project_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'V pláne': return l10n.statusPlanning;
      case 'Príprava': return l10n.statusPreparation;
      case 'Vo výrobe': return l10n.statusProduction;
      case 'Hotovo': return l10n.statusDone;
      default: return status;
    }
  }

  Future<void> _showAddProjectDialog([ProjectModel? project]) async {
    final l10n = AppLocalizations.of(context)!;
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
              if (imageFile != null) {
                finalUrl = await _storageService.uploadProjectImage(imageFile!);
              }

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

              if (project == null) {
                await _dbService.addProject(data);
              } else {
                await _dbService.updateProject(project.id, data);
              }
              if (mounted) Navigator.pop(context);
            } catch (e) {
              print('Chyba pri ukladaní projektu: $e');
            } finally {
              setDialogState(() => isSaving = false);
            }
          },
          content: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (picked != null) setDialogState(() => imageFile = File(picked.path));
                },
                child: Container(
                  height: 120, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12),
                    image: imageFile != null ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover) : (imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null),
                  ),
                  child: imageFile == null && imageUrl == null ? const Icon(Icons.add_a_photo, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: l10n.status),
                items: ['V pláne', 'Príprava', 'Vo výrobe', 'Hotovo'].map((s) => DropdownMenuItem(value: s, child: Text(_getLocalizedStatus(context, s)))).toList(),
                onChanged: (val) => status = val!,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: ChoiceChip(label: Text(l10n.forStock), selected: !isForCustomer, onSelected: (val) => setDialogState(() => isForCustomer = !val))),
                const SizedBox(width: 8),
                Expanded(child: ChoiceChip(label: Text(l10n.forCustomer), selected: isForCustomer, onSelected: (val) => setDialogState(() => isForCustomer = val))),
              ]),
              if (isForCustomer) ...[
                const SizedBox(height: 8),
                TextField(controller: customerController, decoration: InputDecoration(labelText: l10n.customerName)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: priceController, decoration: InputDecoration(labelText: '${l10n.price} (€)'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Column(children: [Text(l10n.paid, style: const TextStyle(fontSize: 12)), Checkbox(value: isPaid, onChanged: (val) => setDialogState(() => isPaid = val ?? false))]),
                ]),
              ],
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
              _buildChipSelection(title: l10n.material, collection: 'materials', selected: selectedMaterials, onChanged: (list) => setDialogState(() => selectedMaterials = list)),
              const SizedBox(height: 8),
              _buildChipSelection(title: l10n.tools, collection: 'tools', selected: selectedTools, onChanged: (list) => setDialogState(() => selectedTools = list)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipSelection({required String title, required String collection, required List<String> selected, required Function(List<String>) onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final items = snapshot.data!.docs.map((d) => d['name'] as String).toList();
          return Wrap(spacing: 4, children: items.map((name) {
            final isSel = selected.contains(name);
            return FilterChip(label: Text(name, style: const TextStyle(fontSize: 11)), selected: isSel, onSelected: (s) {
              final newList = List<String>.from(selected);
              s ? newList.add(name) : newList.remove(name);
              onChanged(newList);
            }, padding: EdgeInsets.zero);
          }).toList());
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projects),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(heroTag: 'proj_fab', onPressed: () => _showAddProjectDialog(), backgroundColor: AppColors.accent, child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<List<ProjectModel>>(
        stream: _dbService.projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/nesti_organizing.png', height: 120), const SizedBox(height: 16), Text(l10n.noProjects, style: const TextStyle(color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              Color statusColor;
              switch (project.status) {
                case 'Vo výrobe': statusColor = Colors.orange; break;
                case 'Hotovo': statusColor = Colors.green; break;
                default: statusColor = Colors.grey;
              }

              return NestoryCard(
                leading: project.imageUrl != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(project.imageUrl!, width: 50, height: 50, fit: BoxFit.cover))
                  : Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.palette_outlined, color: Colors.grey)),
                title: project.name,
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_getLocalizedStatus(context, project.status), style: TextStyle(color: statusColor, fontSize: 12)),
                  if (project.isForCustomer) Text('👤 ${project.customerName ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ]),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (project.isForCustomer) Padding(padding: const EdgeInsets.only(right: 8.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${project.price.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Icon(project.isPaid ? Icons.check_circle : Icons.error_outline, size: 14, color: project.isPaid ? Colors.green : Colors.red),
                  ])),
                  IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () {
                    showDialog(context: context, builder: (c) => AlertDialog(title: Text(l10n.deleteConfirmation), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)), TextButton(onPressed: () { _dbService.deleteProject(project.id); Navigator.pop(c); }, child: Text(l10n.yes, style: const TextStyle(color: Colors.red)))]));
                  }),
                ]),
                onTap: () => _showAddProjectDialog(project),
              );
            },
          );
        },
      ),
    );
  }
}
