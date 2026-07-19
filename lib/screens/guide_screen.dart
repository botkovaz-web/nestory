import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/guide_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../widgets/nestory_fab.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/detail_entry_dialog.dart';
import '../widgets/premium_paywall.dart';
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

  void _showDetailDialog(GuideModel guide) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => DetailEntryDialog(
        title: guide.title,
        onEdit: () {
          Navigator.pop(context);
          _showAddGuideDialog(guide);
        },
        onDelete: () => _dbService.deleteGuide(guide.id),
        children: [
          DetailEntryDialog.buildDetailRow(Icons.category_outlined, l10n.category, guide.category),
          if (guide.note.isNotEmpty)
            DetailEntryDialog.buildDetailRow(Icons.notes_outlined, l10n.note, guide.note),
          if (guide.updatedAt != null)
            DetailEntryDialog.buildDetailRow(Icons.history, 'Naposledy', DateFormat('dd.MM.yyyy HH:mm').format(guide.updatedAt!)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _viewGuide(guide);
            },
            icon: Icon(guide.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image),
            label: Text(guide.fileType == 'pdf' ? 'Otvoriť PDF návod' : 'Zobraziť fotku návodu'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddGuideDialog([GuideModel? guide]) async {
    final l10n = AppLocalizations.of(context)!;
    if (guide == null) {
      final isPremium = await _dbService.isPremium.first;
      final guides = await _dbService.guides.first;
      if (!isPremium && guides.length >= 2) {
        if (mounted) showPremiumPaywall(context);
        return;
      }
    }

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
              String finalFileType = fileType;
              if (pickedFile != null) {
                final extension = pickedFile!.path.split('.').last.toLowerCase();
                finalUrl = await _storageService.uploadGuideFile(pickedFile!, extension);
                finalFileType = (extension == 'pdf') ? 'pdf' : 'image';
              }

              final data = GuideModel(
                id: guide?.id ?? '',
                title: titleController.text.trim(),
                category: category,
                fileUrl: finalUrl,
                fileType: finalFileType,
                note: noteController.text.trim(),
              ).toMap();

              guide == null ? await _dbService.addGuide(data) : await _dbService.updateGuide(guide.id, data);
              if (mounted) Navigator.pop(context);
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
                items: ['Háčkovanie', 'Šitie', 'Pletenie', 'Šperky', 'Iné'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
                  if (result != null && result.files.single.path != null) {
                    setDialogState(() { pickedFile = File(result.files.single.path!); fileName = result.files.single.name; });
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(fileName ?? (currentUrl != null ? 'Zmeniť súbor' : 'Vybrať súbor (Foto/PDF)')),
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
      floatingActionButton: NestoryFAB(heroTag: 'guide_fab', onPressed: () => _showAddGuideDialog()),
      body: StreamBuilder<List<GuideModel>>(
        stream: _dbService.guides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return NestoryEmptyState(imagePath: 'assets/nesti_watching.png', message: l10n.noGuides);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final guide = snapshot.data![index];
              return NestoryCard(
                leading: Icon(guide.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: AppColors.accent),
                title: guide.title,
                subtitle: Text(guide.category),
                onTap: () => _showDetailDialog(guide),
              );
            },
          );
        },
      ),
    );
  }
}
