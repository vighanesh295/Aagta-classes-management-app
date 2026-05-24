// lib/providers/admin_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firebase_service.dart';
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

  final _fb = FirebaseService.instance;

  // ── Create Student ──────────────────────────────────────────────────────────
  Future<void> createStudent(StudentModel student) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.students.doc(student.uid).set(student.toMap());
      await _fb.users.doc(student.uid).set(student.toMap(), SetOptions(merge: true));
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Update Student ──────────────────────────────────────────────────────────
  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.students.doc(uid).update(data);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Delete Student ──────────────────────────────────────────────────────────
  Future<void> deleteStudent(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.students.doc(uid).delete();
      await _fb.users.doc(uid).delete();
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Create Teacher ──────────────────────────────────────────────────────────
  Future<void> createTeacher(TeacherModel teacher) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.teachers.doc(teacher.uid).set(teacher.toMap());
      await _fb.users.doc(teacher.uid).set(teacher.toMap(), SetOptions(merge: true));
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Schedule Lecture ────────────────────────────────────────────────────────
  Future<void> scheduleLecture(LectureModel lecture) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.lectures.add(lecture.toMap());
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Create Announcement ─────────────────────────────────────────────────────
  Future<void> createAnnouncement(AnnouncementModel ann) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.announcements.add(ann.toMap());
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Update Fee ──────────────────────────────────────────────────────────────
  Future<void> updateFeePayment(String feeId, double newPaidAmount) async {
    state = state.copyWith(isLoading: true);
    try {
      await _fb.fees.doc(feeId).update({
        'paidAmount': newPaidAmount,
        'updatedAt':  Timestamp.now(),
      });
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
  return FirebaseService.instance.lectures
      .orderBy('startTime', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map(LectureModel.fromDoc).toList());
});

// ── All Announcements (admin) ─────────────────────────────────────────────────
final allAnnouncementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return FirebaseService.instance.announcements
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(AnnouncementModel.fromDoc).toList());
});
