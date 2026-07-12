import 'package:cloud_firestore/cloud_firestore.dart';

class GuideModel {
  final String id;
  final String title;
  final String category;
  final String fileUrl;
  final String fileType; // 'image' or 'pdf'
  final String note;
  final DateTime? updatedAt;

  GuideModel({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    required this.fileType,
    this.note = '',
    this.updatedAt,
  });

  factory GuideModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GuideModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileType: data['fileType'] ?? 'image',
      note: data['note'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'note': note,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
