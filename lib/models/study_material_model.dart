import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class StudyMaterialModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? subject;
  final String fileUrl;
  final String? fileName;
  final int? fileSize; // in bytes
  final String? fileType; // mime type e.g. 'application/pdf', 'image/png'
  final String uploadedBy;
  final String? uploaderName;
  final String? uploaderRole;
  final String batch;
  final int downloadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyMaterialModel({
    required this.id,
    required this.title,
    this.description,
    this.subject,
    required this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    required this.uploadedBy,
    this.uploaderName,
    this.uploaderRole,
    required this.batch,
    this.downloadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData get fileIcon {
    if (fileType == null) return Icons.insert_drive_file_outlined;
    final t = fileType!.toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (t.contains('image')) return Icons.image_outlined;
    if (t.contains('video')) return Icons.video_file_outlined;
    if (t.contains('word') || t.contains('document')) return Icons.description_outlined;
    if (t.contains('presentation') || t.contains('powerpoint')) return Icons.slideshow_outlined;
    if (t.contains('sheet') || t.contains('excel')) return Icons.table_chart_outlined;
    if (t.contains('zip') || t.contains('rar')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color get fileColor {
    if (fileType == null) return const Color(0xFF666666);
    final t = fileType!.toLowerCase();
    if (t.contains('pdf')) return Colors.red;
    if (t.contains('image')) return Colors.blue;
    if (t.contains('video')) return Colors.purple;
    if (t.contains('word') || t.contains('document')) return const Color(0xFF2B7BDB);
    if (t.contains('presentation') || t.contains('powerpoint')) return Colors.orange;
    if (t.contains('sheet') || t.contains('excel')) return Colors.green;
    return const Color(0xFF666666);
  }

  factory StudyMaterialModel.fromMap(Map<String, dynamic> map) {
    return StudyMaterialModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      subject: map['subject'],
      fileUrl: map['file_url'] ?? '',
      fileName: map['file_name'],
      fileSize: map['file_size'] != null ? (map['file_size'] as num).toInt() : null,
      fileType: map['file_type'],
      uploadedBy: map['uploaded_by'] ?? '',
      uploaderName: map['uploader_name'],
      uploaderRole: map['uploader_role'],
      batch: map['batch'] ?? '',
      downloadCount: map['download_count'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (subject != null) 'subject': subject,
      'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (fileType != null) 'file_type': fileType,
      'uploaded_by': uploadedBy,
      if (uploaderName != null) 'uploader_name': uploaderName,
      if (uploaderRole != null) 'uploader_role': uploaderRole,
      'batch': batch,
      'download_count': downloadCount,
    };
  }

  @override
  List<Object?> get props => [id, fileUrl, downloadCount, updatedAt];
}
