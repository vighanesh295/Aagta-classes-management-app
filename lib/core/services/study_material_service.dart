import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/study_material_model.dart';

class StudyMaterialService {
  final _client = Supabase.instance.client;

  // Stream materials for a specific batch — realtime
  Stream<List<StudyMaterialModel>> watchMaterials(String batch) {
    return _client
        .from('study_materials')
        .stream(primaryKey: ['id'])
        .eq('batch', batch)
        .order('created_at', ascending: false)
        .map((data) => data.map(StudyMaterialModel.fromMap).toList());
  }

  // Admin/Teacher: stream all materials across all batches
  Stream<List<StudyMaterialModel>> watchAllMaterials() {
    return _client
        .from('study_materials')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map(StudyMaterialModel.fromMap).toList());
  }

  // Upload file to Supabase Storage and insert record
  Future<void> uploadMaterial({
    required String title,
    String? description,
    String? subject,
    required String batch,
    required File file,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String uploaderName,
    required String uploaderRole,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final ext = fileName.split('.').last;
    final path = '$batch/${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // Upload to storage
    await _client.storage.from('study-materials').upload(path, file);
    final fileUrl = _client.storage.from('study-materials').getPublicUrl(path);

    // Insert record
    await _client.from('study_materials').insert({
      'title': title,
      'description': description,
      'subject': subject,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'file_type': fileType,
      'uploaded_by': userId,
      'uploader_name': uploaderName,
      'uploader_role': uploaderRole,
      'batch': batch,
    });

    // Send announcement notification for new material
    await _client.from('announcements').insert({
      'title': 'New Study Material: $title',
      'body': '${uploaderRole == 'teacher' ? uploaderName : 'Admin'} uploaded new material for your batch.',
      'created_by': userId,
      'creator_name': uploaderName,
      'creator_role': uploaderRole,
      'target': 'batch',
      'batch': batch,
    });
  }

  // Download signed URL (for private bucket)
  Future<String> getDownloadUrl(String fileUrl) async {
    // Extract path from URL and create signed URL valid for 60 seconds
    final path = fileUrl.split('study-materials/').last;
    final response = await _client.storage
        .from('study-materials')
        .createSignedUrl(path, 60);
    return response;
  }

  // Increment download count
  Future<void> incrementDownload(String materialId) async {
    await _client.rpc('increment_download_count', params: {'material_id': materialId});
  }

  // Delete material (uploader or admin only)
  Future<void> deleteMaterial(String id, String fileUrl) async {
    final path = fileUrl.split('study-materials/').last;
    await _client.storage.from('study-materials').remove([path]);
    await _client.from('study_materials').delete().eq('id', id);
  }
}
