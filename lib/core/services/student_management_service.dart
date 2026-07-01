import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/student_model.dart';

class StudentManagementService {
  final _client = Supabase.instance.client;

  // Stream all students — realtime, ordered by name
  Stream<List<StudentModel>> watchAllStudents() {
    return _client
        .from('students')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((data) => data.map(StudentModel.fromMap).toList());
  }

  // Stream students by batch
  Stream<List<StudentModel>> watchStudentsByBatch(String batch) {
    return _client
        .from('students')
        .stream(primaryKey: ['id'])
        .eq('batch', batch)
        .order('name', ascending: true)
        .map((data) => data.map(StudentModel.fromMap).toList());
  }

  // Invite new student — calls Edge Function
  Future<void> inviteStudent({
    required String name,
    required String email,
    required String batch,
    String? phone,
    String? rollNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
  }) async {
    // Call invite-student Edge Function
    final response = await _client.functions.invoke('invite-student', body: {
      'email': email,
      'name': name,
      'batch': batch,
      'phone': phone,
      'roll_number': rollNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
    });
    if (response.status != 200) throw Exception('Failed to invite student');
  }

  // Update existing student (no auth changes, just DB row)
  Future<void> updateStudent(StudentModel student) async {
    await _client
        .from('students')
        .update(student.toMap())
        .eq('id', student.id);
    // Also update users table name/phone/batch
    await _client.from('users').update({
      'name': student.name,
      'phone': student.phone,
      'batch': student.batch,
    }).eq('id', student.id);
  }

  // Soft delete — set is_active = false
  Future<void> deactivateStudent(String id) async {
    await _client
        .from('students')
        .update({'is_active': false}).eq('id', id);
  }

  // Reactivate student
  Future<void> reactivateStudent(String id) async {
    await _client
        .from('students')
        .update({'is_active': true}).eq('id', id);
  }

  // Hard delete (only if admin confirms twice)
  Future<void> deleteStudent(String id) async {
    await _client.from('students').delete().eq('id', id);
    await _client.from('users').delete().eq('id', id);
    // Note: Supabase auth user deletion requires service role — do it via Edge Function or manual admin.
  }

  // Upload student photo to Supabase Storage
  Future<String> uploadStudentPhoto(String studentId, File photo) async {
    final path = 'students/$studentId.jpg';
    await _client.storage.from('avatars').upload(path, photo,
        fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  // Fetch all unique batches (for filter dropdown)
  Future<List<String>> fetchBatches() async {
    final data = await _client
        .from('students')
        .select('batch')
        .not('batch', 'is', null);
    final batches = data
        .map((e) => e['batch'] as String)
        .toSet()
        .toList()
      ..sort();
    return batches;
  }
}
