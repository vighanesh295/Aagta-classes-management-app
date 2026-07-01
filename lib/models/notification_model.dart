import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String? announcementId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.announcementId,
    required this.title,
    required this.message,
    this.type = 'announcement',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      announcementId: map['announcement_id'],
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'announcement',
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'announcement_id': announcementId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    userId: userId,
    announcementId: announcementId,
    title: title,
    message: message,
    type: type,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [id, isRead];
}
