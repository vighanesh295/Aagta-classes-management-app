// lib/providers/teacher_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firebase_service.dart';
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
      return FirebaseService.instance.teachers
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? TeacherModel.fromDoc(doc) : null);
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
      return FirebaseService.instance.lectures
          .where('teacherId', isEqualTo: user.uid)
          .orderBy('startTime', descending: true)
          .limit(50)
          .snapshots()
          .map((snap) => snap.docs.map(LectureModel.fromDoc).toList());
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
      return FirebaseService.instance.lectures
          .where('teacherId', isEqualTo: user.uid)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime', isLessThan: Timestamp.fromDate(end))
          .orderBy('startTime')
          .snapshots()
          .map((snap) => snap.docs.map(LectureModel.fromDoc).toList());
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
      return FirebaseService.instance.studyMaterials
          .where('uploadedBy', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(StudyMaterialModel.fromDoc).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── All Teachers (admin use) ──────────────────────────────────────────────────
final allTeachersProvider = StreamProvider<List<TeacherModel>>((ref) {
  return FirebaseService.instance.teachers
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map(TeacherModel.fromDoc).toList());
});

// ── Attendance for a lecture ──────────────────────────────────────────────────
final lectureAttendanceProvider = StreamProvider.family<List<AttendanceModel>, String>((ref, lectureId) {
  return FirebaseService.instance.attendance
      .where('lectureId', isEqualTo: lectureId)
      .snapshots()
      .map((snap) => snap.docs.map(AttendanceModel.fromDoc).toList());
});
