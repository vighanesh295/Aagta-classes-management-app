// lib/features/teacher/screens/upload_material_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/validators.dart';
import '../../../models/study_material_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../widgets/golden_button.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

class UploadMaterialScreen extends ConsumerStatefulWidget {
  const UploadMaterialScreen({super.key});
  @override
  ConsumerState<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends ConsumerState<UploadMaterialScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();

  File?          _pickedFile;
  String?        _fileName;
  MaterialType   _type     = MaterialType.pdf;
  bool           _uploading = false;
  double         _progress  = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _fileName   = result.files.single.name;
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _uploading = true; _progress = 0; });
    try {
      final user    = ref.read(currentUserProvider).valueOrNull;
      final teacher = ref.read(currentTeacherProvider).valueOrNull;
      if (user == null) return;

      final url = await StorageService.instance.uploadStudyMaterial(
        _pickedFile!, user.uid, _fileName ?? 'file',
        onProgress: (p) => setState(() => _progress = p),
      );

      if (url != null) {
        final map = StudyMaterialModel(
          id:          '',
          title:       _titleCtrl.text.trim(),
          subject:     _subjectCtrl.text.trim(),
          fileUrl:     url,
          type:        _type,
          uploadedBy:  user.uid,
          teacherName: teacher?.name ?? user.name,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          uploadedAt:  DateTime.now(),
        ).toMap();
        map.remove('id');
        await SupabaseService.instance.client.from('study_materials').insert(map);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material uploaded!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GoldenAppBar(title: 'Upload Material'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // File picker card
            GestureDetector(
              onTap: _pickedFile == null ? _pickFile : null,
              child: PremiumCard(
                showGoldBorder: _pickedFile != null,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    _pickedFile != null ? Icons.insert_drive_file_rounded : Icons.upload_file_rounded,
                    color: Theme.of(context).colorScheme.secondary, size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pickedFile != null ? (_fileName ?? 'File selected') : 'Tap to select file',
                    style: TextStyle(
                      color: _pickedFile != null ? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_pickedFile != null)
                    TextButton(
                      onPressed: _pickFile,
                      child: const Text('Change file'),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Type selector
            Wrap(
              spacing: 8,
              children: MaterialType.values.map((t) {
                final isSelected = _type == t;
                return FilterChip(
                  label: Text(t.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  checkmarkColor: Theme.of(context).colorScheme.secondary,
                  side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).dividerColor),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleCtrl,
              validator: Validators.required,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectCtrl,
              validator: Validators.required,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            if (_uploading)
              Column(children: [
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Text('Uploading ${(_progress * 100).toStringAsFixed(0)}%...',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                const SizedBox(height: 16),
              ]),

            GoldenButton(
              label: 'Upload Material',
              isLoading: _uploading,
              onPressed: _uploading ? null : _upload,
              icon: Icons.cloud_upload_rounded,
            ),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    );
  }
}
