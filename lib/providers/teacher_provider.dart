// lib/providers/teacher_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/teacher_model.dart';
import '../models/lecture_model.dart';
import '../models/study_material_model.dart';
import '../models/attendance_model.dart';
import 'auth_provider.dart';

// ── Current Teacher ──────────────────────────────────────────────────────────
final currentTeacherProvider = StreamProvider<TeacherModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return SupabaseService.instance.client
          .from('teachers')
          .stream(primaryKey: ['id'])
          .eq('id', user.uid)
          .map((rows) => rows.isNotEmpty ? TeacherModel.fromMap(rows.first, user.uid) : null);
    },
    loading: () => Stream.value(null),
    error:   (_, __) => Stream.value(null),
  );
});

// ── Teacher Lectures (all) ──────────────────────────────────────────────────
final teacherLecturesProvider = StreamProvider<List<LectureModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('lectures')
          .stream(primaryKey: ['id'])
          .eq('teacher_id', user.uid)
          .order('startTime', ascending: false)
          .limit(50)
          .map((rows) => rows.map((row) => LectureModel.fromMap(row, row['id'])).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Today's Lectures ─────────────────────────────────────────────────────────
final todayLecturesProvider = StreamProvider<List<LectureModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final now   = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end   = start.add(const Duration(days: 1));
      
      return SupabaseService.instance.client
          .from('lectures')
          .stream(primaryKey: ['id'])
          .eq('teacher_id', user.uid)
          .order('startTime', ascending: true)
          .map((rows) {
            return rows.map((row) => LectureModel.fromMap(row, row['id']))
                .where((l) => (l.startTime.isAfter(start) || l.startTime.isAtSameMomentAs(start)) && l.startTime.isBefore(end))
                .toList();
          });
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Teacher Materials ─────────────────────────────────────────────────────────
final teacherMaterialsProvider = StreamProvider<List<StudyMaterialModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('study_materials')
          .stream(primaryKey: ['id'])
          .eq('uploaded_by', user.uid)
          .order('uploadedAt', ascending: false)
          .map((rows) => rows.map((row) => StudyMaterialModel.fromMap(row, row['id'])).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── All Teachers (admin use) ──────────────────────────────────────────────────
final allTeachersProvider = StreamProvider<List<TeacherModel>>((ref) {
  return SupabaseService.instance.client
      .from('teachers')
      .stream(primaryKey: ['id'])
      .order('name', ascending: true)
      .map((rows) => rows.map((row) => TeacherModel.fromMap(row, row['id'])).toList());
});

// ── Attendance for a lecture ──────────────────────────────────────────────────
final lectureAttendanceProvider = StreamProvider.family<List<AttendanceModel>, String>((ref, lectureId) {
  return SupabaseService.instance.client
      .from('attendance')
      .stream(primaryKey: ['id'])
      .eq('lectureId', lectureId)
      .map((rows) => rows.map((row) => AttendanceModel.fromMap(row, row['id'])).toList());
});
