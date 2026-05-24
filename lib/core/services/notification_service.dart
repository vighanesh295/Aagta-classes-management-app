// lib/core/services/notification_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles FCM token registration, incoming messages,
/// and the installment reminder notification schedule.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging          _fcm   = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'aagte_classes_channel';
  static const _channelName = 'Aagte Classes Notifications';

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );

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

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Subscribe to topic
    await _fcm.subscribeToTopic('all');
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  Future<String?> getToken() => _fcm.getToken();

  Future<void> saveTokenToFirestore(String uid) async {
    final token = await getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }

  // ── Foreground handler ─────────────────────────────────────────────────────
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _showLocalNotification(
      title: notification.title ?? 'Aagte Classes',
      body:  notification.body  ?? '',
    );
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
      final snap  = await FirebaseFirestore.instance
          .collection('installments')
          .where('studentId', isEqualTo: studentId)
          .where('status', isEqualTo: 'pending')
          .get();

      int notifId = 100;
      for (final doc in snap.docs) {
        final data    = doc.data();
        final dueTs   = data['dueDate'] as Timestamp?;
        if (dueTs == null) continue;

        final due     = dueTs.toDate();
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


