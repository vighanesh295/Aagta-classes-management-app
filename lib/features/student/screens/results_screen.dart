// lib/features/student/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  Color _gradeColor(BuildContext context, String grade) {
    switch (grade) {
      case 'A+': case 'A':  return Colors.green;
      case 'B+': case 'B':  return Colors.blue;
      case 'C':             return Colors.orange;
      default:              return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentResultsProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'My Results'),
      body: resultsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (results) {
          if (results.isEmpty) {
            return Center(
            child: Text('No results yet.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)));
          }

          final avg = results.isNotEmpty
              ? results.map((r) => r.percentage).reduce((a, b) => a + b) / results.length
              : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary
              Row(children: [
                Expanded(child: StatCard(
                  label: 'Total Exams', value: '${results.length}',
                  icon: Icons.assignment_rounded,
                  iconColor: Theme.of(context).colorScheme.secondary, iconBg: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                )),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: 'Avg Score', value: '${avg.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  iconColor: avg >= 75 ? Colors.green : Colors.orange,
                  iconBg: avg >= 75 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  valueColor: avg >= 75 ? Colors.green : Colors.orange,
                )),
              ]).animate().fadeIn(),
              const SizedBox(height: 20),

              const SectionHeader(title: 'Exam Results').animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 12),

              ...results.asMap().entries.map((e) {
                final r = e.value;
                final grade = r.computedGrade;
                return PremiumCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  showGoldBorder: grade == 'A+' || grade == 'A',
                  child: Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _gradeColor(context, grade).withValues(alpha: 0.1),
                      child: Text(
                        grade,
                        style: TextStyle(
                        color: _gradeColor(context, grade), fontSize: 16, fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.examName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(r.subject, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                      Text(AppDateUtils.formatDate(r.examDate),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${r.marks.toStringAsFixed(0)}/${r.totalMarks.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800)),
                      Text('${r.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(color: _gradeColor(context, grade), fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: (150 + e.key * 50).ms);
              }),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
