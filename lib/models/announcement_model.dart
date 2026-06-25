// lib/models/announcement_model.dart
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
      createdBy:  map['created_by']  as String? ?? '',
      targetRole: map['targetRole'] as String?,
      isPinned:   map['isPinned']   as bool? ?? false,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':      title,
    'content':    content,
    'created_by':  createdBy,
    'targetRole': targetRole,
    'isPinned':   isPinned,
    'created_at':  createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, title];
}
