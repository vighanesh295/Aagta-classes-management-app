// lib/features/student/screens/student_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/premium_card.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(currentUserProvider).valueOrNull;
    final student = ref.watch(currentStudentProvider).valueOrNull;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          centerTitle: true,
          title: Image.asset(AppAssets.logo, height: 32, fit: BoxFit.contain),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
          actions: const [],
          flexibleSpace: FlexibleSpaceBar(
            background: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 80),
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                      blurRadius: 16,
                    )],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    backgroundImage: student?.photoUrl != null
                        ? NetworkImage(student!.photoUrl!) : null,
                    child: student?.photoUrl == null
                        ? Text((user?.name ?? 'S')[0].toUpperCase(),
                            style: TextStyle(fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.secondary))
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(user?.name ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                if (student?.studentId != null)
                  Text('ID: ${student!.studentId}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        fontSize: 12,
                      )),
              ]),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Batch/Course chips
            if (student != null) Wrap(spacing: 8, children: [
              if (student.batchName != null)
                _InfoChip(student.batchName!, Icons.groups_rounded, Theme.of(context).colorScheme.secondary),
              if (student.course != null)
                _InfoChip(student.course!, Icons.school_rounded, Colors.blue),
            ]).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            // Attendance card
            PremiumCard(
              showGoldBorder: true,
              child: Row(children: [
                CircularPercentIndicator(
                  radius: 40, lineWidth: 6,
                  percent: ((student?.attendancePercent ?? 0) / 100).clamp(0.0, 1.0),
                  center: Text(
                    '${(student?.attendancePercent ?? 0).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.secondary),
                  ),
                  progressColor: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Attendance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Enrolled: ${AppDateUtils.formatDate(student?.enrolledAt ?? DateTime.now())}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 12)),
                ]),
              ]),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),

            // Contact Information
            _SectionCard(
              title: 'Contact Information',
              icon: Icons.contact_phone_rounded,
              children: [
                _InfoRow(Icons.email_outlined, 'Email', user?.email ?? 'â€”'),
                _InfoRow(Icons.phone_outlined, 'Phone', student?.phone ?? 'â€”'),
                _InfoRow(Icons.location_on_outlined, 'Address', student?.address ?? 'â€”'),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),

            // Academic Information
            _SectionCard(
              title: 'Academic Information',
              icon: Icons.school_outlined,
              children: [
                _InfoRow(Icons.class_outlined,  'Course',    student?.course    ?? 'â€”'),
                _InfoRow(Icons.groups_outlined, 'Batch',     student?.batchName ?? 'â€”'),
                _InfoRow(Icons.book_outlined,   'Education', student?.education ?? 'â€”'),
              ],
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 12),

            // Parent Contact
            _SectionCard(
              title: 'Parent/Guardian',
              icon: Icons.family_restroom_rounded,
              children: [
                _InfoRow(Icons.person_outline, 'Parent Name', student?.parentName  ?? 'â€”'),
                _InfoRow(Icons.phone_outlined, 'Parent Phone', student?.parentPhone ?? 'â€”'),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),

            // Achievements
            if (student != null && student.achievements.isNotEmpty) ...[
              _SectionCard(
                title: 'Achievements',
                icon: Icons.emoji_events_rounded,
                children: [
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: student.achievements.map((a) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(a, style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    )).toList(),
                  ),
                ],
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _InfoChip(this.label, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) => PremiumCard(
    padding: const EdgeInsets.all(0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
      const Divider(height: 1),
      ...children,
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, size: 18),
      const SizedBox(width: 12),
      SizedBox(width: 90,
          child: Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 13))),
      Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]),
  );
}
