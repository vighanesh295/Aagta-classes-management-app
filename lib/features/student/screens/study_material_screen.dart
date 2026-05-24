// lib/features/student/screens/study_material_screen.dart
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../models/study_material_model.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

class StudyMaterialScreen extends ConsumerWidget {
  const StudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(currentStudentProvider);
    final batchId      = studentAsync.valueOrNull?.batchId;
    final matAsync     = ref.watch(studyMaterialsProvider(batchId));

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Study Materials'),
      body: matAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (materials) {
          if (materials.isEmpty) {
            return Center(
            child: Text('No study materials available.',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            itemBuilder: (_, i) {
              final m = materials[i];
              return _MaterialCard(material: m)
                  .animate().fadeIn(delay: (i * 60).ms);
            },
          );
        },
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final StudyMaterialModel material;
  const _MaterialCard({required this.material});

  IconData get _icon {
    switch (material.type) {
      case MaterialType.pdf:   return Icons.picture_as_pdf_rounded;
      case MaterialType.video: return Icons.play_circle_rounded;
      case MaterialType.link:  return Icons.link_rounded;
      case MaterialType.image: return Icons.image_rounded;
    }
  }

  Color _color(BuildContext context) {
    switch (material.type) {
      case MaterialType.pdf:   return Theme.of(context).colorScheme.error;
      case MaterialType.video: return Colors.blue;
      case MaterialType.link:  return Theme.of(context).colorScheme.secondary;
      case MaterialType.image: return Colors.green;
    }
  }

  Future<void> _open() async {
    final uri = Uri.parse(material.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 10),
    onTap: _open,
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: _color(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_icon, color: _color(context), size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(material.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(material.subject, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
        Text('By ${material.teacherName} Â· ${AppDateUtils.relativeTime(material.uploadedAt)}',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
      ])),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _color(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(material.type.label,
            style: TextStyle(color: _color(context), fontSize: 10, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 4),
      Icon(Icons.open_in_new_rounded, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, size: 16),
    ]),
  );
}
