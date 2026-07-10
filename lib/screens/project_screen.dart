import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/project_model.dart';
import '../models/order_model.dart';
import '../l10n/app_localizations.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
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
    String status = project?.status ?? 'V pláne';
    bool isForOrder = project?.isForOrder ?? false;
    String? selectedOrderId = project?.orderId;
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
        builder: (context, setDialogState) => AlertDialog(
          title: Text(project == null ? '${l10n.add} ${l10n.projects.toLowerCase()}' : '${l10n.edit} ${l10n.projects.toLowerCase()}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                      if (picked != null) {
                        setDialogState(() => imageFile = File(picked.path));
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: imageFile != null
                            ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                            : (imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null),
                      ),
                      child: imageFile == null && imageUrl == null
                          ? const Icon(Icons.add_a_photo, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: l10n.status),
                    items: [
                      DropdownMenuItem(value: 'V pláne', child: Text(l10n.statusPlanning)),
                      DropdownMenuItem(value: 'Príprava', child: Text(l10n.statusPreparation)),
                      DropdownMenuItem(value: 'Vo výrobe', child: Text(l10n.statusProduction)),
                      DropdownMenuItem(value: 'Hotovo', child: Text(l10n.statusDone)),
                    ],
                    onChanged: (val) => status = val!,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(l10n.orders, style: const TextStyle(fontSize: 14)),
                    value: isForOrder,
                    onChanged: (val) => setDialogState(() => isForOrder = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isForOrder)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('orders').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final orders = snapshot.data!.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
                        return DropdownButtonFormField<String>(
                          value: selectedOrderId,
                          decoration: InputDecoration(labelText: l10n.customerName),
                          items: orders.map((o) => DropdownMenuItem(value: o.id, child: Text(o.customerName))).toList(),
                          onChanged: (val) => selectedOrderId = val,
                        );
                      },
                    ),
                  ListTile(
                    title: Text(deadline == null ? l10n.deadline : DateFormat('dd.MM.yyyy').format(deadline!)),
                    trailing: const Icon(Icons.calendar_today, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: deadline ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (picked != null) setDialogState(() => deadline = picked);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: descController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
                  const SizedBox(height: 16),
                  _buildChipSelection(
                    title: l10n.material,
                    collection: 'materials',
                    selected: selectedMaterials,
                    onChanged: (list) => setDialogState(() => selectedMaterials = list),
                  ),
                  const SizedBox(height: 8),
                  _buildChipSelection(
                    title: l10n.tools,
                    collection: 'tools',
                    selected: selectedTools,
                    onChanged: (list) => setDialogState(() => selectedTools = list),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isSaving ? null : () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameController.text.isEmpty) return;
                setDialogState(() => isSaving = true);
                
                String? finalUrl = imageUrl;
                if (imageFile != null) {
                  final ref = FirebaseStorage.instance.ref().child('users/${user!.uid}/projects/${DateTime.now().millisecondsSinceEpoch}.jpg');
                  await ref.putFile(imageFile!);
                  finalUrl = await ref.getDownloadURL();
                }

                final data = ProjectModel(
                  id: project?.id ?? '',
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  status: status,
                  isForOrder: isForOrder,
                  orderId: isForOrder ? selectedOrderId : null,
                  deadline: deadline,
                  imageUrl: finalUrl,
                  requiredMaterials: selectedMaterials,
                  requiredTools: selectedTools,
                ).toMap();

                if (project == null) {
                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('projects').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('projects').doc(project.id).update(data);
                }
                if (mounted) Navigator.pop(context);
              },
              child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelection({required String title, required String collection, required List<String> selected, required Function(List<String>) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection(collection).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final items = snapshot.data!.docs.map((d) => d['name'] as String).toList();
            return Wrap(
              spacing: 4,
              children: items.map((name) {
                final isSel = selected.contains(name);
                return FilterChip(
                  label: Text(name, style: const TextStyle(fontSize: 11)),
                  selected: isSel,
                  onSelected: (s) {
                    final newList = List<String>.from(selected);
                    s ? newList.add(name) : newList.remove(name);
                    onChanged(newList);
                  },
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.projects), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(
        heroTag: 'proj_fab',
        onPressed: () => _showAddProjectDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('projects').orderBy('updatedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/nesti_organizing.png', height: 120), const SizedBox(height: 16), Text(l10n.noProjects, style: const TextStyle(color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final project = ProjectModel.fromFirestore(snapshot.data!.docs[index]);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: project.imageUrl != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(project.imageUrl!, width: 50, height: 50, fit: BoxFit.cover))
                    : Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.palette_outlined, color: Colors.grey)),
                  title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_getLocalizedStatus(context, project.status), style: TextStyle(color: project.status == 'Hotovo' ? Colors.green : Colors.orange)),
                  onTap: () => _showAddProjectDialog(project),
                  onLongPress: () {
                    showDialog(context: context, builder: (c) => AlertDialog(title: Text(l10n.deleteConfirmation), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)), TextButton(onPressed: () { FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('projects').doc(project.id).delete(); Navigator.pop(c); }, child: Text(l10n.yes, style: const TextStyle(color: Colors.red)))]));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
