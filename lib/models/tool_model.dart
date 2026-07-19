import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class ToolModel {
  final String id;
  final String name;
  final String category;
  final String condition;
  final String note;
  final String location;
  final DateTime? updatedAt;

  ToolModel({
    required this.id,
    required this.name,
    required this.category,
    required this.condition,
    this.note = '',
    this.location = '',
    this.updatedAt,
  });

  String getLocalizedCategory(AppLocalizations l10n) {
    switch (category) {
      case 'Stroje': return l10n.catMachines;
      case 'Ručné náradie': return l10n.catHandTools;
      case 'Meradlá': return l10n.catMeasuring;
      case 'Organizéry': return l10n.catOrganizers;
      case 'Iné': return l10n.catOther;
      default: return category;
    }
  }

  String getLocalizedCondition(AppLocalizations l10n) {
    switch (condition) {
      case 'Výborný': return l10n.condExcellent;
      case 'Potrebuje údržbu': return l10n.condMaintenance;
      case 'Nefunkčný': return l10n.condBroken;
      default: return condition;
    }
  }

  factory ToolModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ToolModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      condition: data['condition'] ?? 'Výborný',
      note: data['note'] ?? '',
      location: data['location'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'condition': condition,
      'note': note,
      'location': location,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
