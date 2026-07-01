// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/lecture_model.dart';
import '../models/announcement_model.dart';

// ── Admin Notifier (CRUD operations) ─────────────────────────────────────────
class AdminState {
  final bool    isLoading;
  final String? error;
  final bool    success;

  const AdminState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AdminState copyWith({
    bool? isLoading, String? error, bool? success,
  }) => AdminState(
    isLoading: isLoading ?? this.isLoading,
    error:     error,
    success:   success   ?? this.success,
  );
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  final _supabase = SupabaseService.instance;

  // ── Create Student ──────────────────────────────────────────────────────────
  Future<void> createStudent(StudentModel student) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.setDoc('students', student.uid, student.toMap());
      await _supabase.setDoc('users', student.uid, student.toMap());
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Update Student ──────────────────────────────────────────────────────────
  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.updateDoc('students', uid, data);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Delete Student ──────────────────────────────────────────────────────────
  Future<void> deleteStudent(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.deleteDoc('students', uid);
      await _supabase.deleteDoc('users', uid);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Create Teacher ──────────────────────────────────────────────────────────
  Future<void> createTeacher(TeacherModel teacher) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.setDoc('teachers', teacher.uid, teacher.toMap());
      await _supabase.setDoc('users', teacher.uid, teacher.toMap());
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Schedule Lecture ────────────────────────────────────────────────────────
  Future<void> scheduleLecture(LectureModel lecture) async {
    state = state.copyWith(isLoading: true);
    try {
      final map = lecture.toMap();
      map.remove('id'); // Let DB auto-generate UUID or we pass it
      await _supabase.client.from('lectures').insert(map);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Create Announcement ─────────────────────────────────────────────────────
  Future<void> createAnnouncement(AnnouncementModel ann) async {
    state = state.copyWith(isLoading: true);
    try {
      final map = ann.toMap();
      map.remove('id');
      await _supabase.client.from('announcements').insert(map);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Update Fee ──────────────────────────────────────────────────────────────
  Future<void> updateFeePayment(String feeId, double newPaidAmount) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.client.from('fees').update({
        'paidAmount': newPaidAmount,
        'updated_at':  DateTime.now().toIso8601String(),
      }).eq('id', feeId);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearStatus() => state = const AdminState();
}

final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) => AdminNotifier());

// ── All Lectures (admin) ──────────────────────────────────────────────────────
final allLecturesProvider = StreamProvider<List<LectureModel>>((ref) {
  return SupabaseService.instance.client
      .from('lectures')
      .stream(primaryKey: ['id'])
      .order('startTime', ascending: false)
      .limit(100)
      .map((rows) => rows.map((row) => LectureModel.fromMap(row, row['id'])).toList());
});

// ── All Announcements (admin) ─────────────────────────────────────────────────
final allAnnouncementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return SupabaseService.instance.client
      .from('announcements')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) => rows.map((row) => AnnouncementModel.fromMap(row)).toList());
});
