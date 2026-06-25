// lib/models/lecture_model.dart
import 'package:equatable/equatable.dart';

class LectureModel extends Equatable {
  final String   id;
  final String   subject;
  final String   teacherId;
  final String   teacherName;
  final String   batchId;
  final String   batchName;
  final DateTime startTime;
  final DateTime endTime;
  final String?  room;
  final String?  topic;
  final bool     isCancelled;
  final DateTime createdAt;

  Duration get duration => endTime.difference(startTime);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  const LectureModel({
    required this.id,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.batchId,
    required this.batchName,
    required this.startTime,
    required this.endTime,
    this.room,
    this.topic,
    this.isCancelled = false,
    required this.createdAt,
  });

  factory LectureModel.fromMap(Map<String, dynamic> map, String id) {
    return LectureModel(
      id:           id,
      subject:      map['subject']     as String? ?? '',
      teacherId:    map['teacher_id']   as String? ?? '',
      teacherName:  map['teacherName'] as String? ?? '',
      batchId:      map['batch_id']     as String? ?? '',
      batchName:    map['batch_name']   as String? ?? '',
      startTime:   DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime:     DateTime.tryParse(map['endTime']?.toString() ?? '') ?? DateTime.now(),
      room:         map['room']        as String?,
      topic:        map['topic']       as String?,
      isCancelled:  map['isCancelled'] as bool? ?? false,
      createdAt:   DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'subject':     subject,
    'teacher_id':   teacherId,
    'teacherName': teacherName,
    'batch_id':     batchId,
    'batch_name':   batchName,
    'startTime':   startTime.toIso8601String(),
    'endTime':     endTime.toIso8601String(),
    'room':        room,
    'topic':       topic,
    'isCancelled': isCancelled,
    'created_at':   createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, teacherId, startTime];
}
