import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../models/notification_model.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../widgets/premium_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(studentNotificationsProvider);

    return Scaffold(
      appBar: const GoldenAppBar(title: 'Notifications'),
      body: notifsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary)),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Opacity(
                opacity: 0.35,
                child: Image.asset(AppAssets.logo, width: 160, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              Text('No notifications yet.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))),
              const SizedBox(height: 6),
              Text('You\'re all caught up!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4))),
            ]).animate().fadeIn(),
          );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (_, i) {
              final n = notifs[i];
              return _NotifCard(notif: n).animate().fadeIn(delay: (i * 50).ms);
            },
          );
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  const _NotifCard({required this.notif});

  IconData get _icon {
    switch (notif.type) {
      case 'fee_reminder':  return Icons.account_balance_wallet_rounded;
      case 'announcement':  return Icons.campaign_rounded;
      case 'result':        return Icons.emoji_events_rounded;
      default:              return Icons.notifications_rounded;
    }
  }

  Color _color(BuildContext context) {
    switch (notif.type) {
      case 'fee_reminder':  return Colors.orange;
      case 'announcement':  return Theme.of(context).colorScheme.secondary;
      case 'result':        return Colors.green;
      default:              return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) => PremiumCard(
    margin: const EdgeInsets.only(bottom: 10),
    showGoldBorder: !notif.isRead,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _color(context).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon, color: _color(context), size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(notif.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
              ))),
          if (!notif.isRead)
            Container(width: 8, height: 8,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 4),
        Text(notif.body, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(AppDateUtils.relativeTime(notif.createdAt),
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, fontSize: 10)),
      ])),
    ]),
  );
}
