import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/notification_service.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final unreadCountProvider = StreamProvider<int>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return ref.watch(notificationServiceProvider).watchUnreadCount(userId);
});

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return ref.watch(notificationServiceProvider).watchNotifications(userId);
});
