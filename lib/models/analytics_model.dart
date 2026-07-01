class OverviewAnalytics {
  final int totalStudents;
  final int totalTeachers;
  final int totalBatches;
  final int totalAnnouncements;
  final int totalMaterials;

  OverviewAnalytics({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalBatches,
    required this.totalAnnouncements,
    required this.totalMaterials,
  });

  factory OverviewAnalytics.fromMap(Map<String, dynamic> map) {
    return OverviewAnalytics(
      totalStudents: map['total_students'] as int? ?? 0,
      totalTeachers: map['total_teachers'] as int? ?? 0,
      totalBatches: map['total_batches'] as int? ?? 0,
      totalAnnouncements: map['total_announcements'] as int? ?? 0,
      totalMaterials: map['total_materials'] as int? ?? 0,
    );
  }
}

class FeeAnalytics {
  final double totalFeeAssigned;
  final double totalCollected;
  final double totalPending;
  final int paidCount;
  final int partialCount;
  final int unpaidCount;
  final int totalStudentsWithFees;

  FeeAnalytics({
    required this.totalFeeAssigned,
    required this.totalCollected,
    required this.totalPending,
    required this.paidCount,
    required this.partialCount,
    required this.unpaidCount,
    required this.totalStudentsWithFees,
  });

  double get collectionPercentage => totalFeeAssigned > 0
      ? (totalCollected / totalFeeAssigned * 100) : 0;

  factory FeeAnalytics.fromMap(Map<String, dynamic> map) {
    return FeeAnalytics(
      totalFeeAssigned: (map['total_fee_assigned'] as num?)?.toDouble() ?? 0.0,
      totalCollected: (map['total_collected'] as num?)?.toDouble() ?? 0.0,
      totalPending: (map['total_pending'] as num?)?.toDouble() ?? 0.0,
      paidCount: map['paid_count'] as int? ?? 0,
      partialCount: map['partial_count'] as int? ?? 0,
      unpaidCount: map['unpaid_count'] as int? ?? 0,
      totalStudentsWithFees: map['total_students_with_fees'] as int? ?? 0,
    );
  }
}

class MonthlyFeeData {
  final String month;
  final double collected;

  MonthlyFeeData({
    required this.month,
    required this.collected,
  });

  factory MonthlyFeeData.fromMap(Map<String, dynamic> map) {
    return MonthlyFeeData(
      month: map['month'] as String? ?? '',
      collected: (map['collected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AttendanceAnalytics {
  final String batch;
  final int totalRecords;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final double attendancePercentage;

  AttendanceAnalytics({
    required this.batch,
    required this.totalRecords,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
  });

  factory AttendanceAnalytics.fromMap(Map<String, dynamic> map) {
    return AttendanceAnalytics(
      batch: map['batch'] as String? ?? 'Unknown',
      totalRecords: map['total_records'] as int? ?? 0,
      presentCount: map['present_count'] as int? ?? 0,
      absentCount: map['absent_count'] as int? ?? 0,
      lateCount: map['late_count'] as int? ?? 0,
      attendancePercentage: (map['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MaterialAnalytics {
  final String batch;
  final int totalMaterials;
  final int totalDownloads;
  final int uniqueUploaders;

  MaterialAnalytics({
    required this.batch,
    required this.totalMaterials,
    required this.totalDownloads,
    required this.uniqueUploaders,
  });

  factory MaterialAnalytics.fromMap(Map<String, dynamic> map) {
    return MaterialAnalytics(
      batch: map['batch'] as String? ?? 'Unknown',
      totalMaterials: map['total_materials'] as int? ?? 0,
      totalDownloads: map['total_downloads'] as int? ?? 0,
      uniqueUploaders: map['unique_uploaders'] as int? ?? 0,
    );
  }
}

class BatchStudentCount {
  final String batch;
  final int studentCount;

  BatchStudentCount({
    required this.batch,
    required this.studentCount,
  });

  factory BatchStudentCount.fromMap(Map<String, dynamic> map) {
    return BatchStudentCount(
      batch: map['batch'] as String? ?? 'Unknown',
      studentCount: map['student_count'] as int? ?? 0,
    );
  }
}
