import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              final user = ref.read(currentUserProvider).valueOrNull;
              if (user != null) {
                ref.read(notificationServiceProvider).markAllAsRead(user.uid);
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(notificationsProvider.future);
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationTile(notification: notif);
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

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;

    return ListTile(
      tileColor: isUnread ? AppColors.primaryOrange.withValues(alpha: 0.05) : null,
      leading: CircleAvatar(
        backgroundColor: _getColorForType(notification.type).withValues(alpha: 0.1),
        child: Icon(_getIconForType(notification.type), color: _getColorForType(notification.type)),
      ),
      title: Text(
        notification.title,
        style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.message, style: TextStyle(color: isUnread ? Colors.black87 : Colors.black54)),
          const SizedBox(height: 4),
          Text(_timeAgo(notification.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      onTap: () {
        if (isUnread) {
          ref.read(notificationServiceProvider).markAsRead(notification.id);
        }
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'announcement': return Icons.campaign;
      case 'fee': return Icons.payment;
      case 'result': return Icons.grade;
      default: return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'announcement': return AppColors.primaryOrange;
      case 'fee': return Colors.red;
      case 'result': return Colors.green;
      default: return Colors.blue;
    }
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
