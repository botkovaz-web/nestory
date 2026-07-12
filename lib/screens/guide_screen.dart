import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as pk;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../app_colors.dart';
import '../models/guide_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _dbService = DatabaseService();
  final _storageService = StorageService();

  Future<void> _showAddGuideDialog([GuideModel? guide]) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: guide?.title ?? '');
    final noteController = TextEditingController(text: guide?.note ?? '');
    String category = guide?.category ?? 'Háčkovanie';
    
    File? pickedFile;
    String? fileName;
    String? currentUrl = guide?.fileUrl;
    String fileType = guide?.fileType ?? 'image';
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: guide == null ? '${l10n.add} návod' : '${l10n.edit} návod',
          isSaving: isSaving,
          onSave: () async {
            if (titleController.text.isEmpty || (pickedFile == null && currentUrl == null)) return;
            setDialogState(() => isSaving = true);
            
            try {
              String finalUrl = currentUrl ?? '';
              if (pickedFile != null) {
                final extension = pickedFile!.path.split('.').last.toLowerCase();
                finalUrl = await _storageService.uploadGuideFile(pickedFile!, extension);
                fileType = (extension == 'pdf') ? 'pdf' : 'image';
              }

              final data = GuideModel(
                id: guide?.id ?? '',
                title: titleController.text.trim(),
                category: category,
                fileUrl: finalUrl,
                fileType: fileType,
                note: noteController.text.trim(),
              ).toMap();

              if (guide == null) {
                await _dbService.addGuide(data);
              } else {
                await _dbService.updateGuide(guide.id, data);
              }
              if (mounted) Navigator.pop(context);
            } catch (e) {
              debugPrint('Chyba pri ukladaní návodu: $e');
            } finally {
              if (mounted) setDialogState(() => isSaving = false);
            }
          },
          content: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: l10n.category),
                items: ['Háčkovanie', 'Šitie', 'Pletenie', 'Šperky', 'Iné']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Using prefixed import to avoid any naming conflicts
                    final pk.FilePickerResult? result = await pk.FilePicker.platform.pickFiles(
                      type: pk.FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                    );
                    
                    if (result != null && result.files.single.path != null) {
                      setDialogState(() {
                        pickedFile = File(result.files.single.path!);
                        fileName = result.files.single.name;
                      });
                    }
                  } catch (e) {
                    debugPrint('FilePicker error: $e');
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(fileName ?? (currentUrl != null ? 'Súbor vybraný' : 'Vybrať súbor (Foto/PDF)')),
              ),
              const SizedBox(height: 16),
              TextField(controller: noteController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _viewGuide(GuideModel guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(guide.title), backgroundColor: Colors.transparent, elevation: 0),
          body: guide.fileType == 'pdf'
              ? SfPdfViewer.network(guide.fileUrl)
              : InteractiveViewer(child: Center(child: Image.network(guide.fileUrl))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.guides), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(
        heroTag: 'guide_fab',
        onPressed: () => _showAddGuideDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<GuideModel>>(
        stream: _dbService.guides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/nesti_watching.png', height: 120), const SizedBox(height: 16), Text(l10n.noGuides, style: const TextStyle(color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final guide = snapshot.data![index];
              return NestoryCard(
                leading: Icon(guide.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: AppColors.accent),
                title: guide.title,
                subtitle: Text(guide.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(l10n.deleteConfirmation),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.no)),
                          TextButton(
                            onPressed: () {
                              _dbService.deleteGuide(guide.id);
                              Navigator.pop(c);
                            },
                            child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () => _viewGuide(guide),
              );
            },
          );
        },
      ),
    );
  }
}
