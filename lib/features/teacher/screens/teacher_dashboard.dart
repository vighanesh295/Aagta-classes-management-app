// lib/features/teacher/screens/teacher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../models/lecture_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../routes/app_router.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});
  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user        = ref.watch(currentUserProvider).valueOrNull;
    final teacher     = ref.watch(currentTeacherProvider).valueOrNull;
    final todayAsync  = ref.watch(todayLecturesProvider);
    final allAsync    = ref.watch(teacherLecturesProvider);

    final todayLectures = todayAsync.valueOrNull ?? [];
    final allLectures   = allAsync.valueOrNull ?? [];
    final theme         = Theme.of(context);

    return Scaffold(
      drawer: _TeacherDrawer(name: user?.name),
      body: CustomScrollView(
        slivers: [
          // Sticky White Top Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.teacherTextPrimary,
            elevation: 0,
            scrolledUnderElevation: 2,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.teacherBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_rounded, color: AppColors.teacherTextSecondary, size: 24),
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: theme.textTheme.headlineLarge,
                children: const [
                  TextSpan(text: 'Teacher '),
                  TextSpan(text: 'Dashboard', style: TextStyle(color: AppColors.teacherPrimary)),
                ],
              ),
            ),
            actions: [
              _buildAppBarIcon(Icons.notifications_none_rounded, true, () => context.push(Routes.notifications)),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Welcome Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [AppColors.teacherPrimary, AppColors.teacherPrimaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teacherPrimary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text((user?.name ?? 'T')[0].toUpperCase(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Playfair Display')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back,', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontFamily: 'Nunito')),
                            Text(user?.name ?? 'Teacher',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Playfair Display')),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ADE80),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.6), blurRadius: 6),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(teacher?.subject != null ? '${teacher!.subject} Teacher' : 'Teacher', 
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(child: _TeacherStatCard(
                      label: 'Total Classes', value: '${allLectures.length}',
                      icon: Icons.calendar_month_rounded, iconBg: AppColors.teacherPrimaryPale, iconColor: AppColors.teacherPrimary, delay: 50,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _TeacherStatCard(
                      label: "Today's Classes", value: '${todayLectures.length}',
                      icon: Icons.today_rounded, iconBg: AppColors.teacherBluePale, iconColor: AppColors.teacherBlueIcon, delay: 100,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _TeacherStatCard(
                      label: 'Batches', value: '${teacher?.batches.length ?? 0}',
                      icon: Icons.groups_rounded, iconBg: AppColors.teacherGreenPale, iconColor: AppColors.teacherGreenIcon, delay: 150,
                    )),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Access Grid
                const _SectionHeader(title: 'Quick Access'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _QuickAccessCard(
                      title: 'Lecture\nSchedule', icon: Icons.event_note_rounded,
                      isActive: true, bg: AppColors.teacherPrimary, iconColor: Colors.white, delay: 200, onTap: () => context.push(Routes.lectureSchedule),
                    ),
                    _QuickAccessCard(
                      title: 'Study\nMaterials', icon: Icons.menu_book_rounded,
                      isActive: false, bg: AppColors.teacherGreenPale, iconColor: AppColors.teacherGreenIcon, delay: 250, onTap: () => context.push(Routes.studyMaterial),
                    ),
                    _QuickAccessCard(
                      title: 'Attendance', icon: Icons.fact_check_rounded,
                      isActive: false, bg: AppColors.teacherPrimaryPale, iconColor: AppColors.teacherPrimary, delay: 300, onTap: () => context.push(Routes.markAttendance),
                    ),
                    _QuickAccessCard(
                      title: 'Homework', icon: Icons.assignment_rounded,
                      isActive: false, bg: AppColors.teacherTealPale, iconColor: AppColors.teacherTealIcon, delay: 350, onTap: () => context.push(Routes.homework),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Today's Classes
                _SectionHeader(title: "Today's Classes", actionLabel: 'Schedule →', onAction: () => context.push(Routes.lectureSchedule)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.teacherCardBorder, width: 1.5),
                  ),
                  child: todayLectures.isEmpty 
                      ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("No classes scheduled today.", style: TextStyle(color: AppColors.teacherTextSecondary))))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayLectures.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.teacherCardBorder),
                          itemBuilder: (context, index) {
                            final l = todayLectures[index];
                            // Mock logic for live / next
                            final isLive = index == 0 && !l.isCancelled;
                            final isNext = index == 1 && !l.isCancelled;
                            return _ClassRow(lecture: l, isLive: isLive, isNext: isNext);
                          },
                        ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Notices Section
                _SectionHeader(title: 'Notices', actionLabel: 'View all →', onAction: () {}),
                const SizedBox(height: 16),
                const _NoticeCard(title: 'Staff meeting at 4 PM in Main Hall.', time: '2h ago', isActive: true),
                const SizedBox(height: 12),
                const _NoticeCard(title: 'Upload mid-term grades by Friday.', time: '1d ago', isActive: false),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, bool hasBadge, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.teacherBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.teacherTextSecondary, size: 22),
            if (hasBadge)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.teacherPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Components ─────────────────────────────────────────────────────────────

class _TeacherStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int delay;

  const _TeacherStatCard({required this.label, required this.value, required this.icon, required this.iconBg, required this.iconColor, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.teacherCardBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display', color: AppColors.teacherTextPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: AppColors.teacherTextSecondary), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0, duration: 400.ms);
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
            Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.teacherPrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display', color: AppColors.teacherTextPrimary)),
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: AppColors.teacherPrimary)),
          ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final Color bg;
  final Color iconColor;
  final int delay;
  final VoidCallback onTap;

  const _QuickAccessCard({required this.title, required this.icon, required this.isActive, required this.bg, required this.iconColor, required this.delay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? null : Colors.white,
            gradient: isActive ? const LinearGradient(colors: [AppColors.teacherPrimary, AppColors.teacherPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            borderRadius: BorderRadius.circular(13),
            border: isActive ? null : Border.all(color: AppColors.teacherCardBorder, width: 1.5),
            boxShadow: isActive ? [BoxShadow(color: AppColors.teacherPrimary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withValues(alpha: 0.2) : bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Nunito', height: 1.2,
                color: isActive ? Colors.white : AppColors.teacherTextSecondary,
              ), textAlign: TextAlign.center),
            ],
          ),
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final LectureModel lecture;
  final bool isLive;
  final bool isNext;

  const _ClassRow({required this.lecture, required this.isLive, required this.isNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time Column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppDateUtils.formatTime(lecture.startTime), style: const TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Nunito')),
                const SizedBox(height: 4),
                Text('${lecture.endTime.difference(lecture.startTime).inMinutes} min', style: const TextStyle(color: AppColors.teacherTextSecondary, fontSize: 11, fontFamily: 'Nunito')),
              ],
            ),
          ),
          // Colored Dot
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: isLive ? AppColors.teacherPrimary : AppColors.teacherGrayBorder,
              shape: BoxShape.circle,
              boxShadow: isLive ? [BoxShadow(color: AppColors.teacherPrimary.withValues(alpha: 0.5), blurRadius: 6)] : null,
            ),
          ),
          // Class Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lecture.subject, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${lecture.batchName} • ${lecture.room ?? 'Online'}', style: const TextStyle(color: AppColors.teacherTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          // Status Badge
          if (isLive || isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLive ? AppColors.teacherPrimaryPale : AppColors.teacherBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isLive ? '● Live' : 'Next', style: TextStyle(
                color: isLive ? AppColors.teacherPrimary : AppColors.teacherTextSecondary,
                fontSize: 11, fontWeight: FontWeight.w800,
              )),
            ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String time;
  final bool isActive;

  const _NoticeCard({required this.title, required this.time, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.teacherCardBorder, width: 1.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, decoration: BoxDecoration(color: isActive ? AppColors.teacherPrimary : AppColors.teacherGrayBorder, borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.teacherTextPrimary))),
                    const SizedBox(width: 12),
                    Text(time, style: const TextStyle(fontSize: 11, color: AppColors.teacherTextSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms);
  }
}

class _TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TeacherBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.teacherCardBorder, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(icon: Icons.home_rounded, label: 'Home', isSelected: currentIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.event_note_rounded, label: 'Schedule', isSelected: currentIndex == 1, onTap: () => onTap(1)),
            
            // Floating Center Action Button
            GestureDetector(
              onTap: () {}, // Add class/notice action
              child: Container(
                width: 52, height: 52,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.teacherPrimary, AppColors.teacherPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.teacherPrimary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
            
            _NavItem(icon: Icons.people_rounded, label: 'Students', isSelected: currentIndex == 2, onTap: () => onTap(2)),
            _NavItem(icon: Icons.person_rounded, label: 'Profile', isSelected: false, onTap: () => context.push(Routes.profile)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.teacherPrimary : AppColors.teacherTextSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontFamily: 'Nunito')),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4, height: 4,
                decoration: const BoxDecoration(color: AppColors.teacherPrimary, shape: BoxShape.circle),
              )
            else
              const SizedBox(height: 8), // Placeholder to maintain height
          ],
        ),
      ),
    );
  }
}

class _TeacherDrawer extends ConsumerWidget {
  final String? name;
  const _TeacherDrawer({this.name});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return Drawer(
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teacherPrimary, AppColors.teacherPrimaryLight],
          ),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 32, backgroundColor: Colors.white.withValues(alpha: 0.3),
            backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                ? Text((name ?? 'T')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24,
                        fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Playfair Display'))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? 'Teacher',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display')),
              const Text('Teacher', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Nunito')),
            ],
          )),
        ]),
      ),
      _DrawerItem(Icons.dashboard_rounded,        'Dashboard',  () => context.go(Routes.teacherDashboard)),
      _DrawerItem(Icons.event_note_rounded,       'Schedule',   () => context.push(Routes.lectureSchedule)),
      _DrawerItem(Icons.menu_book_rounded,      'Study Materials', () => context.push(Routes.studyMaterial)),
      _DrawerItem(Icons.fact_check_rounded,       'Attendance', () => context.push(Routes.markAttendance)),
      _DrawerItem(Icons.assignment_rounded,       'Homework',   () => context.push(Routes.homework)),
      _DrawerItem(Icons.notifications_outlined,   'Notifications', () => context.push(Routes.notifications)),
      _DrawerItem(Icons.campaign_outlined,        'Announcements', () => context.push(Routes.announcements)),
      const Divider(),
      _DrawerItem(Icons.logout_rounded,           'Logout',     () {
        ref.read(authNotifierProvider.notifier).signOut();
        context.go(Routes.login);
      }),
    ]),
  );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.teacherTextSecondary, size: 22),
    title: Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary)),
    onTap: () { Navigator.pop(context); onTap(); },
  );
}
