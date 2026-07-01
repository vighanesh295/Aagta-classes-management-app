import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mime/mime.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../models/study_material_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/study_material_provider.dart';

class StudyMaterialsScreen extends ConsumerStatefulWidget {
  const StudyMaterialsScreen({super.key});
  @override
  ConsumerState<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends ConsumerState<StudyMaterialsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedSubject = 'All';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;
    final isTeacher = user?.role == UserRole.teacher;
    final canManage = isAdmin || isTeacher;

    final AsyncValue<List<StudyMaterialModel>> materialsAsync;
    if (canManage) {
      materialsAsync = ref.watch(allMaterialsProvider);
    } else {
      materialsAsync = ref.watch(studentMaterialsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search title or subject...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              )
            : const Text('Study Materials'),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = '';
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryOrange,
              onPressed: () => _showUploadSheet(context, ref, user?.batch),
              child: const Icon(Icons.upload_file, color: Colors.white),
            )
          : null,
      body: materialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (materials) {
          if (materials.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No study materials yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Extract unique subjects
          final subjects = {'All'};
          for (var m in materials) {
            if (m.subject != null && m.subject!.isNotEmpty) {
              subjects.add(m.subject!);
            }
          }
          final subjectList = subjects.toList()..sort();

          // Filter materials
          final filtered = materials.where((m) {
            final matchesSubject = _selectedSubject == 'All' || m.subject == _selectedSubject;
            final matchesSearch = _searchQuery.isEmpty ||
                m.title.toLowerCase().contains(_searchQuery) ||
                (m.subject?.toLowerCase().contains(_searchQuery) ?? false);
            return matchesSubject && matchesSearch;
          }).toList();

          return Column(
            children: [
              // Filter Chips
              if (subjectList.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: subjectList.map((s) {
                      final isActive = s == _selectedSubject;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: isActive,
                          onSelected: (_) => setState(() => _selectedSubject = s),
                          selectedColor: AppColors.primaryOrange,
                          backgroundColor: const Color(0xFFFFF4EB),
                          labelStyle: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFFFB8B24),
                            fontWeight: FontWeight.w600,
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text("No results for '$_searchQuery'", style: const TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          return _MaterialCard(
                            material: filtered[i],
                            canManage: canManage,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUploadSheet(BuildContext context, WidgetRef ref, String? defaultBatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadSheet(defaultBatch: defaultBatch),
    );
  }
}

class _MaterialCard extends ConsumerStatefulWidget {
  final StudyMaterialModel material;
  final bool canManage;
  const _MaterialCard({required this.material, required this.canManage});

  @override
  ConsumerState<_MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends ConsumerState<_MaterialCard> {
  bool _isDownloading = false;
  double _progress = 0.0;

  Future<void> _handleDownloadAndOpen() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    try {
      final service = ref.read(studyMaterialServiceProvider);
      // 1. Get signed URL
      final url = await service.getDownloadUrl(widget.material.fileUrl);

      // 2. Setup download path
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${widget.material.fileName ?? widget.material.id}';

      // 3. Download file
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      // 4. Increment download count (fire and forget)
      service.incrementDownload(widget.material.id).catchError((_) {});

      // 5. Open file
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
        });
      }
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Material?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(studyMaterialServiceProvider).deleteMaterial(widget.material.id, widget.material.fileUrl);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.material;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _handleDownloadAndOpen,
          onLongPress: widget.canManage ? _handleDelete : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.fileColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(m.fileIcon, color: m.fileColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  m.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.canManage)
                                InkWell(
                                  onTap: _handleDelete,
                                  child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                                )
                            ],
                          ),
                          if (m.subject != null && m.subject!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4, bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                m.subject!,
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                            ),
                          if (m.description != null && m.description!.isNotEmpty)
                            Text(
                              m.description!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(m.batch, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(m.fileSizeFormatted, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const Icon(Icons.download, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text('${m.downloadCount}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${m.uploaderName ?? "Unknown"} • ${AppDateUtils.relativeTime(m.createdAt)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isDownloading) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryOrange),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadSheet extends ConsumerStatefulWidget {
  final String? defaultBatch;
  const _UploadSheet({this.defaultBatch});

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String? _selectedBatch;
  File? _pickedFile;
  String? _fileName;
  int? _fileSize;
  String? _fileType;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedBatch = widget.defaultBatch;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      final mime = lookupMimeType(file.path) ?? 'application/octet-stream';

      setState(() {
        _pickedFile = file;
        _fileName = result.files.single.name;
        _fileSize = size;
        _fileType = mime;
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a batch.')));
      return;
    }
    if (_pickedFile == null || _fileName == null || _fileSize == null || _fileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file.')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      final teacher = ref.read(currentTeacherProvider).valueOrNull;
      final uploaderName = teacher?.name ?? user?.name ?? 'Admin';
      final uploaderRole = user?.role.name ?? 'admin';

      await ref.read(studyMaterialServiceProvider).uploadMaterial(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        batch: _selectedBatch!,
        file: _pickedFile!,
        fileName: _fileName!,
        fileType: _fileType!,
        fileSize: _fileSize!,
        uploaderName: uploaderName,
        uploaderRole: uploaderRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material uploaded successfully'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Upload Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Upload Material', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            // Need a batch dropdown. Ideally from API, but for now we'll allow text input or just standard choices.
            // If the teacher has a default batch, let's just make it a text field to keep it simple, 
            // or if it's admin, they must type it. In a real app we'd fetch batches.
            TextFormField(
              initialValue: _selectedBatch,
              decoration: const InputDecoration(labelText: 'Batch *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              onChanged: (v) => _selectedBatch = v,
            ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_fileName ?? 'Select File'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: _fileName != null ? AppColors.primaryOrange : Colors.grey),
              ),
            ),
            if (_fileSize != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Size: ${(_fileSize! / 1024 / 1024).toStringAsFixed(2)} MB', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
