// lib/features/student/screens/student_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/stat_card.dart';
import '../../../models/fee_model.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});
  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _idx == 0 ? const _HomeTab() : const SizedBox(),
      bottomNavigationBar: _BottomNav(
        currentIndex: _idx,
        onTap: (i) {
          if (i == 1) { context.push(Routes.attendance); return; }
          if (i == 2) { context.push(Routes.notifications); return; }
          if (i == 3) { context.push(Routes.profile); return; }
          setState(() => _idx = i);
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (Icons.dashboard_rounded, 'Home'),
      (Icons.calendar_today_rounded, 'Attendance'),
      (Icons.notifications_rounded, 'Alerts'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5);
          
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index].$1, color: color, size: 24),
                const SizedBox(height: 4),
                Text(items[index].$2, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user    = ref.watch(currentUserProvider).valueOrNull;
    final student = ref.watch(currentStudentProvider).valueOrNull;
    final fee     = ref.watch(studentFeeProvider).valueOrNull;
    final insts   = ref.watch(studentInstallmentsProvider).valueOrNull ?? [];
    final notifs  = ref.watch(studentNotificationsProvider).valueOrNull ?? [];
    final anns    = ref.watch(announcementsProvider).valueOrNull ?? [];

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 160, pinned: true, elevation: 0,
          centerTitle: true,
          title: Image.asset(AppAssets.logo, height: 36, fit: BoxFit.contain),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 16),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.push(Routes.profile),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: student?.photoUrl != null
                        ? NetworkImage(student!.photoUrl!) : null,
                    child: student?.photoUrl == null
                        ? Text((user?.name ?? 'S')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.w800, color: Colors.white))
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Welcome back,',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(user?.name ?? 'Student',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 18, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis),
                    if (student?.batchName != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(student!.batchName!,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                  ],
                )),
                Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => context.push(Routes.notifications),
                  ),
                  if (notifs.any((n) => !n.isRead))
                    Positioned(right: 12, top: 12,
                        child: Container(width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error, shape: BoxShape.circle))),
                ]),
              ]),
            ),
          ),
          actions: const [],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Fee Card
            _FeeSummaryCard(fee: fee, onTap: () => context.push(Routes.feeDetails))
                .animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            // Quick Actions
            _QuickActions().animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),

            // Attendance
            SectionHeader(
              title: AppStrings.attendance,
              actionLabel: 'View All',
              onAction: () => context.push(Routes.attendance),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 12),
            _AttendanceCard(percent: student?.attendancePercent ?? 0)
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),

            // Installments due
            if (insts.where((i) => i.status.label != 'Paid').isNotEmpty) ...[
              SectionHeader(
                title: 'Upcoming Installments',
                actionLabel: 'All',
                onAction: () => context.push(Routes.feeDetails),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 10),
              ...insts.where((i) => i.status.label != 'Paid').take(2).map((inst) =>
                _InstallmentTile(inst: inst).animate().fadeIn(delay: 400.ms)),
              const SizedBox(height: 20),
            ],

            // Announcements
            if (anns.isNotEmpty) ...[
              const SectionHeader(title: AppStrings.announcements)
                  .animate().fadeIn(delay: 430.ms),
              const SizedBox(height: 10),
              ...anns.take(3).map((a) =>
                _AnnouncementTile(ann: a).animate().fadeIn(delay: 460.ms)),
            ],

            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }
}

class _FeeSummaryCard extends StatelessWidget {
  final dynamic fee;
  final VoidCallback onTap;
  const _FeeSummaryCard({this.fee, required this.onTap});
  String _fmt(double v) =>
      v >= 1000 ? '₹${(v / 1000).toStringAsFixed(1)}K' : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final total   = (fee?.totalFees   ?? 0.0) as double;
    final paid    = (fee?.paidAmount  ?? 0.0) as double;
    final rem     = (fee?.remaining   ?? 0.0) as double;
    final pct     = (fee?.paidPercent ?? 0.0) as double;

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.feeStatus,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 14),
            _row(context, 'Total', _fmt(total)),
            const SizedBox(height: 6),
            _row(context, 'Paid',  _fmt(paid)),
            const SizedBox(height: 6),
            _row(context, 'Due',   _fmt(rem), highlight: rem > 0),
          ],
        )),
        const SizedBox(width: 16),
        CircularPercentIndicator(
          radius: 46, lineWidth: 6,
          percent: (pct / 100).clamp(0.0, 1.0),
          center: Text('${pct.toStringAsFixed(0)}%',
              style: TextStyle(color: Theme.of(context).colorScheme.primary,
                  fontSize: 13, fontWeight: FontWeight.w800)),
          progressColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ]),
    );
  }

  Widget _row(BuildContext context, String l, String v, {bool highlight = false}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
        Text(v, style: TextStyle(
          color: highlight ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
          fontSize: 13, fontWeight: FontWeight.w700,
        )),
      ]);
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final items = [
      ('Study\nMaterial', Icons.menu_book_rounded,    Routes.studyMaterial),
      ('Results',         Icons.emoji_events_rounded, Routes.results),
      ('My Fees',         Icons.receipt_long_rounded, Routes.feeDetails),
      ('Schedule',        Icons.event_note_rounded,   Routes.attendance),
    ];
    return GridView.count(
      crossAxisCount: 4, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
      children: items.map((a) => GestureDetector(
        onTap: () => context.push(a.$3),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor, width: 1.5),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(a.$2, color: primary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(a.$1, style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface, height: 1.2),
                textAlign: TextAlign.center),
          ]),
        ),
      )).toList(),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final double percent;
  const _AttendanceCard({required this.percent});
  Color _statusColor(BuildContext context) => percent >= 75 ? Colors.green
      : percent >= 60 ? Colors.orange : Theme.of(context).colorScheme.error;

  @override
  Widget build(BuildContext context) {
    final c = _statusColor(context);
    return PremiumCard(
      elevation: 2,
      child: Row(children: [
        CircularPercentIndicator(
          radius: 42, lineWidth: 7,
          percent: (percent / 100).clamp(0.0, 1.0),
          center: Text('${percent.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c)),
          progressColor: c, backgroundColor: c.withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Overall Attendance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            percent >= 75 ? 'Great! Keep it up.'
                : percent >= 60 ? 'Needs improvement.'
                : 'Critical! Attend more classes.',
            style: TextStyle(color: c, fontSize: 12),
          ),
        ])),
      ]),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  final dynamic inst;
  const _InstallmentTile({required this.inst});

  @override
  Widget build(BuildContext context) {
    final days    = AppDateUtils.daysUntil(inst.dueDate);
    final dueSoon = days >= 0 && days <= 5;
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 8),
      showAccentBorder: dueSoon,
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: dueSoon ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_rounded,
              color: dueSoon ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Installment #${inst.installmentNo}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(AppDateUtils.dueDateLabel(inst.dueDate),
              style: TextStyle(fontSize: 11,
                  color: dueSoon ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey,
                  fontWeight: dueSoon ? FontWeight.w600 : FontWeight.w400)),
        ])),
        Text('₹${inst.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final dynamic ann;
  const _AnnouncementTile({required this.ann});

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (ann.isPinned == true)
        Padding(padding: const EdgeInsets.only(right: 8, top: 2),
            child: Icon(Icons.push_pin_rounded, color: Theme.of(context).colorScheme.primary, size: 14)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ann.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(ann.content, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
        const SizedBox(height: 6),
        Text(AppDateUtils.relativeTime(ann.createdAt),
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
      ])),
    ]),
  );
}
