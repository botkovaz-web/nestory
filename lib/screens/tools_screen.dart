import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/tool_model.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  void _showAddToolDialog([ToolModel? tool]) {
    final nameController = TextEditingController(text: tool != null ? tool.name : '');
    final noteController = TextEditingController(text: tool != null ? tool.note : '');
    final locationController = TextEditingController(text: tool != null ? tool.location : '');
    String category = tool != null ? tool.category : 'Ručné náradie';
    String condition = tool != null ? tool.condition : 'Výborný';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tool == null ? 'Pridať pomôcku' : 'Upraviť pomôcku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Názov (napr. Šijací stroj)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategória'),
                items: ['Stroje', 'Ručné náradie', 'Meradlá', 'Organizéry', 'Iné']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: const InputDecoration(labelText: 'Stav'),
                items: ['Výborný', 'Potrebuje údržbu', 'Nefunkčný']
                    .map((cond) => DropdownMenuItem(value: cond, child: Text(cond)))
                    .toList(),
                onChanged: (val) => condition = val!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Umiestnenie (napr. Ateliér - skriňa)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Poznámka (voliteľné)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final newTool = ToolModel(
                id: tool?.id ?? '',
                name: nameController.text.trim(),
                category: category,
                condition: condition,
                note: noteController.text.trim(),
                location: locationController.text.trim(),
              );

              if (tool == null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('tools')
                    .add(newTool.toMap());
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('tools')
                    .doc(tool.id)
                    .update(newTool.toMap());
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
        title: const Text('Pomôcky'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tools_fab_unique', // Unikátny tag pre Pomôcky
        onPressed: () => _showAddToolDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('tools')
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
                  Image.asset('assets/nesti_watching.png', height: 150),
                  const SizedBox(height: 16),
                  const Text('Zatiaľ tu nemáš žiadne pomôcky.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final tool = ToolModel.fromFirestore(snapshot.data!.docs[index]);

              Color conditionColor;
              switch (tool.condition) {
                case 'Výborný':
                  conditionColor = Colors.green;
                  break;
                case 'Potrebuje údržbu':
                  conditionColor = Colors.orange;
                  break;
                case 'Nefunkčný':
                  conditionColor = Colors.red;
                  break;
                default:
                  conditionColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tool.category),
                      if (tool.location.isNotEmpty)
                        Text('📍 ${tool.location}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      if (tool.note.isNotEmpty)
                        Text(tool.note, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: conditionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: conditionColor),
                        ),
                        child: Text(
                          tool.condition,
                          style: TextStyle(fontSize: 12, color: conditionColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showAddToolDialog(tool),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('tools')
                            .doc(tool.id)
                            .delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
