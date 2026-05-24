// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Upload File ─────────────────────────────────────────────────────────────
  Future<String?> uploadFile({
    required File file,
    required String path,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final ref   = _storage.ref(path);
      final task  = ref.putFile(file);

      task.snapshotEvents.listen((snap) {
        final progress = snap.bytesTransferred / snap.totalBytes;
        onProgress?.call(progress);
      });

      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.uploadFile error: $e');
      return null;
    }
  }

  // ── Upload Profile Image ────────────────────────────────────────────────────
  Future<String?> uploadProfileImage(File file, String uid) {
    return uploadFile(file: file, path: 'profiles/$uid/avatar.jpg');
  }

  // ── Upload Study Material ───────────────────────────────────────────────────
  Future<String?> uploadStudyMaterial(
    File file,
    String teacherId,
    String fileName, {
    ValueChanged<double>? onProgress,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return uploadFile(
      file: file,
      path: 'study_materials/$teacherId/${timestamp}_$fileName',
      onProgress: onProgress,
    );
  }

  // ── Delete File ─────────────────────────────────────────────────────────────
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('StorageService.deleteFile error: $e');
    }
  }

  // ── Get Download URL ────────────────────────────────────────────────────────
  Future<String?> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      debugPrint('StorageService.getDownloadUrl error: $e');
      return null;
    }
  }
}
