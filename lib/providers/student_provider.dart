// lib/providers/student_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firebase_service.dart';
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
      return FirebaseService.instance.students
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists
              ? StudentModel.fromDoc(doc)
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
      return FirebaseService.instance.fees
          .where('studentId', isEqualTo: user.uid)
          .limit(1)
          .snapshots()
          .map((snap) => snap.docs.isNotEmpty
              ? FeeModel.fromDoc(snap.docs.first)
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
      return FirebaseService.instance.installments
          .where('studentId', isEqualTo: user.uid)
          .orderBy('installmentNo')
          .snapshots()
          .map((snap) => snap.docs.map(InstallmentModel.fromDoc).toList());
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
      return FirebaseService.instance.attendance
          .where('studentId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(60)
          .snapshots()
          .map((snap) => snap.docs.map(AttendanceModel.fromDoc).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Study Materials ────────────────────────────────────────────────────────
final studyMaterialsProvider = StreamProvider.family<List<StudyMaterialModel>, String?>((ref, batchId) {
  Query query = FirebaseService.instance.studyMaterials;
  if (batchId != null) query = query.where('batchId', isEqualTo: batchId);
  return query
      .orderBy('uploadedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map(StudyMaterialModel.fromDoc).toList());
});

// ── Notifications ──────────────────────────────────────────────────────────
final studentNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseService.instance.notifications
          .where(Filter.or(
            Filter('targetUid',  isEqualTo: user.uid),
            Filter('targetRole', isEqualTo: 'student'),
            Filter('targetRole', isEqualTo: null),
          ))
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots()
          .map((snap) => snap.docs.map(NotificationModel.fromDoc).toList());
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
      return FirebaseService.instance.results
          .where('studentId', isEqualTo: user.uid)
          .orderBy('examDate', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(ResultModel.fromDoc).toList());
    },
    loading: () => Stream.value([]),
    error:   (_, __) => Stream.value([]),
  );
});

// ── Announcements ──────────────────────────────────────────────────────────
final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return FirebaseService.instance.announcements
      .orderBy('isPinned', descending: true)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map(AnnouncementModel.fromDoc).toList());
});

// ── All Students (admin use) ───────────────────────────────────────────────
final allStudentsProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirebaseService.instance.students
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map(StudentModel.fromDoc).toList());
});
