// lib/features/admin/screens/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../models/announcement_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/golden_button.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});
  @override
  ConsumerState<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends ConsumerState<AdminAnnouncementsScreen> {
  bool _showForm = false;
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  String? _targetRole;
  bool _isPinned = false;

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    await ref.read(adminNotifierProvider.notifier).createAnnouncement(
      AnnouncementModel(
        id: '',
        title: _titleCtrl.text.trim(),
        content: _bodyCtrl.text.trim(),
        createdBy: user.uid,
        targetRole: _targetRole,
        isPinned: _isPinned,
        createdAt: DateTime.now(),
      ),
    );
    setState(() { _showForm = false; });
    _titleCtrl.clear(); _bodyCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement posted!'), backgroundColor: Colors.green),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    final annsAsync  = ref.watch(allAnnouncementsProvider);
    final adminState = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Announcements'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showForm = !_showForm),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        child: Icon(_showForm ? Icons.close_rounded : Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_showForm) ...[
            PremiumCard(
              showGoldBorder: true,
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('New Announcement', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleCtrl,
                    validator: Validators.required,
                    decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.title_rounded)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyCtrl,
                    maxLines: 4,
                    validator: Validators.required,
                    decoration: const InputDecoration(
                      labelText: 'Content *',
                      prefixIcon: Icon(Icons.notes_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _targetRole,
                    decoration: const InputDecoration(labelText: 'Audience', prefixIcon: Icon(Icons.people_outline_rounded)),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'student', child: Text('Students')),
                      DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                    ],
                    onChanged: (v) => setState(() => _targetRole = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isPinned,
                    onChanged: (v) => setState(() => _isPinned = v),
                    title: const Text('Pin Announcement'),
                    activeThumbColor: Theme.of(context).colorScheme.secondary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  GoldenButton(
                    label: 'Post Announcement',
                    isLoading: adminState.isLoading,
                    onPressed: adminState.isLoading ? null : _post,
                    icon: Icons.campaign_rounded,
                  ),
                ]),
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
          ],

          const _SectionHeader(title: 'All Announcements'),
          const SizedBox(height: 12),

          annsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
            error: (e, _) => Text('Error: $e'),
            data: (anns) {
              if (anns.isEmpty) {
                return Center(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No announcements yet.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                )),
              );
              }
              return Column(
                children: anns.asMap().entries.map((e) {
                  final a = e.value;
                  return PremiumCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    showGoldBorder: a.isPinned,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        if (a.isPinned) Icon(Icons.push_pin_rounded, color: Theme.of(context).colorScheme.secondary, size: 16),
                        if (a.isPinned) const SizedBox(width: 4),
                        Expanded(child: Text(a.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                        if (a.targetRole != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(a.targetRole!.toUpperCase(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                      ]),
                      const SizedBox(height: 6),
                      Text(a.content, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey)),
                      const SizedBox(height: 8),
                      Text(AppDateUtils.relativeTime(a.createdAt),
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 10)),
                    ]),
                  ).animate().fadeIn(delay: (e.key * 50).ms);
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 4, height: 18,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]), borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
  ]);
}
