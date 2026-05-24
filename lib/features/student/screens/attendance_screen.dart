// lib/features/student/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../models/attendance_model.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/stat_card.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attAsync = ref.watch(studentAttendanceProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'My Attendance'),
      body: attAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          final total   = records.length;
          final present = records.where((r) => r.status == AttendanceStatus.present).length;
          final absent  = records.where((r) => r.status == AttendanceStatus.absent).length;
          final late    = records.where((r) => r.status == AttendanceStatus.late).length;
          final percent = total > 0 ? (present / total * 100) : 0.0;
          final pColor  = percent >= 75 ? Colors.green
              : percent >= 60 ? Colors.orange : Theme.of(context).colorScheme.error;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              PremiumCard(
                showGoldBorder: true,
                elevation: 3,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  CircularPercentIndicator(
                    radius: 52, lineWidth: 8,
                    percent: (percent / 100).clamp(0.0, 1.0),
                    center: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${percent.toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: pColor)),
                      Text('Overall', style: TextStyle(fontSize: 9, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                    ]),
                    progressColor: pColor,
                    backgroundColor: pColor.withValues(alpha: 0.1),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  Column(children: [
                    _AttStat('$present', 'Present', Colors.green),
                    const SizedBox(height: 12),
                    _AttStat('$absent',  'Absent',  Theme.of(context).colorScheme.error),
                    const SizedBox(height: 12),
                    _AttStat('$late',    'Late',    Colors.orange),
                  ]),
                ]),
              ).animate().fadeIn(),
              const SizedBox(height: 20),

              // Stats row
              Row(children: [
                Expanded(child: StatCard(
                  label: 'Total Classes', value: '$total',
                  icon: Icons.class_rounded, iconColor: Theme.of(context).colorScheme.secondary, iconBg: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                )),
                const SizedBox(width: 10),
                Expanded(child: StatCard(
                  label: 'Present', value: '$present',
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green, iconBg: Colors.green.withValues(alpha: 0.1),
                  valueColor: Colors.green,
                )),
              ]).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              const SectionHeader(title: 'Attendance History').animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),

              if (records.isEmpty)
                Center(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No attendance records yet.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                  )),
                )
              else
                ...records.map((r) => _AttendanceTile(record: r)
                    .animate().fadeIn(delay: 200.ms)),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _AttStat extends StatelessWidget {
  final String value; final String label; final Color color;
  const _AttStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text('$value $label', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
  ]);
}

class _AttendanceTile extends StatelessWidget {
  final AttendanceModel record;
  const _AttendanceTile({required this.record});

  Color _color(BuildContext context) {
    switch (record.status) {
      case AttendanceStatus.present: return Colors.green;
      case AttendanceStatus.absent:  return Theme.of(context).colorScheme.error;
      case AttendanceStatus.late:    return Colors.orange;
    }
  }

  IconData get _icon {
    switch (record.status) {
      case AttendanceStatus.present: return Icons.check_circle_rounded;
      case AttendanceStatus.absent:  return Icons.cancel_rounded;
      case AttendanceStatus.late:    return Icons.watch_later_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: _color(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon, color: _color(context), size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(record.subject, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        Text(AppDateUtils.formatDate(record.date),
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(record.status.label,
            style: TextStyle(color: _color(context), fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}
