import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final List<String> requiredMaterials;
  final List<String> requiredTools;
  final String status; // 'V pláne', 'Príprava', 'Vo výrobe', 'Hotovo'
  final DateTime? deadline;
  final String? imageUrl;
  final bool isForCustomer;
  final String? customerName;
  final double price;
  final bool isPaid;
  final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description = '',
    this.requiredMaterials = const [],
    this.requiredTools = const [],
    required this.status,
    this.deadline,
    this.imageUrl,
    this.isForCustomer = false,
    this.customerName,
    this.price = 0.0,
    this.isPaid = false,
    this.updatedAt,
  });

  String getLocalizedStatus(AppLocalizations l10n) {
    switch (status) {
      case 'V pláne': return l10n.statusPlanning;
      case 'Príprava': return l10n.statusPreparation;
      case 'Vo výrobe': return l10n.statusProduction;
      case 'Hotovo': return l10n.statusDone;
      default: return status;
    }
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      requiredMaterials: List<String>.from(data['requiredMaterials'] ?? []),
      requiredTools: List<String>.from(data['requiredTools'] ?? []),
      status: data['status'] ?? 'V pláne',
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'],
      isForCustomer: data['isForCustomer'] ?? false,
      customerName: data['customerName'],
      price: (data['price'] ?? 0.0).toDouble(),
      isPaid: data['isPaid'] ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'requiredMaterials': requiredMaterials,
      'requiredTools': requiredTools,
      'status': status,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'imageUrl': imageUrl,
      'isForCustomer': isForCustomer,
      'customerName': customerName,
      'price': price,
      'isPaid': isPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
