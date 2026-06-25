// lib/providers/fee_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
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
  final supabase = SupabaseService.instance.client;
  return supabase.from('fees').stream(primaryKey: ['id']).asyncMap((feesRows) async {
    final studentsRes = await supabase.from('students').select('id').count();
    final teachersRes = await supabase.from('teachers').select('id').count();

    double collected = 0;
    double pending   = 0;
    final now        = DateTime.now();
    double monthly   = 0;

    for (final row in feesRows) {
      final fee = FeeModel.fromMap(row, row['id']);
      collected += fee.paidAmount;
      pending   += fee.remaining;
      if (fee.updatedAt.month == now.month && fee.updatedAt.year == now.year) {
        monthly += fee.paidAmount;
      }
    }

    return AdminStats(
      totalStudents:      studentsRes.count,
      totalTeachers:      teachersRes.count,
      totalFeesCollected: collected,
      totalPendingFees:   pending,
      monthlyRevenue:     monthly,
    );
  });
});

// ── All Fees (admin) ──────────────────────────────────────────────────────────
final allFeesProvider = StreamProvider<List<FeeModel>>((ref) {
  return SupabaseService.instance.client
      .from('fees')
      .stream(primaryKey: ['id'])
      .order('updated_at', ascending: false)
      .map((rows) => rows.map((row) => FeeModel.fromMap(row, row['id'])).toList());
});

// ── All Installments (admin) ──────────────────────────────────────────────────
final allInstallmentsProvider = StreamProvider<List<InstallmentModel>>((ref) {
  return SupabaseService.instance.client
      .from('installments')
      .stream(primaryKey: ['id'])
      .order('dueDate', ascending: true)
      .map((rows) => rows.map((row) => InstallmentModel.fromMap(row, row['id'])).toList());
});

// ── Student fee by studentId (admin) ─────────────────────────────────────────
final studentFeeByIdProvider = StreamProvider.family<FeeModel?, String>((ref, studentId) {
  return SupabaseService.instance.client
      .from('fees')
      .stream(primaryKey: ['id'])
      .eq('student_id', studentId)
      .limit(1)
      .map((rows) => rows.isNotEmpty ? FeeModel.fromMap(rows.first, rows.first['id']) : null);
});
