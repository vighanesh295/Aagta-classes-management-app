import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/notification_model.dart';

class NotificationService {
  final _client = Supabase.instance.client;

  // Stream unread count for bell badge
  Stream<int> watchUnreadCount(String userId) {
    if (userId.isEmpty) return Stream.value(0);
    return _client.from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.where((r) => r['is_read'] == false).length);
  }

  // Stream all notifications for a user
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _client.from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((d) => NotificationModel.fromMap(d)).toList());
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  // Mark all as read for a user
  Future<void> markAllAsRead(String userId) async {
    await _client.from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // Save FCM token for this device
  Future<void> savePushToken(String userId, String token, String platform) async {
    await _client.from('push_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
    });
  }
}
