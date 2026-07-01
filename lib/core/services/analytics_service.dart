import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/analytics_model.dart';

class AnalyticsService {
  final _client = Supabase.instance.client;

  Future<OverviewAnalytics> fetchOverview() async {
    final data = await _client.from('analytics_overview').select().single();
    return OverviewAnalytics.fromMap(data);
  }

  Future<FeeAnalytics> fetchFeeAnalytics() async {
    final data = await _client.from('analytics_fees').select().single();
    return FeeAnalytics.fromMap(data);
  }

  Future<List<MonthlyFeeData>> fetchMonthlyFees() async {
    final data = await _client.from('analytics_fee_monthly').select();
    return data.map((e) => MonthlyFeeData.fromMap(e)).toList();
  }

  Future<List<AttendanceAnalytics>> fetchAttendanceAnalytics() async {
    final data = await _client.from('analytics_attendance').select();
    return data.map((e) => AttendanceAnalytics.fromMap(e)).toList();
  }

  Future<List<MaterialAnalytics>> fetchMaterialAnalytics() async {
    final data = await _client.from('analytics_materials').select();
    return data.map((e) => MaterialAnalytics.fromMap(e)).toList();
  }

  Future<List<BatchStudentCount>> fetchStudentsPerBatch() async {
    final data = await _client.from('analytics_students_per_batch').select();
    return data.map((e) => BatchStudentCount.fromMap(e)).toList();
  }
}
