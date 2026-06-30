import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bjmvphdsgyslyurrvvnc.supabase.co',
    'sb_publishable_LR9ZhHo-yaUTzFy6j50ryA_GSXDOXpy',
  );

  final uid = '52dc6463-3504-457b-97ea-d27cd90284c2';

  final userData = {
    'id': uid,
    'email': 'thakaresakshi0987@gmail.com',
    'name': 'Sakshi Thakare',
    'role': 'student',
    'photo_url': null,
    'phone': null,
    'fcmToken': null,
    'isActive': true,
    'created_at': DateTime.now().toIso8601String(),
  };

  try {
    print('Testing upsert on users...');
    await supabase.from('users').upsert(userData);
    print('Success users!');
  } catch (e) {
    print('Failed users: $e');
  }

  final studentData = {
    'id': uid,
    'name': 'Sakshi Thakare',
    'email': 'thakaresakshi0987@gmail.com',
    'student_id': 'STU-999999',
    'phone': null,
    'photo_url': null,
    'batch_id': null,
    'batch_name': null,
    'course': null,
    'address': null,
    'parentName': null,
    'parentPhone': null,
    'education': null,
    'attendancePercent': 0.0,
    'achievements': [],
    'isActive': true,
    'enrolledAt': DateTime.now().toIso8601String(),
    'role': 'student',
  };

  try {
    print('Testing upsert on students...');
    await supabase.from('students').upsert(studentData);
    print('Success students!');
  } catch (e) {
    print('Failed students: $e');
  }
}
