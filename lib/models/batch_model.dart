import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum BatchStatus { active, inactive, completed }

class BatchModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? subject;
  final String? teacherId;
  final String? teacherName;
  final int maxStudents;
  final int currentStudentCount;
  final List<String> scheduleDays;
  final String? scheduleTime;
  final DateTime? startDate;
  final DateTime? endDate;
  final double feeAmount;
  final BatchStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BatchModel({
    required this.id,
    required this.name,
    this.description,
    this.subject,
    this.teacherId,
    this.teacherName,
    this.maxStudents = 30,
    this.currentStudentCount = 0,
    this.scheduleDays = const [],
    this.scheduleTime,
    this.startDate,
    this.endDate,
    this.feeAmount = 0,
    this.status = BatchStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helpers
  bool get isFull => currentStudentCount >= maxStudents;

  double get occupancyPercentage =>
      maxStudents > 0 ? (currentStudentCount / maxStudents * 100) : 0;

  Color get statusColor {
    switch (status) {
      case BatchStatus.active: return const Color(0xFF4CAF50);
      case BatchStatus.inactive: return const Color(0xFFFF9800);
      case BatchStatus.completed: return const Color(0xFF9E9E9E);
    }
  }

  String get statusLabel {
    switch (status) {
      case BatchStatus.active: return 'Active';
      case BatchStatus.inactive: return 'Inactive';
      case BatchStatus.completed: return 'Completed';
    }
  }

  String get scheduleDisplay {
    if (scheduleDays.isEmpty && scheduleTime == null) return 'No schedule set';
    final days = scheduleDays.join(', ');
    if (scheduleTime != null) return '$days • $scheduleTime';
    return days;
  }

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    BatchStatus parseStatus(String? s) {
      switch (s) {
        case 'inactive': return BatchStatus.inactive;
        case 'completed': return BatchStatus.completed;
        case 'active':
        default:
          return BatchStatus.active;
      }
    }

    return BatchModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      subject: map['subject'] as String?,
      teacherId: map['teacher_id'] as String?,
      teacherName: map['teacher_name'] as String?,
      maxStudents: map['max_students'] as int? ?? 30,
      currentStudentCount: map['current_student_count'] as int? ?? 0,
      scheduleDays: List<String>.from(map['schedule_days'] ?? []),
      scheduleTime: map['schedule_time'] as String?,
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
      feeAmount: (map['fee_amount'] as num?)?.toDouble() ?? 0.0,
      status: parseStatus(map['status'] as String?),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'max_students': maxStudents,
      'schedule_days': scheduleDays,
      'schedule_time': scheduleTime,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'fee_amount': feeAmount,
      'status': status.name,
      // currentStudentCount, createdAt, updatedAt are handled by DB triggers/defaults
    };
  }

  BatchModel copyWith({
    String? id,
    String? name,
    String? description,
    String? subject,
    String? teacherId,
    String? teacherName,
    int? maxStudents,
    int? currentStudentCount,
    List<String>? scheduleDays,
    String? scheduleTime,
    DateTime? startDate,
    DateTime? endDate,
    double? feeAmount,
    BatchStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      maxStudents: maxStudents ?? this.maxStudents,
      currentStudentCount: currentStudentCount ?? this.currentStudentCount,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      feeAmount: feeAmount ?? this.feeAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, subject, teacherId, teacherName, maxStudents,
        currentStudentCount, scheduleDays, scheduleTime, startDate, endDate,
        feeAmount, status,
      ];
}
