// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

enum UserRole { student, teacher, admin }

extension UserRoleX on UserRole {
  String get name {
    switch (this) {
      case UserRole.student: return 'student';
      case UserRole.teacher: return 'teacher';
      case UserRole.admin:   return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'teacher': return UserRole.teacher;
      case 'admin':   return UserRole.admin;
      default:        return UserRole.student;
    }
  }
}

class UserModel extends Equatable {
  final String   uid;
  final String   email;
  final String   name;
  final UserRole role;
  final String?  photoUrl;
  final String?  phone;
  final String?  fcmToken;
  final bool     isActive;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phone,
    this.fcmToken,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid:       uid,
      email:     map['email']    as String? ?? '',
      name:      map['name']     as String? ?? '',
      role:      UserRoleX.fromString(map['role'] as String? ?? 'student'),
      photoUrl:  map['photo_url'] as String?,
      phone:     map['phone']    as String?,
      fcmToken:  map['fcmToken'] as String?,
      isActive:  map['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email':     email,
    'name':      name,
    'role':      role.name,
    'photo_url':  photoUrl,
    'phone':     phone,
    'fcmToken':  fcmToken,
    'isActive':  isActive,
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String?   name,
    String?   photoUrl,
    String?   phone,
    String?   fcmToken,
    bool?     isActive,
  }) => UserModel(
    uid:       uid,
    email:     email,
    name:      name      ?? this.name,
    role:      role,
    photoUrl:  photoUrl  ?? this.photoUrl,
    phone:     phone     ?? this.phone,
    fcmToken:  fcmToken  ?? this.fcmToken,
    isActive:  isActive  ?? this.isActive,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [uid, email, role];
}
