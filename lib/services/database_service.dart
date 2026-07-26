import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/material_model.dart';
import '../models/tool_model.dart';
import '../models/project_model.dart';
import '../models/event_model.dart';
import '../models/guide_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dynamický getter pre UID - vždy vráti aktuálne ID prihláseného používateľa
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Pomocná funkcia pre získanie referencie na dokument používateľa
  DocumentReference get userDoc {
    if (uid == null) {
      debugPrint('VAROVANIE: Pokus o prístup k DB bez prihláseného používateľa!');
    }
    return _db.collection('users').doc(uid ?? 'unauthenticated');
  }

  // --- POUŽÍVATEĽ & PREMIUM ---
  Stream<DocumentSnapshot> get userData => userDoc.snapshots();

  Stream<bool> get isPremium {
    return userDoc.snapshots().map((snap) {
      if (!snap.exists) return false;
      return (snap.data() as Map<String, dynamic>)['isPremium'] ?? false;
    });
  }

  Future<void> updatePremiumStatus(bool status) async {
    await userDoc.update({'isPremium': status});
  }

  // --- MATERIÁL & POMÔCKY ---
  Stream<List<MaterialModel>> get materials {
    return userDoc.collection('materials')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList());
  }

  Future<void> addMaterial(Map<String, dynamic> data) async {
    debugPrint('Pridávam materiál do: users/$uid/materials');
    await userDoc.collection('materials').add(data);
  }
  
  Future<void> updateMaterial(String id, Map<String, dynamic> data) async => await userDoc.collection('materials').doc(id).update(data);
  Future<void> deleteMaterial(String id) async => await userDoc.collection('materials').doc(id).delete();

  Stream<List<ToolModel>> get tools {
    return userDoc.collection('tools')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ToolModel.fromFirestore(doc)).toList());
  }

  Future<void> addTool(Map<String, dynamic> data) async => await userDoc.collection('tools').add(data);
  Future<void> updateTool(String id, Map<String, dynamic> data) async => await userDoc.collection('tools').doc(id).update(data);
  Future<void> deleteTool(String id) async => await userDoc.collection('tools').doc(id).delete();

  // --- PROJEKTY ---
  Stream<List<ProjectModel>> get projects {
    return userDoc.collection('projects')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Stream<List<ProjectModel>> get activeProjects {
    return userDoc.collection('projects')
      .where('status', whereIn: ['Vo výrobe', 'Príprava'])
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Future<void> addProject(Map<String, dynamic> data) async {
    debugPrint('Pridávam projekt do: users/$uid/projects');
    await userDoc.collection('projects').add(data);
  }
  
  Future<void> updateProject(String id, Map<String, dynamic> data) async => await userDoc.collection('projects').doc(id).update(data);
  Future<void> deleteProject(String id) async => await userDoc.collection('projects').doc(id).delete();

  // --- NÁVODY ---
  Stream<List<GuideModel>> get guides {
    return userDoc.collection('guides')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => GuideModel.fromFirestore(doc)).toList());
  }

  Future<void> addGuide(Map<String, dynamic> data) async => await userDoc.collection('guides').add(data);
  Future<void> updateGuide(String id, Map<String, dynamic> data) async => await userDoc.collection('guides').doc(id).update(data);
  Future<void> deleteGuide(String id) async => await userDoc.collection('guides').doc(id).delete();

  // --- UDALOSTI ---
  Stream<List<EventModel>> get events {
    return userDoc.collection('events')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<void> addEvent(Map<String, dynamic> data) async => await userDoc.collection('events').add(data);
  Future<void> updateEvent(String id, Map<String, dynamic> data) async => await userDoc.collection('events').doc(id).update(data);
  Future<void> deleteEvent(String id) async => await userDoc.collection('events').doc(id).delete();
}
