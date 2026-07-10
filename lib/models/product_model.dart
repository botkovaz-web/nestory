import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> requiredMaterials; // Zoznam ID materiálov alebo názvov
  final List<String> requiredTools; // Zoznam ID pomôcok
  final String? orderId; // Prepojenie na konkrétnu objednávku
  final String status; // 'Nápad', 'Príprava', 'Vo výrobe', 'Hotovo'
  final DateTime? deadline;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    this.price = 0.0,
    this.imageUrl,
    this.requiredMaterials = const [],
    this.requiredTools = const [],
    this.orderId,
    required this.status,
    this.deadline,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      requiredMaterials: List<String>.from(data['requiredMaterials'] ?? []),
      requiredTools: List<String>.from(data['requiredTools'] ?? []),
      orderId: data['orderId'],
      status: data['status'] ?? 'Nápad',
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'requiredMaterials': requiredMaterials,
      'requiredTools': requiredTools,
      'orderId': orderId,
      'status': status,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
