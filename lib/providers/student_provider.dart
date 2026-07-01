// lib/providers/student_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/student_model.dart';
import '../models/fee_model.dart';
import '../models/attendance_model.dart';
import '../models/study_material_model.dart';
import '../models/notification_model.dart';
import '../models/result_model.dart';
import '../models/announcement_model.dart';
import 'auth_provider.dart';

// ── Current Student ───────────────────────────────────────────────────────
final currentStudentProvider = StreamProvider<StudentModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return SupabaseService.instance.client
          .from('students')
          .stream(primaryKey: ['id'])
          .eq('id', user.uid)
          .map((rows) => rows.isNotEmpty
              ? StudentModel.fromMap(rows.first, user.uid)
              : null);
    },
    loading: () => Stream.value(null),
    error:   (_, __) => Stream.value(null),
  );
});

// ── Student Fee ────────────────────────────────────────────────────────────
final studentFeeProvider = StreamProvider<FeeModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return SupabaseService.instance.client
          .from('fees')
          .stream(primaryKey: ['id'])
          .eq('student_id', user.uid)
          .limit(1)
          .map((rows) => rows.isNotEmpty
              ? FeeModel.fromMap(rows.first, rows.first['id'])
              : null);
    },
    loading: () => Stream.value(null),
    error:   (_, __) => Stream.value(null),
  );
});

// ── Student Installments ───────────────────────────────────────────────────
final studentInstallmentsProvider = StreamProvider<List<InstallmentModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('installments')
          .stream(primaryKey: ['id'])
          .eq('student_id', user.uid)
          .order('installmentNo')
          .map((rows) => rows.map((row) => InstallmentModel.fromMap(row, row['id'])).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Student Attendance ─────────────────────────────────────────────────────
final studentAttendanceProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('attendance')
          .stream(primaryKey: ['id'])
          .eq('student_id', user.uid)
          .order('date', ascending: false)
          .limit(60)
          .map((rows) => rows.map((row) => AttendanceModel.fromMap(row, row['id'])).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Study Materials ────────────────────────────────────────────────────────
final studyMaterialsProvider = StreamProvider.family<List<StudyMaterialModel>, String?>((ref, batchId) {
  final stream = SupabaseService.instance.client
      .from('study_materials')
      .stream(primaryKey: ['id']);
  
  if (batchId != null) {
    return stream
        .eq('batch_id', batchId)
        .order('uploadedAt', ascending: false)
        .limit(50)
        .map((rows) => rows.map((row) => StudyMaterialModel.fromMap(row)).toList());
  }
  
  return stream
      .order('uploadedAt', ascending: false)
      .limit(50)
      .map((rows) => rows.map((row) => StudyMaterialModel.fromMap(row)).toList());
});

// ── Notifications ──────────────────────────────────────────────────────────
final studentNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('notifications')
          .stream(primaryKey: ['id'])
          // Note: Realtime stream filters don't support .or() yet in the same way as select().
          // For now, fetch all related to student or specifically targeted, filtering client-side if needed
          .eq('targetUid', user.uid) // Simplified for realtime constraint, ideally uses postgres RLS
          .order('created_at', ascending: false)
          .limit(30)
          .map((rows) => rows.map((row) => NotificationModel.fromMap(row)).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Results ────────────────────────────────────────────────────────────────
final studentResultsProvider = StreamProvider<List<ResultModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return SupabaseService.instance.client
          .from('results')
          .stream(primaryKey: ['id'])
          .eq('student_id', user.uid)
          .order('examDate', ascending: false)
          .map((rows) => rows.map((row) => ResultModel.fromMap(row, row['id'])).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Announcements ──────────────────────────────────────────────────────────
final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return SupabaseService.instance.client
      .from('announcements')
      .stream(primaryKey: ['id'])
      .order('isPinned', ascending: false)
      .order('created_at', ascending: false)
      .limit(20)
      .map((rows) => rows.map((row) => AnnouncementModel.fromMap(row)).toList());
});

// ── All Students (admin use) ───────────────────────────────────────────────
final allStudentsProvider = StreamProvider<List<StudentModel>>((ref) {
  return SupabaseService.instance.client
      .from('students')
      .stream(primaryKey: ['id'])
      .order('name', ascending: true)
      .map((rows) => rows.map((row) => StudentModel.fromMap(row, row['id'])).toList());
});
