// lib/features/teacher/screens/lecture_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../models/lecture_model.dart';
import '../../../providers/teacher_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class LectureScheduleScreen extends ConsumerWidget {
  const LectureScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(teacherLecturesProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Lecture Schedule'),
      body: lecturesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lectures) {
          if (lectures.isEmpty) {
            return Center(
              child: Text('No lectures scheduled.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
          }

          // Group by date
          final grouped = <String, List<LectureModel>>{};
          for (final l in lectures) {
            final key = AppDateUtils.formatDate(l.startTime);
            grouped.putIfAbsent(key, () => []).add(l);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(child: StatCard(
                  label: 'Total', value: '${lectures.length}',
                  icon: Icons.class_rounded, iconColor: Theme.of(context).colorScheme.secondary, iconBg: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                )),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: 'Upcoming',
                  value: '${lectures.where((l) => l.startTime.isAfter(DateTime.now())).length}',
                  icon: Icons.event_rounded,
                  iconColor: Colors.blue, iconBg: Colors.blue.withValues(alpha: 0.1),
                )),
              ]).animate().fadeIn(),
              const SizedBox(height: 20),
              ...grouped.entries.expand((entry) => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Container(
                      width: 4, height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(entry.key, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700)),
                  ]),
                ),
                ...entry.value.map((l) => _LectureCard(lecture: l).animate().fadeIn()),
              ]),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  final LectureModel lecture;
  const _LectureCard({required this.lecture});

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    showGoldBorder: lecture.isToday && !lecture.isCancelled,
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: lecture.isCancelled ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppDateUtils.formatTime(lecture.startTime),
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: lecture.isCancelled ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary)),
          Text(AppDateUtils.formatShortDay(lecture.startTime),
              style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lecture.subject, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700)),
        if (lecture.topic != null)
          Text(lecture.topic!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
        Text('${lecture.batchName} Â· ${lecture.room ?? "Online"}',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(
          '${AppDateUtils.formatTime(lecture.startTime)} â€“ ${AppDateUtils.formatTime(lecture.endTime)}',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11),
        ),
      ])),
      if (lecture.isCancelled)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('CANCELLED', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 9, fontWeight: FontWeight.w700)),
        )
      else if (lecture.isToday)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('TODAY', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
    ]),
  );
}
