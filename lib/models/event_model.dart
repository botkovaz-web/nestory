import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  // Mapa kde kľúč je názov veci a hodnota je mapa {'taken': int, 'sold': int}
  final Map<String, Map<String, int>> inventory; 
  final double sales;
  final double expenses;
  final DateTime date;
  final String type;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    this.location = '',
    this.inventory = const {},
    this.sales = 0.0,
    this.expenses = 0.0,
    required this.date,
    required this.type,
    this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    // Konverzia dynamickej mapy z Firestore na typovanú mapu
    Map<String, Map<String, int>> typedInventory = {};
    if (data['inventory'] != null) {
      (data['inventory'] as Map).forEach((key, value) {
        typedInventory[key] = {
          'taken': value['taken'] ?? 0,
          'sold': value['sold'] ?? 0,
        };
      });
    }

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      inventory: typedInventory,
      sales: (data['sales'] ?? 0.0).toDouble(),
      expenses: (data['expenses'] ?? 0.0).toDouble(),
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
      'inventory': inventory,
      'sales': sales,
      'expenses': expenses,
      'date': Timestamp.fromDate(date),
      'type': type,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
