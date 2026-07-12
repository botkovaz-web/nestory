import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final List<String> inventoryItems; // List of material/product names or IDs
  final DateTime date;
  final String type; // 'event' (e.g. market), 'deadline' (from order/project)
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    this.location = '',
    this.inventoryItems = const [],
    required this.date,
    required this.type,
    this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      inventoryItems: List<String>.from(data['inventoryItems'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'event',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'inventoryItems': inventoryItems,
      'date': Timestamp.fromDate(date),
      'type': type,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
