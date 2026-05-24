// lib/models/result_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ResultModel extends Equatable {
  final String   id;
  final String   studentId;
  final String   studentName;
  final String   examName;
  final String   subject;
  final double   marks;
  final double   totalMarks;
  final String?  grade;
  final String?  remarks;
  final DateTime examDate;

  double get percentage => totalMarks > 0 ? (marks / totalMarks * 100) : 0;

  String get computedGrade {
    if (grade != null) return grade!;
    final pct = percentage;
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    return 'F';
  }

  const ResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examName,
    required this.subject,
    required this.marks,
    required this.totalMarks,
    this.grade,
    this.remarks,
    required this.examDate,
  });

  factory ResultModel.fromMap(Map<String, dynamic> map, String id) {
    return ResultModel(
      id:          id,
      studentId:   map['studentId']   as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      examName:    map['examName']    as String? ?? '',
      subject:     map['subject']     as String? ?? '',
      marks:      (map['marks']       as num?)?.toDouble() ?? 0,
      totalMarks: (map['totalMarks']  as num?)?.toDouble() ?? 100,
      grade:       map['grade']       as String?,
      remarks:     map['remarks']     as String?,
      examDate:   (map['examDate']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ResultModel.fromDoc(DocumentSnapshot doc) =>
      ResultModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'studentId':   studentId,
    'studentName': studentName,
    'examName':    examName,
    'subject':     subject,
    'marks':       marks,
    'totalMarks':  totalMarks,
    'grade':       grade,
    'remarks':     remarks,
    'examDate':    Timestamp.fromDate(examDate),
  };

  @override
  List<Object?> get props => [id, studentId, examName];
}
