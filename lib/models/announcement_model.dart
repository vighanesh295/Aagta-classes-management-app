// lib/models/announcement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AnnouncementModel extends Equatable {
  final String   id;
  final String   title;
  final String   content;
  final String   createdBy;
  final String?  targetRole; // null = all
  final bool     isPinned;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdBy,
    this.targetRole,
    this.isPinned = false,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id:         id,
      title:      map['title']      as String? ?? '',
      content:    map['content']    as String? ?? '',
      createdBy:  map['createdBy']  as String? ?? '',
      targetRole: map['targetRole'] as String?,
      isPinned:   map['isPinned']   as bool? ?? false,
      createdAt: (map['createdAt']  as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AnnouncementModel.fromDoc(DocumentSnapshot doc) =>
      AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'title':      title,
    'content':    content,
    'createdBy':  createdBy,
    'targetRole': targetRole,
    'isPinned':   isPinned,
    'createdAt':  Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [id, title];
}
