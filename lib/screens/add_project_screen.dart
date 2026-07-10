import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/project_model.dart';
import '../models/order_model.dart';
import '../models/material_model.dart';
import '../models/tool_model.dart';

class AddProjectScreen extends StatefulWidget {
  final ProjectModel? project;
  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _status = 'V pláne';
  bool _isForOrder = false;
  String? _selectedOrderId;
  DateTime? _deadline;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  List<String> _selectedMaterials = [];
  List<String> _selectedTools = [];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _status = widget.project!.status;
      _isForOrder = widget.project!.isForOrder;
      _selectedOrderId = widget.project!.orderId;
      _deadline = widget.project!.deadline;
      _imageUrl = widget.project!.imageUrl;
      _selectedMaterials = List.from(widget.project!.requiredMaterials);
      _selectedTools = List.from(widget.project!.requiredTools);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_imageFile == null) return _imageUrl;
    
    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(userId)
        .child('projects')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final uploadedUrl = await _uploadImage(user.uid);
      
      final projectData = ProjectModel(
        id: widget.project?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        isForOrder: _isForOrder,
        orderId: _isForOrder ? _selectedOrderId : null,
        deadline: _deadline,
        imageUrl: uploadedUrl,
        requiredMaterials: _selectedMaterials,
        requiredTools: _selectedTools,
      ).toMap();

      if (widget.project == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .add(projectData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .doc(widget.project!.id)
            .update(projectData);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba pri ukladaní: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'Nový projekt' : 'Upraviť projekt'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.accent)))
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProject),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : (_imageUrl != null
                          ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                          : null),
                ),
                child: _imageFile == null && _imageUrl == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          Text('Pridať fotku', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Názov projektu *'),
              validator: (val) => val == null || val.isEmpty ? 'Zadajte názov' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Popis / Poznámky'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Stav projektu'),
              items: ['V pláne', 'Príprava', 'Vo výrobe', 'Hotovo']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 24),
            
            // Order Link
            SwitchListTile(
              title: const Text('Na objednávku?'),
              value: _isForOrder,
              activeColor: AppColors.accent,
              onChanged: (val) => setState(() => _isForOrder = val),
            ),
            if (_isForOrder)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('orders')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final orders = snapshot.data!.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedOrderId,
                    decoration: const InputDecoration(labelText: 'Priradiť k objednávke'),
                    items: orders.map((o) => DropdownMenuItem(
                      value: o.id,
                      child: Text('${o.customerName} - ${o.productName}'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedOrderId = val),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            ListTile(
              title: Text(_deadline == null 
                ? 'Termín dokončenia' 
                : 'Termín: ${DateFormat('dd.MM.yyyy').format(_deadline!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),

            const Divider(height: 40),
            
            // Material Selection (Simplified)
            _buildSelectionSection(
              title: 'Potrebný materiál',
              selectedItems: _selectedMaterials,
              collectionName: 'materials',
              onChanged: (newList) => setState(() => _selectedMaterials = newList),
            ),
            
            const SizedBox(height: 16),
            
            // Tool Selection (Simplified)
            _buildSelectionSection(
              title: 'Potrebné pomôcky',
              selectedItems: _selectedTools,
              collectionName: 'tools',
              onChanged: (newList) => setState(() => _selectedTools = newList),
            ),
            
            const SizedBox(height: 100), // Space for FAB or just padding
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection({
    required String title,
    required List<String> selectedItems,
    required String collectionName,
    required Function(List<String>) onChanged,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection(collectionName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final allItems = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
            
            return Wrap(
              spacing: 8,
              children: allItems.map((name) {
                final isSelected = selectedItems.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> newList = List.from(selectedItems);
                    if (selected) {
                      newList.add(name);
                    } else {
                      newList.remove(name);
                    }
                    onChanged(newList);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
