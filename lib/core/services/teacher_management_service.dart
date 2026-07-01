import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/teacher_model.dart';

class TeacherManagementService {
  final _client = Supabase.instance.client;

  // Stream all teachers with their batch assignments
  Stream<List<TeacherModel>> watchAllTeachers() {
    return _client
        .from('teachers')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .asyncMap((rows) async {
          // For each teacher fetch their batch assignments
          final teachers = <TeacherModel>[];
          for (final row in rows) {
            final assignments = await _client
                .from('teacher_batch_assignments')
                .select('batch_name')
                .eq('teacher_id', row['id']);
            final batches = assignments
                .map((a) => a['batch_name'] as String)
                .toList();
            teachers.add(TeacherModel.fromMap({...row, 'assigned_batches': batches}));
          }
          return teachers;
        });
  }

  // Invite new teacher via Edge Function
  Future<void> inviteTeacher({
    required String name,
    required String email,
    String? phone,
    String? subject,
    String? qualification,
    int experienceYears = 0,
    String? address,
    DateTime? joiningDate,
    double salary = 0,
  }) async {
    final response = await _client.functions.invoke('invite-teacher', body: {
      'email': email,
      'name': name,
      'phone': phone,
      'subject': subject,
      'qualification': qualification,
      'experience_years': experienceYears,
      'address': address,
      'joining_date': joiningDate?.toIso8601String(),
      'salary': salary,
    });
    if (response.status != 200) throw Exception('Failed to invite teacher');
  }

  // Update teacher profile
  Future<void> updateTeacher(TeacherModel teacher) async {
    await _client.from('teachers')
        .update(teacher.toMap())
        .eq('id', teacher.id);
    await _client.from('users').update({
      'name': teacher.name,
      'phone': teacher.phone,
    }).eq('id', teacher.id);
  }

  // Assign teacher to a batch
  Future<void> assignToBatch({
    required String teacherId,
    required String batchId,
    required String batchName,
    required String teacherName,
  }) async {
    await _client.from('teacher_batch_assignments').upsert({
      'teacher_id': teacherId,
      'batch_id': batchId,
      'batch_name': batchName,
    });
    // Update batch teacher info
    await _client.from('batches').update({
      'teacher_id': teacherId,
      'teacher_name': teacherName,
    }).eq('id', batchId);
  }

  // Remove teacher from a batch
  Future<void> removeFromBatch({
    required String teacherId,
    required String batchId,
  }) async {
    await _client.from('teacher_batch_assignments')
        .delete()
        .eq('teacher_id', teacherId)
        .eq('batch_id', batchId);
    // Clear batch teacher info if this teacher was assigned
    await _client.from('batches').update({
      'teacher_id': null,
      'teacher_name': null,
    }).eq('id', batchId).eq('teacher_id', teacherId);
  }

  // Upload teacher photo
  Future<String> uploadTeacherPhoto(String teacherId, File photo) async {
    final path = 'teachers/$teacherId.jpg';
    await _client.storage.from('avatars').upload(path, photo,
        fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  // Deactivate teacher
  Future<void> deactivateTeacher(String id) async {
    await _client.from('teachers')
        .update({'is_active': false}).eq('id', id);
  }

  // Reactivate teacher
  Future<void> reactivateTeacher(String id) async {
    await _client.from('teachers')
        .update({'is_active': true}).eq('id', id);
  }

  // Delete teacher (hard delete with confirmation)
  Future<void> deleteTeacher(String id) async {
    await _client.from('teacher_batch_assignments')
        .delete().eq('teacher_id', id);
    await _client.from('teachers').delete().eq('id', id);
    await _client.from('users').delete().eq('id', id);
  }

  // Fetch all active batches for assignment dropdown
  Future<List<Map<String, dynamic>>> fetchActiveBatches() async {
    final data = await _client
        .from('batches')
        .select('id, name')
        .eq('status', 'active')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }
}
