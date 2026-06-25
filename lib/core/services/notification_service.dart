import 'dart:async';
import 'supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles incoming messages,
/// and the installment reminder notification schedule.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'aagte_classes_channel';
  static const _channelName = 'Aagte Classes Notifications';

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Local notifications init
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings    = InitializationSettings(android: androidSettings);
    await _local.initialize(initSettings);

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId, _channelName,
      description: 'Coaching institute alerts',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  Future<String?> getToken() async => null;

  Future<void> saveTokenToFirestore(String uid) async {
    // Left as stub for future Supabase Push implementation
  }

  // ── Show local notification ────────────────────────────────────────────────
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          importance: Importance.high,
          priority:   Priority.high,
          color:      Color(0xFFD4A017),
          playSound:  true,
        ),
      ),
    );
  }

  // ── Installment reminders ──────────────────────────────────────────────────
  /// Called by a background job / Cloud Function trigger.
  /// Checks all pending installments and sends local notifications
  /// if the due date is within 5 days.
  Future<void> checkAndScheduleInstallmentReminders(String studentId) async {
    try {
      final now   = DateTime.now();
      final rows  = await SupabaseService.instance.client
          .from('installments')
          .select()
          .eq('student_id', studentId)
          .eq('status', 'pending');

      int notifId = 100;
      for (final row in rows) {
        final dueTs   = row['dueDate']?.toString();
        if (dueTs == null) continue;

        final due     = DateTime.tryParse(dueTs);
        if (due == null) continue;
        
        final daysDiff = due.difference(DateTime(now.year, now.month, now.day)).inDays;

        if (daysDiff >= 0 && daysDiff <= 5) {
          await _showLocalNotification(
            id:    notifId++,
            title: 'Installment Reminder',
            body:  daysDiff == 0
                ? 'Your installment payment is due today!'
                : 'Reminder: Your installment payment is due in $daysDiff day${daysDiff == 1 ? '' : 's'}.',
          );
        }
      }
    } catch (e) {
      debugPrint('NotificationService.checkInstallments error: $e');
    }
  }
}


