// lib/models/student_model.dart
import 'package:equatable/equatable.dart';

class StudentModel extends Equatable {
  final String  uid;
  final String  name;
  final String  email;
  final String  studentId;
  final String? phone;
  final String? photoUrl;
  final String? batchId;
  final String? batchName;
  final String? course;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? education;
  final double  attendancePercent;
  final List<String> achievements;
  final bool    isActive;
  final DateTime enrolledAt;

  const StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    this.phone,
    this.photoUrl,
    this.batchId,
    this.batchName,
    this.course,
    this.address,
    this.parentName,
    this.parentPhone,
    this.education,
    this.attendancePercent = 0.0,
    this.achievements = const [],
    this.isActive = true,
    required this.enrolledAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String uid) {
    return StudentModel(
      uid:                uid,
      name:               map['name']               as String? ?? '',
      email:              map['email']              as String? ?? '',
      studentId:          map['student_id']          as String? ?? '',
      phone:              map['phone']              as String?,
      photoUrl:           map['photo_url']           as String?,
      batchId:            map['batch_id']            as String?,
      batchName:          map['batch_name']          as String?,
      course:             map['course']             as String?,
      address:            map['address']            as String?,
      parentName:         map['parentName']         as String?,
      parentPhone:        map['parentPhone']        as String?,
      education:          map['education']          as String?,
      attendancePercent: (map['attendancePercent'] as num?)?.toDouble() ?? 0.0,
      achievements:      List<String>.from(map['achievements'] as List? ?? []),
      isActive:           map['isActive']           as bool? ?? true,
      enrolledAt: DateTime.tryParse(map['enrolledAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':               name,
    'email':              email,
    'student_id':          studentId,
    'phone':              phone,
    'photo_url':           photoUrl,
    'batch_id':            batchId,
    'batch_name':          batchName,
    'course':             course,
    'address':            address,
    'parentName':         parentName,
    'parentPhone':        parentPhone,
    'education':          education,
    'attendancePercent':  attendancePercent,
    'achievements':       achievements,
    'isActive':           isActive,
    'enrolledAt':         enrolledAt.toIso8601String(),
    'role':               'student',
  };

  StudentModel copyWith({
    String?  name, String?  phone, String?  photoUrl, String?  batchId,
    String?  batchName, String?  course, String?  address, String?  parentName,
    String?  parentPhone, String?  education, double?  attendancePercent,
    List<String>? achievements, bool? isActive,
  }) => StudentModel(
    uid: uid, email: email, studentId: studentId, enrolledAt: enrolledAt,
    name:               name               ?? this.name,
    phone:              phone              ?? this.phone,
    photoUrl:           photoUrl           ?? this.photoUrl,
    batchId:            batchId            ?? this.batchId,
    batchName:          batchName          ?? this.batchName,
    course:             course             ?? this.course,
    address:            address            ?? this.address,
    parentName:         parentName         ?? this.parentName,
    parentPhone:        parentPhone        ?? this.parentPhone,
    education:          education          ?? this.education,
    attendancePercent:  attendancePercent  ?? this.attendancePercent,
    achievements:       achievements       ?? this.achievements,
    isActive:           isActive           ?? this.isActive,
  );

  @override
  List<Object?> get props => [uid, studentId, email];
}
