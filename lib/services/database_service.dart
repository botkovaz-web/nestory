import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/material_model.dart';
import '../models/tool_model.dart';
import '../models/project_model.dart';
import '../models/event_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // --- POUŽÍVATEĽ ---
  Stream<DocumentSnapshot> get userData {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- MATERIÁL ---
  Stream<List<MaterialModel>> get materials {
    return _db.collection('users').doc(uid).collection('materials')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => MaterialModel.fromFirestore(doc)).toList());
  }

  Future<void> addMaterial(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('materials').add(data);
  }

  Future<void> updateMaterial(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('materials').doc(id).update(data);
  }

  Future<void> deleteMaterial(String id) async {
    await _db.collection('users').doc(uid).collection('materials').doc(id).delete();
  }

  // --- POMÔCKY ---
  Stream<List<ToolModel>> get tools {
    return _db.collection('users').doc(uid).collection('tools')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ToolModel.fromFirestore(doc)).toList());
  }

  Future<void> addTool(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('tools').add(data);
  }

  Future<void> updateTool(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('tools').doc(id).update(data);
  }

  Future<void> deleteTool(String id) async {
    await _db.collection('users').doc(uid).collection('tools').doc(id).delete();
  }

  // --- PROJEKTY ---
  Stream<List<ProjectModel>> get projects {
    return _db.collection('users').doc(uid).collection('projects')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Stream<List<ProjectModel>> get activeProjects {
    return _db.collection('users').doc(uid).collection('projects')
      .where('status', whereIn: ['Vo výrobe', 'Príprava'])
      .snapshots()
      .map((snap) => snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList());
  }

  Future<void> addProject(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('projects').add(data);
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('projects').doc(id).update(data);
  }

  Future<void> deleteProject(String id) async {
    await _db.collection('users').doc(uid).collection('projects').doc(id).delete();
  }

  // --- UDALOSTI ---
  Stream<List<EventModel>> get events {
    return _db.collection('users').doc(uid).collection('events')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<void> addEvent(Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('events').add(data);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).collection('events').doc(id).update(data);
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('users').doc(uid).collection('events').doc(id).delete();
  }
}
