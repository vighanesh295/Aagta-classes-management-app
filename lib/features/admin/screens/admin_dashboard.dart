// lib/features/admin/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';

// ── Colors ─────────────────────────────────────────────────────────────
const _orangePrimary = Color(0xFFF97316);
const _orangeLight   = Color(0xFFFB923C);
const _background    = Color(0xFFF1F1F1);
const _cardBg        = Color(0xFFFFFFFF);
const _cardBorder    = Color(0xFFE5E5E5);
const _textPrimary   = Color(0xFF1F2937);
const _textSecondary = Color(0xFF9A9A9A);

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: _background,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _background,
        drawer: _AdminDrawer(name: user?.name),
        body: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: CustomScrollView(
                  slivers: [
                    // ── 1. Sticky Top Bar ─────────────────────────────────
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      toolbarHeight: 70,
                      titleSpacing: 15,
                      title: Row(
                        children: [
                          _SquareIconButton(
                            icon: Icons.menu_rounded,
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Admin ',
                                    style: GoogleFonts.playfairDisplay(
                                      color: _textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Dashboard',
                                    style: GoogleFonts.playfairDisplay(
                                      color: _orangePrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              _SquareIconButton(
                                icon: Icons.notifications_none_rounded,
                                onTap: () => context.push(Routes.announcements),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: _orangePrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 18),
                          
                          // ── 2. Welcome Hero Card ──────────────────────────
                          const _WelcomeHeroCard()
                              .animate()
                              .slideY(begin: -0.1, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
                              .fadeIn(duration: 500.ms),
                          
                          const SizedBox(height: 18),

                          // ── 3. Analytics Overview ───────────────────────
                          const _SectionHeader(title: 'Analytics Overview', actionText: 'See all →'),
                          const SizedBox(height: 12),
                          const _AnalyticsBanner(),

                          const SizedBox(height: 18),

                          // ── 4. Quick Access ─────────────────────────────
                          const _SectionHeader(title: 'Quick Access'),
                          const SizedBox(height: 12),
                          const _QuickAccessGrid(),

                          const SizedBox(height: 18),

                          // ── 5. Recent Activity ──────────────────────────
                          const _SectionHeader(title: 'Recent Activity', actionText: 'View all →'),
                          const SizedBox(height: 12),
                          const _RecentActivityList(),

                          const SizedBox(height: 90), // Space for bottom nav
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 6. Bottom Navigation Bar ─────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: _BottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (idx) => setState(() => _currentIndex = idx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _textPrimary, size: 20),
      ),
    );
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  const _WelcomeHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_orangePrimary, _orangeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          transform: GradientRotation(135 * 3.14159 / 180),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(249, 115, 22, 0.28),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 170, height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30, right: -20,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,',
                            style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('Administrator',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Color(0xFF4ADE80), blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Full Access Granted',
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom Row Stats
                const Row(
                  children: [
                    Expanded(child: _HeroStatChip(number: '248', label: 'STUDENTS')),
                    SizedBox(width: 8),
                    Expanded(child: _HeroStatChip(number: '18', label: 'TEACHERS')),
                    SizedBox(width: 8),
                    Expanded(child: _HeroStatChip(number: '6', label: 'BATCHES')),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final String number;
  final String label;

  const _HeroStatChip({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(number, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.9), fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const _SectionHeader({required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: _orangePrimary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.playfairDisplay(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        if (actionText != null)
          Text(actionText!, style: GoogleFonts.nunito(color: _orangePrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AnalyticsBanner extends StatelessWidget {
  const _AnalyticsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFBCAAC)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: _orangePrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Permission Error: Firestore rules need to be updated. Please contact your developer.',
                style: GoogleFonts.nunito(color: const Color(0xFFC05621), fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Manage Students', 'icon': Icons.groups_rounded, 'iconBg': const Color(0xFFEAF2FF), 'iconColor': const Color(0xFF3A7BD5), 'route': Routes.manageStudents},
      {'title': 'Manage Teachers', 'icon': Icons.person_rounded, 'iconBg': const Color(0xFFE8F8EE), 'iconColor': const Color(0xFF2EA86B), 'route': Routes.manageTeachers},
      {'title': 'Fee Management',  'icon': Icons.credit_card_rounded, 'iconBg': _orangePrimary, 'iconColor': Colors.white, 'route': Routes.manageFees, 'isFeatured': true},
      {'title': 'Analytics',       'icon': Icons.bar_chart_rounded,   'iconBg': const Color(0xFFF2EEFF), 'iconColor': const Color(0xFF7C5CBF), 'route': Routes.analytics},
      {'title': 'Batch Management','icon': Icons.calendar_month_rounded,'iconBg': const Color(0xFFE5F7F6), 'iconColor': const Color(0xFF1A9E94), 'route': Routes.batchManagement},
      {'title': 'Announcements',   'icon': Icons.notifications_active_rounded, 'iconBg': const Color(0xFFFFECEC), 'iconColor': const Color(0xFFD94040), 'route': Routes.announcements},
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isFeatured = item['isFeatured'] == true;
        
        Widget cardContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: item['iconBg'] as Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item['icon'] as IconData, color: item['iconColor'] as Color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item['title'] as String,
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 2,
              style: GoogleFonts.nunito(
                color: isFeatured ? Colors.white : const Color(0xFF555555),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        );

        Widget card = GestureDetector(
          onTap: () => context.push(item['route'] as String),
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 14, left: 8, right: 8),
            decoration: BoxDecoration(
              color: isFeatured ? null : _cardBg,
              gradient: isFeatured ? const LinearGradient(
                colors: [_orangePrimary, _orangeLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ) : null,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: isFeatured ? Colors.transparent : _cardBorder, width: 1.5),
              boxShadow: isFeatured ? const [
                BoxShadow(color: Color.fromRGBO(249, 115, 22, 0.3), blurRadius: 12, offset: Offset(0, 6))
              ] : const [],
            ),
            child: cardContent,
          ),
        );

        return card.animate().fadeIn(delay: (i * 50).ms).slideY(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'text': 'New student enrollment request received', 'time': '2m ago', 'color': _orangePrimary},
      {'text': 'Fee payment received — Batch A', 'time': '1h ago', 'color': const Color(0xFFD1D5DB)},
      {'text': 'Teacher schedule updated', 'time': '3h ago', 'color': const Color(0xFFD1D5DB)},
    ];

    return Column(
      children: activities.map((act) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _cardBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 4, height: 36,
                decoration: BoxDecoration(
                  color: act['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(act['text'] as String,
                  style: GoogleFonts.nunito(color: const Color(0xFF555555), fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(act['time'] as String,
                style: GoogleFonts.nunito(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _cardBorder, width: 1)),
        boxShadow: [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', isSelected: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.people_rounded, label: 'Users', isSelected: currentIndex == 1, onTap: () => onTap(1)),
              const SizedBox(width: 60), // FAB space
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Fees', isSelected: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isSelected: false, onTap: () => context.push(Routes.profile)),
            ],
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [_orangePrimary, _orangeLight]),
                  boxShadow: [
                    BoxShadow(color: Color.fromRGBO(249, 115, 22, 0.40), blurRadius: 12, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
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
    final color = isSelected ? _orangePrimary : const Color(0xFFBDBDBD);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.nunito(color: isSelected ? _orangePrimary : _textSecondary, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
            const SizedBox(height: 4),
            if (isSelected)
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: _orangePrimary, shape: BoxShape.circle))
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

// ── Drawer ──────────────────────────────────────────────────────────────────
class _AdminDrawer extends ConsumerWidget {
  final String? name;
  const _AdminDrawer({this.name});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) => Drawer(
    backgroundColor: Colors.white,
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_orangePrimary, _orangeLight],
          ),
        ),
        child: Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? 'Admin', style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Administrator', style: GoogleFonts.nunito(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          )),
        ]),
      ),
      _DItem(Icons.dashboard_rounded,           'Dashboard',      () => context.go(Routes.adminDashboard)),
      _DItem(Icons.people_rounded,              'Students',       () => context.push(Routes.manageStudents)),
      _DItem(Icons.person_rounded,              'Teachers',       () => context.push(Routes.manageTeachers)),
      _DItem(Icons.account_balance_wallet_rounded,'Fee Management',() => context.push(Routes.manageFees)),
      _DItem(Icons.bar_chart_rounded,           'Analytics',      () => context.push(Routes.analytics)),
      _DItem(Icons.groups_rounded,              'Batches',        () => context.push(Routes.batchManagement)),
      _DItem(Icons.campaign_rounded,            'Announcements',  () => context.push(Routes.announcements)),
      const Divider(),
      _DItem(Icons.logout_rounded,              'Logout',         () {
        ref.read(authNotifierProvider.notifier).signOut();
        context.go(Routes.login);
      }),
    ]),
  );
}

class _DItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: _textSecondary, size: 22),
    title: Text(label, style: GoogleFonts.nunito(color: _textPrimary, fontWeight: FontWeight.w700)),
    onTap: () { Navigator.pop(context); onTap(); },
  );
}

