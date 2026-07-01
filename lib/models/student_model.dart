// lib/models/student_model.dart
import 'package:equatable/equatable.dart';

class StudentModel extends Equatable {
  final String  uid; // Also serves as id
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

  // --- New fields requested by prompt ---
  final String? batch; // Keeping alongside batchName for compatibility if needed
  final String? rollNumber;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? parentEmail;
  final DateTime? joinedAt;
  final DateTime? updatedAt;

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
    
    // New fields
    this.batch,
    this.rollNumber,
    this.dateOfBirth,
    this.gender,
    this.parentEmail,
    this.joinedAt,
    this.updatedAt,
  });

  // Getter for ID to match the new module's expectation
  String get id => uid;

  // Helpers requested by prompt
  String get ageDisplay {
    if (dateOfBirth == null) return '';
    final age = DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
    return '$age years';
  }

  String get initials {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, [String? fallbackUid]) {
    final parsedUid = map['id'] ?? map['uid'] ?? fallbackUid ?? '';
    
    return StudentModel(
      uid:                parsedUid,
      name:               map['name']               as String? ?? '',
      email:              map['email']              as String? ?? '',
      studentId:          map['student_id']          as String? ?? '',
      phone:              map['phone']              as String?,
      photoUrl:           map['photo_url']           as String?,
      batchId:            map['batch_id']            as String?,
      batchName:          map['batch_name']          as String?,
      course:             map['course']             as String?,
      address:            map['address']            as String?,
      parentName:         map['parentName'] ?? map['parent_name'] as String?,
      parentPhone:        map['parentPhone'] ?? map['parent_phone'] as String?,
      education:          map['education']          as String?,
      attendancePercent: (map['attendancePercent'] as num?)?.toDouble() ?? 0.0,
      achievements:      List<String>.from(map['achievements'] as List? ?? []),
      isActive:           map['isActive'] ?? map['is_active'] as bool? ?? true,
      enrolledAt: DateTime.tryParse(map['enrolledAt']?.toString() ?? '') ?? DateTime.now(),
      
      // New fields mapping
      batch:              map['batch'] as String?,
      rollNumber:         map['roll_number'] as String?,
      dateOfBirth:        map['date_of_birth'] != null ? DateTime.tryParse(map['date_of_birth'].toString()) : null,
      gender:             map['gender'] as String?,
      parentEmail:        map['parent_email'] as String?,
      joinedAt:           map['joined_at'] != null ? DateTime.tryParse(map['joined_at'].toString()) : null,
      updatedAt:          map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':                 uid,
    'uid':                uid,
    'name':               name,
    'email':              email,
    'student_id':         studentId,
    'phone':              phone,
    'photo_url':          photoUrl,
    'batch_id':           batchId,
    'batch_name':         batchName,
    'course':             course,
    'address':            address,
    'parentName':         parentName,
    'parent_name':        parentName,
    'parentPhone':        parentPhone,
    'parent_phone':       parentPhone,
    'education':          education,
    'attendancePercent':  attendancePercent,
    'achievements':       achievements,
    'isActive':           isActive,
    'is_active':          isActive,
    'enrolledAt':         enrolledAt.toIso8601String(),
    'role':               'student',
    
    // New fields
    'batch':              batch,
    'roll_number':        rollNumber,
    'date_of_birth':      dateOfBirth?.toIso8601String(),
    'gender':             gender,
    'parent_email':       parentEmail,
    'joined_at':          joinedAt?.toIso8601String(),
    'updated_at':         updatedAt?.toIso8601String(),
  };

  StudentModel copyWith({
    String?  name, String?  phone, String?  photoUrl, String?  batchId,
    String?  batchName, String?  course, String?  address, String?  parentName,
    String?  parentPhone, String?  education, double?  attendancePercent,
    List<String>? achievements, bool? isActive,
    String? batch, String? rollNumber, DateTime? dateOfBirth, String? gender,
    String? parentEmail, DateTime? joinedAt, DateTime? updatedAt,
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
    batch:              batch              ?? this.batch,
    rollNumber:         rollNumber         ?? this.rollNumber,
    dateOfBirth:        dateOfBirth        ?? this.dateOfBirth,
    gender:             gender             ?? this.gender,
    parentEmail:        parentEmail        ?? this.parentEmail,
    joinedAt:           joinedAt           ?? this.joinedAt,
    updatedAt:          updatedAt          ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [uid, studentId, email];
}
