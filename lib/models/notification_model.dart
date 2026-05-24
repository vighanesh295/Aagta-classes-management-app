// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String   id;
  final String   title;
  final String   body;
  final String?  targetUid;
  final String?  targetRole;
  final bool     isRead;
  final String   type; // 'fee_reminder' | 'announcement' | 'result' | 'general'
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.targetUid,
    this.targetRole,
    this.isRead = false,
    this.type = 'general',
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id:         id,
      title:      map['title']      as String? ?? '',
      body:       map['body']       as String? ?? '',
      targetUid:  map['targetUid']  as String?,
      targetRole: map['targetRole'] as String?,
      isRead:     map['isRead']     as bool? ?? false,
      type:       map['type']       as String? ?? 'general',
      createdAt: (map['createdAt']  as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory NotificationModel.fromDoc(DocumentSnapshot doc) =>
      NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'title':      title,
    'body':       body,
    'targetUid':  targetUid,
    'targetRole': targetRole,
    'isRead':     isRead,
    'type':       type,
    'createdAt':  Timestamp.fromDate(createdAt),
  };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, title: title, body: body, targetUid: targetUid,
    targetRole: targetRole, type: type, createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [id];
}
