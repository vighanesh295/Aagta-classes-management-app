import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/analytics_service.dart';
import '../models/analytics_model.dart';

final analyticsServiceProvider = Provider((_) => AnalyticsService());

final overviewAnalyticsProvider = FutureProvider<OverviewAnalytics>((ref) {
  return ref.watch(analyticsServiceProvider).fetchOverview();
});

final feeAnalyticsProvider = FutureProvider<FeeAnalytics>((ref) {
  return ref.watch(analyticsServiceProvider).fetchFeeAnalytics();
});

final monthlyFeeProvider = FutureProvider<List<MonthlyFeeData>>((ref) {
  return ref.watch(analyticsServiceProvider).fetchMonthlyFees();
});

final attendanceAnalyticsProvider = FutureProvider<List<AttendanceAnalytics>>((ref) {
  return ref.watch(analyticsServiceProvider).fetchAttendanceAnalytics();
});

final materialAnalyticsProvider = FutureProvider<List<MaterialAnalytics>>((ref) {
  return ref.watch(analyticsServiceProvider).fetchMaterialAnalytics();
});

final studentsPerBatchProvider = FutureProvider<List<BatchStudentCount>>((ref) {
  return ref.watch(analyticsServiceProvider).fetchStudentsPerBatch();
});
