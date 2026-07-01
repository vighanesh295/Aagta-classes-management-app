import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/announcement_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _CreateAnnouncementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    final user = userAsync.valueOrNull;
    final canCreate = user?.role == UserRole.admin || user?.role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryOrange,
              onPressed: _showCreateBottomSheet,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No announcements yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(announcementsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final ann = announcements[index];
                return _AnnouncementCard(announcement: ann, currentUser: user);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _AnnouncementCard extends ConsumerStatefulWidget {
  final AnnouncementModel announcement;
  final UserModel? currentUser;

  const _AnnouncementCard({required this.announcement, this.currentUser});

  @override
  ConsumerState<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends ConsumerState<_AnnouncementCard> {
  bool _expanded = false;

  void _delete() async {
    try {
      await ref.read(announcementServiceProvider).delete(widget.announcement.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ann = widget.announcement;
    final canManage = widget.currentUser?.role == UserRole.admin || widget.currentUser?.uid == ann.createdBy;

    Widget cardContent = Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      color: ann.isPinned ? const Color(0xFFFFF4EB) : Colors.white,
      child: Container(
        decoration: ann.isPinned
            ? const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.primaryOrange, width: 4)),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              )
            : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ann.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E)),
                  ),
                ),
                if (ann.isPinned)
                  const Icon(Icons.push_pin, size: 16, color: AppColors.primaryOrange),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ann.body,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            if (ann.body.length > 100)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ann.creatorRole == 'admin' ? AppColors.primaryOrange.withValues(alpha: 0.1) : Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${ann.creatorName ?? 'User'} (${ann.creatorRole ?? 'Unknown'})',
                    style: TextStyle(
                      fontSize: 12,
                      color: ann.creatorRole == 'admin' ? AppColors.primaryOrange : Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(ann.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (ann.target == 'batch' && ann.batch != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Batch: ${ann.batch}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ),
              ),
          ],
        ),
      ),
    );

    if (canManage) {
      return Dismissible(
        key: Key(ann.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          margin: const EdgeInsets.only(bottom: 12),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Announcement?'),
              content: const Text('Are you sure you want to delete this announcement?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
        onDismissed: (_) => _delete(),
        child: cardContent,
      );
    }
    return cardContent;
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 1) return DateFormat('MMM d, yyyy').format(d);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}

class _CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  ConsumerState<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends ConsumerState<_CreateAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _target = 'global';
  String? _batch;
  bool _isPinned = false;
  bool _isLoading = false;

  void _post() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and body are required')));
      return;
    }
    if (_target == 'batch' && (_batch == null || _batch!.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batch name is required for batch target')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Announcement?'),
        content: const Text('This will notify users immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Post', style: TextStyle(color: AppColors.primaryOrange))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;

      final ann = AnnouncementModel(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        createdBy: user.uid,
        creatorName: user.name,
        creatorRole: user.role.name,
        target: _target,
        batch: _target == 'batch' ? _batch?.trim() : null,
        isPinned: _isPinned,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(announcementServiceProvider).createAnnouncement(ann);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement posted successfully!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Create Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Target:'),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Everyone'),
                selected: _target == 'global',
                onSelected: (val) => setState(() {
                  _target = 'global';
                  _batch = null;
                }),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Specific Batch'),
                selected: _target == 'batch',
                onSelected: (val) => setState(() => _target = 'batch'),
              ),
            ],
          ),
          if (_target == 'batch') ...[
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => _batch = val,
              decoration: const InputDecoration(labelText: 'Batch Name (e.g. Batch A)', border: OutlineInputBorder()),
            ),
          ],
          if (isAdmin) ...[
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Pin Announcement'),
              value: _isPinned,
              onChanged: (val) => setState(() => _isPinned = val),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _isLoading ? null : _post,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Post Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
