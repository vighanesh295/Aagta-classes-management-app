// lib/models/teacher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TeacherModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? subject;
  final String? qualification;
  final List<String> batches;
  final bool isActive;
  final DateTime joinedAt;

  const TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.subject,
    this.qualification,
    this.batches = const [],
    this.isActive = true,
    required this.joinedAt,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map, String uid) {
    return TeacherModel(
      uid:           uid,
      name:          map['name']          as String? ?? '',
      email:         map['email']         as String? ?? '',
      phone:         map['phone']         as String?,
      photoUrl:      map['photoUrl']      as String?,
      subject:       map['subject']       as String?,
      qualification: map['qualification'] as String?,
      batches:       List<String>.from(map['batches'] as List? ?? []),
      isActive:      map['isActive']      as bool? ?? true,
      joinedAt:     (map['joinedAt']      as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TeacherModel.fromDoc(DocumentSnapshot doc) =>
      TeacherModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'name':          name,
    'email':         email,
    'phone':         phone,
    'photoUrl':      photoUrl,
    'subject':       subject,
    'qualification': qualification,
    'batches':       batches,
    'isActive':      isActive,
    'joinedAt':      Timestamp.fromDate(joinedAt),
    'role':          'teacher',
  };

  TeacherModel copyWith({
    String? name, String? phone, String? photoUrl,
    String? subject, String? qualification,
    List<String>? batches, bool? isActive,
  }) => TeacherModel(
    uid: uid, email: email, joinedAt: joinedAt,
    name:          name          ?? this.name,
    phone:         phone         ?? this.phone,
    photoUrl:      photoUrl      ?? this.photoUrl,
    subject:       subject       ?? this.subject,
    qualification: qualification ?? this.qualification,
    batches:       batches       ?? this.batches,
    isActive:      isActive      ?? this.isActive,
  );

  @override
  List<Object?> get props => [uid, email];
}
