import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  /// Nahrá obrázok do priečinka projektu daného používateľa a vráti URL adresu.
  Future<String> uploadProjectImage(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage
        .ref()
        .child('users')
        .child(_uid)
        .child('projects')
        .child(fileName);

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Voliteľné: Zmaže obrázok zo storage (ak by si chcela šetriť miesto).
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Chyba pri mazaní obrázka: $e');
    }
  }
}
