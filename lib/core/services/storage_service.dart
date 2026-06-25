// lib/core/services/storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final SupabaseStorageClient _storage = SupabaseService.instance.storage;

  // ── Upload File ─────────────────────────────────────────────────────────────
  Future<String?> uploadFile({
    required File file,
    required String path,
    required String bucket,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      // Supabase storage doesn't support stream progress upload natively in Dart yet
      // so we simulate or omit it. We just call uploadBinary.
      await _storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      return _storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('StorageService.uploadFile error: $e');
      return null;
    }
  }

  // ── Upload Profile Image ────────────────────────────────────────────────────
  Future<String?> uploadProfileImage(File file, String uid) {
    return uploadFile(file: file, path: '$uid/avatar.jpg', bucket: 'profile_images');
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
      path: '$teacherId/${timestamp}_$fileName',
      bucket: 'study_materials',
      onProgress: onProgress,
    );
  }

  // ── Delete File ─────────────────────────────────────────────────────────────
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _storage.from(bucket).remove([path]);
    } catch (e) {
      debugPrint('StorageService.deleteFile error: $e');
    }
  }
}
