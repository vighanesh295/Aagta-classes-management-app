// lib/features/student/screens/student_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../routes/app_router.dart';
import '../../../models/fee_model.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});
  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _idx = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _StudentDrawer(name: user?.name),
      body: _idx == 0 ? _HomeTab(scaffoldKey: _scaffoldKey) : const SizedBox(),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final color = isSelected ? const Color(0xFFFB8B24) : theme.colorScheme.onSurface.withValues(alpha: 0.5);
          
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index].$1, color: color, size: isSelected ? 26 : 24),
                const SizedBox(height: 4),
                Text(items[index].$2, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFFB8B24) : Colors.transparent,
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
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _HomeTab({required this.scaffoldKey});

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
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFB8B24), Color(0xFFFF6B35)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 170, height: 170,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  Positioned(
                    bottom: -30, right: -20,
                    child: Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 16),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => context.push(Routes.profile),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: student?.photoUrl != null
                              ? CachedNetworkImageProvider(student!.photoUrl!) : null,
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
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_outlined, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Batch: ${student!.batchName!}',
                                      style: const TextStyle(color: Colors.white,
                                          fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
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
                ],
              ),
            ),
          ),
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
            _SectionHeader(
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
              _SectionHeader(
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
              const _SectionHeader(title: AppStrings.announcements)
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFFFB8B24), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(color: Color(0xFFFB8B24), fontSize: 13, fontWeight: FontWeight.w700)),
          ),
      ],
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFB8B24).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFFFB8B24), size: 18),
                const SizedBox(width: 8),
                Text(AppStrings.feeStatus,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 14),
              if (rem == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Text('All Paid', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w700)),
                )
              else ...[
                _row(context, 'Total', _fmt(total)),
                const SizedBox(height: 6),
                _row(context, 'Paid',  _fmt(paid)),
                const SizedBox(height: 6),
                _row(context, 'Due',   _fmt(rem), highlight: rem > 0),
              ],
            ],
          )),
          const SizedBox(width: 16),
          CircularPercentIndicator(
            radius: 46, lineWidth: 6,
            percent: (pct / 100).clamp(0.0, 1.0),
            center: Text('${pct.toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFFFB8B24),
                    fontSize: 13, fontWeight: FontWeight.w800)),
            linearGradient: const LinearGradient(colors: [Color(0xFFFB8B24), Color(0xFFFF6B35)]),
            backgroundColor: const Color(0xFFFB8B24).withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, String l, String v, {bool highlight = false}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
        Text(v, style: TextStyle(
          color: highlight ? const Color(0xFFD94040) : Theme.of(context).colorScheme.onSurface,
          fontSize: 13, fontWeight: FontWeight.w700,
        )),
      ]);
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      children: items.map((a) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFB8B24).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.push(a.$3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD7B8), width: 1.5),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF4EB), Color(0xFFFFE0C2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.$2, color: const Color(0xFFFB8B24), size: 24),
                ),
                const SizedBox(height: 8),
                Text(a.$1, style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, height: 1.2),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final double percent;
  const _AttendanceCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isCritical = percent < 75;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFB8B24).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(children: [
        CircularPercentIndicator(
          radius: 42, lineWidth: 7,
          percent: (percent / 100).clamp(0.0, 1.0),
          center: Text('${percent.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, 
                  color: isCritical ? const Color(0xFFD94040) : Colors.green)),
          linearGradient: isCritical 
              ? const LinearGradient(colors: [Color(0xFFD94040), Color(0xFFFF6B35)])
              : const LinearGradient(colors: [Colors.green, Color(0xFF4ADE80)]),
          backgroundColor: (isCritical ? const Color(0xFFD94040) : Colors.green).withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Overall Attendance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (isCritical)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Critical! Attend more classes.',
                  style: TextStyle(color: Color(0xFFD94040), fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else
            Text(
              percent >= 75 ? 'Great! Keep it up.' : 'Needs improvement.',
              style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dueSoon ? const Color(0xFFFB8B24) : const Color(0xFFFFD7B8), width: dueSoon ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFB8B24).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: dueSoon ? const Color(0xFFFFF4EB) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_rounded,
              color: dueSoon ? const Color(0xFFFB8B24) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Installment #${inst.installmentNo}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(AppDateUtils.dueDateLabel(inst.dueDate),
              style: TextStyle(fontSize: 11,
                  color: dueSoon ? const Color(0xFFFB8B24) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey,
                  fontWeight: dueSoon ? FontWeight.w600 : FontWeight.w400)),
        ])),
        Text('₹${inst.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFB8B24), fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final dynamic ann;
  const _AnnouncementTile({required this.ann});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFD7B8), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFB8B24).withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (ann.isPinned == true)
        const Padding(padding: EdgeInsets.only(right: 8, top: 2),
            child: Icon(Icons.push_pin_rounded, color: Color(0xFFFB8B24), size: 14)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ann.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(ann.body, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
        const SizedBox(height: 6),
        Text(AppDateUtils.relativeTime(ann.createdAt),
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
      ])),
    ]),
  );
}

class _StudentDrawer extends ConsumerWidget {
  final String? name;
  const _StudentDrawer({this.name});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return Drawer(
    backgroundColor: Colors.white,
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFB8B24), Color(0xFFFF6B35)],
          ),
        ),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
                  )
                : const Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? 'Student', style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Student Account', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          )),
        ]),
      ),
      _DItem(Icons.dashboard_rounded,           'Home',           () => context.go(Routes.studentDashboard)),
      _DItem(Icons.calendar_today_rounded,      'Attendance',     () => context.push(Routes.attendance)),
      _DItem(Icons.menu_book_rounded,           'Study Material', () => context.push(Routes.studyMaterial)),
      _DItem(Icons.emoji_events_rounded,        'Results',        () => context.push(Routes.results)),
      _DItem(Icons.receipt_long_rounded,        'My Fees',        () => context.push(Routes.feeDetails)),
      _DItem(Icons.event_note_rounded,          'Schedule',       () => context.push(Routes.attendance)),
      _DItem(Icons.person_rounded,              'Profile',        () => context.push(Routes.profile)),
      const Divider(),
      _DItem(Icons.logout_rounded,              'Logout',         () {
        ref.read(authNotifierProvider.notifier).signOut();
        context.go(Routes.login);
      }),
    ]),
  );
  }
}

class _DItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: const Color(0xFF9A9A9A), size: 22),
    title: Text(label, style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700)),
    onTap: () { Navigator.pop(context); onTap(); },
  );
}
