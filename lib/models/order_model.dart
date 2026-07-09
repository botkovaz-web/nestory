import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String productName;
  final double price;
  final DateTime? deadline;
  final String status; // 'V poradí', 'V procese', 'Hotovo', 'Odoslané'
  final bool isPaid;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.price,
    this.deadline,
    required this.status,
    required this.isPaid,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'V poradí',
      isPaid: data['isPaid'] ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'productName': productName,
      'price': price,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status,
      'isPaid': isPaid,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
