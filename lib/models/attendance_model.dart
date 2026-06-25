// lib/models/attendance_model.dart
import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present: return 'Present';
      case AttendanceStatus.absent:  return 'Absent';
      case AttendanceStatus.late:    return 'Late';
    }
  }

  static AttendanceStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'present': return AttendanceStatus.present;
      case 'late':    return AttendanceStatus.late;
      default:        return AttendanceStatus.absent;
    }
  }
}

class AttendanceModel extends Equatable {
  final String           id;
  final String           studentId;
  final String           lectureId;
  final String           subject;
  final DateTime         date;
  final AttendanceStatus status;
  final String?          teacherId;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.lectureId,
    required this.subject,
    required this.date,
    required this.status,
    this.teacherId,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id:        id,
      studentId: map['student_id'] as String? ?? '',
      lectureId: map['lectureId'] as String? ?? '',
      subject:   map['subject']   as String? ?? '',
      date:      DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      status:    AttendanceStatusX.fromString(map['status'] as String? ?? 'absent'),
      teacherId: map['teacher_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'student_id': studentId,
    'lectureId': lectureId,
    'subject':   subject,
    'date':      date.toIso8601String(),
    'status':    status.label.toLowerCase(),
    'teacher_id': teacherId,
  };

  @override
  List<Object?> get props => [id, studentId, lectureId];
}
