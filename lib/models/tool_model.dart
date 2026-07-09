import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.note,
    required this.location,
    this.updatedAt,
  });

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
