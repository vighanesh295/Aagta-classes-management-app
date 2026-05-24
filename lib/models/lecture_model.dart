// lib/models/lecture_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      teacherId:    map['teacherId']   as String? ?? '',
      teacherName:  map['teacherName'] as String? ?? '',
      batchId:      map['batchId']     as String? ?? '',
      batchName:    map['batchName']   as String? ?? '',
      startTime:   (map['startTime']   as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime:     (map['endTime']     as Timestamp?)?.toDate() ?? DateTime.now(),
      room:         map['room']        as String?,
      topic:        map['topic']       as String?,
      isCancelled:  map['isCancelled'] as bool? ?? false,
      createdAt:   (map['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory LectureModel.fromDoc(DocumentSnapshot doc) =>
      LectureModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'subject':     subject,
    'teacherId':   teacherId,
    'teacherName': teacherName,
    'batchId':     batchId,
    'batchName':   batchName,
    'startTime':   Timestamp.fromDate(startTime),
    'endTime':     Timestamp.fromDate(endTime),
    'room':        room,
    'topic':       topic,
    'isCancelled': isCancelled,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [id, teacherId, startTime];
}
