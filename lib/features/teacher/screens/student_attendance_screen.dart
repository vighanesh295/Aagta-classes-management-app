// lib/features/teacher/screens/student_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../../../models/attendance_model.dart';
import '../../../models/student_model.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../widgets/golden_button.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});
  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  final Map<String, AttendanceStatus> _statuses = {};
  bool _saving = false;
  String? _selectedLectureId;

  void _toggle(String uid) {
    setState(() {
      final current = _statuses[uid] ?? AttendanceStatus.present;
      _statuses[uid] = current == AttendanceStatus.present
          ? AttendanceStatus.absent
          : AttendanceStatus.present;
    });
  }

  Future<void> _save(List<StudentModel> students) async {
    if (_selectedLectureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a lecture first.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final batch = FirebaseService.instance.firestore.batch();
      final now = DateTime.now();
      for (final s in students) {
        final ref = FirebaseService.instance.attendance.doc();
        final status = _statuses[s.uid] ?? AttendanceStatus.present;
        batch.set(ref, AttendanceModel(
          id:        ref.id,
          studentId: s.uid,
          lectureId: _selectedLectureId!,
          subject:   'Class',
          date:      now,
          status:    status,
        ).toMap());
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);
    final lecturesAsync = ref.watch(todayLecturesProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Mark Attendance'),
      body: studentsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          // Init default statuses
          for (final s in students) {
            _statuses.putIfAbsent(s.uid, () => AttendanceStatus.present);
          }
          final present = _statuses.values.where((s) => s == AttendanceStatus.present).length;

          return Column(children: [
            // Lecture selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: lecturesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (lectures) => lectures.isEmpty
                    ? Center(
                        child: Text('No lectures today.',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)))
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedLectureId,
                        decoration: const InputDecoration(
                          labelText: 'Select Lecture',
                          prefixIcon: Icon(Icons.class_rounded),
                        ),
                        items: lectures.map((l) => DropdownMenuItem(
                          value: l.id,
                          child: Text('${l.subject} â€“ ${l.batchName}'),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedLectureId = v),
                      ),
              ),
            ),

            // Stats bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _Badge('$present Present', Colors.green),
                const SizedBox(width: 10),
                _Badge('${students.length - present} Absent', Theme.of(context).colorScheme.error),
              ]),
            ),
            const SizedBox(height: 12),

            // Student list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: students.length,
                itemBuilder: (_, i) {
                  final s = students[i];
                  final isPresent = (_statuses[s.uid] ?? AttendanceStatus.present)
                      == AttendanceStatus.present;
                  return PremiumCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    showGoldBorder: isPresent,
                    onTap: () => _toggle(s.uid),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isPresent
                            ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        child: Text(s.name[0].toUpperCase(), style: TextStyle(
                            color: isPresent ? Colors.green : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700)),
                        Text(s.studentId, style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 11)),
                      ])),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPresent ? Colors.green : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Center(child: Text(
                          isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            color: isPresent ? Colors.green : Theme.of(context).colorScheme.error,
                            fontSize: 11, fontWeight: FontWeight.w700,
                          ),
                        )),
                      ),
                    ]),
                  ).animate().fadeIn(delay: (i * 30).ms);
                },
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: GoldenButton(
                label: 'Save Attendance',
                isLoading: _saving,
                onPressed: _saving ? null : () => _save(students),
                icon: Icons.save_rounded,
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
  );
}
