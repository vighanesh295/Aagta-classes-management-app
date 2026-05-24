// lib/models/study_material_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      fileUrl:     map['fileUrl']     as String? ?? '',
      type:        MaterialTypeX.fromString(map['type'] as String? ?? 'pdf'),
      uploadedBy:  map['uploadedBy']  as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      batchId:     map['batchId']     as String?,
      description: map['description'] as String?,
      uploadedAt: (map['uploadedAt']  as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory StudyMaterialModel.fromDoc(DocumentSnapshot doc) =>
      StudyMaterialModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'title':       title,
    'subject':     subject,
    'fileUrl':     fileUrl,
    'type':        type.label.toLowerCase(),
    'uploadedBy':  uploadedBy,
    'teacherName': teacherName,
    'batchId':     batchId,
    'description': description,
    'uploadedAt':  Timestamp.fromDate(uploadedAt),
  };

  @override
  List<Object?> get props => [id, fileUrl];
}
