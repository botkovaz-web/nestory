import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String status; // 'V pláne', 'Rozpracované', 'Hotové'
  final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.updatedAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'V pláne',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
