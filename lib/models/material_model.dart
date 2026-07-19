import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class MaterialModel {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String location;
  final String note;
  final DateTime? updatedAt;

  MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.location,
    this.note = '',
    this.updatedAt,
  });

  String getLocalizedCategory(AppLocalizations l10n) {
    switch (category) {
      case 'Priadze': return l10n.catYarns;
      case 'Korálky': return l10n.catBeads;
      case 'Papiere': return l10n.catPapers;
      case 'Látky': return l10n.catFabrics;
      case 'Iné': return l10n.catOther;
      default: return category;
    }
  }

  String getLocalizedUnit(AppLocalizations l10n) {
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

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MaterialModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'ks',
      location: data['location'] ?? '',
      note: data['note'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'note': note,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
