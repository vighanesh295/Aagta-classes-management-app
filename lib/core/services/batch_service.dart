import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/batch_model.dart';
import '../../models/student_model.dart';

class BatchService {
  final _client = Supabase.instance.client;

  // Stream all batches realtime
  Stream<List<BatchModel>> watchAllBatches() {
    return _client
        .from('batches')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((data) => data.map(BatchModel.fromMap).toList());
  }

  // Stream active batches only
  Stream<List<BatchModel>> watchActiveBatches() {
    return _client
        .from('batches')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .order('name', ascending: true)
        .map((data) => data.map(BatchModel.fromMap).toList());
  }

  // Create new batch
  Future<void> createBatch(BatchModel batch) async {
    await _client.from('batches').insert(batch.toMap());
  }

  // Update batch
  Future<void> updateBatch(BatchModel batch) async {
    await _client.from('batches')
        .update(batch.toMap())
        .eq('id', batch.id);
  }

  // Change batch status
  Future<void> updateStatus(String id, BatchStatus status) async {
    await _client.from('batches')
        .update({'status': status.name})
        .eq('id', id);
  }

  // Delete batch (only if no active students assigned)
  Future<void> deleteBatch(String id, String batchName) async {
    final students = await _client
        .from('students')
        .select('id')
        .eq('batch', batchName)
        .eq('is_active', true);
    if (students.isNotEmpty) {
      throw Exception(
        'Cannot delete batch with ${students.length} active students. Move or deactivate them first.'
      );
    }
    await _client.from('batches').delete().eq('id', id);
  }

  // Get all students in a batch
  Future<List<StudentModel>> fetchStudentsInBatch(String batchName) async {
    final data = await _client
        .from('students')
        .select()
        .eq('batch', batchName)
        .order('name', ascending: true);
    return data.map(StudentModel.fromMap).toList();
  }

  // Move student to a different batch
  Future<void> moveStudentToBatch({
    required String studentId,
    required String newBatchName,
  }) async {
    await _client.from('students')
        .update({'batch': newBatchName})
        .eq('id', studentId);
    await _client.from('users')
        .update({'batch': newBatchName})
        .eq('id', studentId);
  }

  // Fetch all teachers for assignment dropdown
  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    final data = await _client
        .from('teachers')
        .select('id, name')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }
}
