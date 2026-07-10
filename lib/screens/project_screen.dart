import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/project_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final user = FirebaseAuth.instance.currentUser;

  void _showAddProjectDialog([ProjectModel? project]) {
    final nameController = TextEditingController(text: project != null ? project.name : '');
    final descriptionController = TextEditingController(text: project != null ? project.description : '');
    String status = project != null ? project.status : 'Rozpracované';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project == null ? 'Nový projekt' : 'Upraviť projekt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Názov projektu'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Stav'),
                items: ['V pláne', 'Rozpracované', 'Hotové']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => status = val!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Poznámky k projektu'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final newProject = ProjectModel(
                id: project?.id ?? '',
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                status: status,
              );

              if (project == null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('projects')
                    .add(newProject.toMap());
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('projects')
                    .doc(project.id)
                    .update(newProject.toMap());
              }
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            child: const Text('Uložiť'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projekty'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'project_fab_unique',
        onPressed: () => _showAddProjectDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('projects')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/nesti_organizing.png', height: 150),
                  const SizedBox(height: 16),
                  const Text('Zatiaľ nemáš žiadne projekty.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final project = ProjectModel.fromFirestore(snapshot.data!.docs[index]);

              Color statusColor;
              switch (project.status) {
                case 'Rozpracované':
                  statusColor = Colors.orange;
                  break;
                case 'Hotové':
                  statusColor = Colors.green;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    project.description.isNotEmpty ? project.description : 'Bez popisu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      project.status,
                      style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => _showAddProjectDialog(project),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Vymazať projekt?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
                          TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('projects')
                                  .doc(project.id)
                                  .delete();
                              Navigator.pop(context);
                            },
                            child: const Text('Vymazať', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
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
