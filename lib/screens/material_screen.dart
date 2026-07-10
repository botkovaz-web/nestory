import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_colors.dart';
import '../models/material_model.dart';
import '../l10n/app_localizations.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final user = FirebaseAuth.instance.currentUser;

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
    final nameController = TextEditingController(text: material != null ? material.name : '');
    final quantityController = TextEditingController(text: material != null ? material.quantity.toString() : '');
    final locationController = TextEditingController(text: material != null ? material.location : '');
    String category = material != null ? material.category : 'Priadze';
    String unit = material != null ? material.unit : 'ks';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(material == null ? '${l10n.add} ${l10n.material.toLowerCase()}' : '${l10n.edit} ${l10n.material.toLowerCase()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.name),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: [
                  DropdownMenuItem(value: 'Priadze', child: Text(l10n.catYarns)),
                  DropdownMenuItem(value: 'Korálky', child: Text(l10n.catBeads)),
                  DropdownMenuItem(value: 'Papiere', child: Text(l10n.catPapers)),
                  DropdownMenuItem(value: 'Látky', child: Text(l10n.catFabrics)),
                  DropdownMenuItem(value: 'Iné', child: Text(l10n.catOther)),
                ],
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: l10n.quantity),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: unit,
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(value: 'ks', child: Text(l10n.unitPcs)),
                        DropdownMenuItem(value: 'g', child: Text(l10n.unitGrams)),
                        DropdownMenuItem(value: 'kg', child: Text(l10n.unitKg)),
                        DropdownMenuItem(value: 'm', child: Text(l10n.unitMeters)),
                        DropdownMenuItem(value: 'klbka', child: Text(l10n.unitBalls)),
                        DropdownMenuItem(value: 'hárky', child: Text(l10n.unitSheets)),
                        DropdownMenuItem(value: 'balenia', child: Text(l10n.unitPacks)),
                      ],
                      onChanged: (val) => unit = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: l10n.location),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.material),
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
                  Text(l10n.noMaterial,
                      style: const TextStyle(color: Colors.grey)),
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
                      Text(_getLocalizedCategory(context, material.category)),
                      if (material.location.isNotEmpty)
                        Text('📍 ${material.location}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${material.quantity} ${_getLocalizedUnit(context, material.unit)}',
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
