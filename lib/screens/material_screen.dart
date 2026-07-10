import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/material_model.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final List<String> _units = ['ks', 'g', 'kg', 'm', 'klbka', 'hárky', 'balenia'];

  void _showAddMaterialDialog([MaterialModel? material]) {
    final nameController = TextEditingController(text: material != null ? material.name : '');
    final quantityController = TextEditingController(text: material != null ? material.quantity.toString() : '');
    final locationController = TextEditingController(text: material != null ? material.location : '');
    String category = material != null ? material.category : 'Priadze';
    String unit = material != null ? material.unit : 'ks';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(material == null ? 'Pridať materiál' : 'Upraviť materiál'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Názov (napr. Biela vlna)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategória'),
                items: ['Priadze', 'Korálky', 'Papiere', 'Látky', 'Iné']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Množstvo'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: unit,
                      decoration: const InputDecoration(
                        labelText: 'Jednotka',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (val) => unit = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Umiestnenie (napr. Polica A1)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zrušiť')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final newMaterial = MaterialModel(
                id: material?.id ?? '',
                name: nameController.text.trim(),
                category: category,
                quantity: double.tryParse(quantityController.text) ?? 0,
                unit: unit,
                location: locationController.text.trim(),
              );

              if (material == null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('materials')
                    .add(newMaterial.toMap());
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('materials')
                    .doc(material.id)
                    .update(newMaterial.toMap());
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
        title: const Text('Materiál'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'material_fab_unique',
        onPressed: () => _showAddMaterialDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('materials')
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
                  const Text('Zatiaľ tu nemáš žiadny materiál.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final material = MaterialModel.fromFirestore(snapshot.data!.docs[index]);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(material.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(material.category),
                      if (material.location.isNotEmpty)
                        Text('📍 ${material.location}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${material.quantity} ${material.unit}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showAddMaterialDialog(material),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('materials')
                            .doc(material.id)
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
