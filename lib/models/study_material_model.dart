// lib/models/study_material_model.dart
import 'package:equatable/equatable.dart';

enum MaterialType { pdf, video, link, image }

extension MaterialTypeX on MaterialType {
  String get label {
    switch (this) {
      case MaterialType.pdf:   return 'PDF';
      case MaterialType.video: return 'Video';
      case MaterialType.link:  return 'Link';
      case MaterialType.image: return 'Image';
    }
  }

  static MaterialType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'video': return MaterialType.video;
      case 'link':  return MaterialType.link;
      case 'image': return MaterialType.image;
      default:      return MaterialType.pdf;
    }
  }
}

class StudyMaterialModel extends Equatable {
  final String       id;
  final String       title;
  final String       subject;
  final String       fileUrl;
  final MaterialType type;
  final String       uploadedBy;
  final String       teacherName;
  final String?      batchId;
  final String?      description;
  final DateTime     uploadedAt;

  const StudyMaterialModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.fileUrl,
    required this.type,
    required this.uploadedBy,
    required this.teacherName,
    this.batchId,
    this.description,
    required this.uploadedAt,
  });

  factory StudyMaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return StudyMaterialModel(
      id:          id,
      title:       map['title']       as String? ?? '',
      subject:     map['subject']     as String? ?? '',
      fileUrl:     map['file_url']     as String? ?? '',
      type:        MaterialTypeX.fromString(map['type'] as String? ?? 'pdf'),
      uploadedBy:  map['uploaded_by']  as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      batchId:     map['batch_id']     as String?,
      description: map['description'] as String?,
      uploadedAt: DateTime.tryParse(map['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':       title,
    'subject':     subject,
    'file_url':     fileUrl,
    'type':        type.label.toLowerCase(),
    'uploaded_by':  uploadedBy,
    'teacherName': teacherName,
    'batch_id':     batchId,
    'description': description,
    'uploadedAt':  uploadedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, fileUrl];
}
