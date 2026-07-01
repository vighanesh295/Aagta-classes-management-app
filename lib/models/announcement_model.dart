import 'package:equatable/equatable.dart';

class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final String createdBy;
  final String? creatorName;
  final String? creatorRole;
  final String target;
  final String? batch;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdBy,
    this.creatorName,
    this.creatorRole,
    this.target = 'global',
    this.batch,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdBy: map['created_by'] ?? '',
      creatorName: map['creator_name'],
      creatorRole: map['creator_role'],
      target: map['target'] ?? 'global',
      batch: map['batch'],
      isPinned: map['is_pinned'] ?? false,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'body': body,
      'created_by': createdBy,
      'creator_name': creatorName,
      'creator_role': creatorRole,
      'target': target,
      'batch': batch,
      'is_pinned': isPinned,
      // created_at and updated_at usually handled by DB on insert
    };
  }

  @override
  List<Object?> get props => [id, title, isPinned];
}
