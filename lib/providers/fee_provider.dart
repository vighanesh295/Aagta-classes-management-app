// lib/providers/fee_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/firebase_service.dart';
import '../models/fee_model.dart';

// ── Admin Stats ───────────────────────────────────────────────────────────────
class AdminStats {
  final int    totalStudents;
  final int    totalTeachers;
  final double totalFeesCollected;
  final double totalPendingFees;
  final double monthlyRevenue;

  const AdminStats({
    this.totalStudents     = 0,
    this.totalTeachers     = 0,
    this.totalFeesCollected = 0,
    this.totalPendingFees   = 0,
    this.monthlyRevenue     = 0,
  });
}

final adminStatsProvider = StreamProvider<AdminStats>((ref) {
  final fb = FirebaseService.instance;
  return fb.fees.snapshots().asyncMap((feesSnap) async {
    final students = await fb.students.count().get();
    final teachers = await fb.teachers.count().get();

    double collected = 0;
    double pending   = 0;
    final now        = DateTime.now();
    double monthly   = 0;

    for (final doc in feesSnap.docs) {
      final fee = FeeModel.fromDoc(doc);
      collected += fee.paidAmount;
      pending   += fee.remaining;
      if (fee.updatedAt.month == now.month && fee.updatedAt.year == now.year) {
        monthly += fee.paidAmount;
      }
    }

    return AdminStats(
      totalStudents:      students.count ?? 0,
      totalTeachers:      teachers.count ?? 0,
      totalFeesCollected: collected,
      totalPendingFees:   pending,
      monthlyRevenue:     monthly,
    );
  });
});

// ── All Fees (admin) ──────────────────────────────────────────────────────────
final allFeesProvider = StreamProvider<List<FeeModel>>((ref) {
  return FirebaseService.instance.fees
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(FeeModel.fromDoc).toList());
});

// ── All Installments (admin) ──────────────────────────────────────────────────
final allInstallmentsProvider = StreamProvider<List<InstallmentModel>>((ref) {
  return FirebaseService.instance.installments
      .orderBy('dueDate')
      .snapshots()
      .map((snap) => snap.docs.map(InstallmentModel.fromDoc).toList());
});

// ── Student fee by studentId (admin) ─────────────────────────────────────────
final studentFeeByIdProvider = StreamProvider.family<FeeModel?, String>((ref, studentId) {
  return FirebaseService.instance.fees
      .where('studentId', isEqualTo: studentId)
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isNotEmpty ? FeeModel.fromDoc(snap.docs.first) : null);
});
