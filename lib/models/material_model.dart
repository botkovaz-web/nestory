import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String location;
  final DateTime? updatedAt;

  MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.location,
    this.updatedAt,
  });

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MaterialModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'ks',
      location: data['location'] ?? '',
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
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
