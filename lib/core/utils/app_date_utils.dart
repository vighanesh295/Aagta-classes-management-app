// lib/core/utils/app_date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat     = DateFormat('dd MMM yyyy');
  static final _timeFormat     = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _monthYear      = DateFormat('MMMM yyyy');
  static final _dayMonth       = DateFormat('dd MMM');
  static final _shortDay       = DateFormat('EEE');

  static String formatDate(DateTime date)       => _dateFormat.format(date);
  static String formatTime(DateTime time)       => _timeFormat.format(time);
  static String formatDateTime(DateTime dt)     => _dateTimeFormat.format(dt);
  static String formatMonthYear(DateTime date)  => _monthYear.format(date);
  static String formatDayMonth(DateTime date)   => _dayMonth.format(date);
  static String formatShortDay(DateTime date)   => _shortDay.format(date);

  static int daysUntil(DateTime future) {
    final now = DateTime.now();
    return future.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  static bool isDueSoon(DateTime dueDate, {int withinDays = 5}) {
    final days = daysUntil(dueDate);
    return days >= 0 && days <= withinDays;
  }

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static String dueDateLabel(DateTime dueDate) {
    final days = daysUntil(dueDate);
    if (days < 0)  return 'Overdue by ${days.abs()} days';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }
}
