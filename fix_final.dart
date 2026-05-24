import 'dart:io';

void main() {
  void replaceInFile(String path, Map<String, String> replacements) {
    final file = File(path);
    if (!file.existsSync()) return;
    var content = file.readAsStringSync();
    var original = content;
    replacements.forEach((from, to) {
      content = content.replaceAll(from, to);
    });
    if (content != original) {
      file.writeAsStringSync(content);
      stderr.writeln('Fixed $path');
    }
  }

  // 1. login_screen.dart
  replaceInFile('lib/features/auth/screens/login_screen.dart', {
    'Center(AppStrings.rememberMe': 'Text(AppStrings.rememberMe',
    'Center(AppStrings.forgotPassword': 'Text(AppStrings.forgotPassword',
  });

  // 2. forgot_password_screen.dart
  replaceInFile('lib/features/auth/screens/forgot_password_screen.dart', {
    'Center(AppStrings.backToLogin': 'Text(AppStrings.backToLogin',
  });

  // 3. settings_screen.dart
  replaceInFile('lib/features/common/screens/settings_screen.dart', {
    'Center(AppStrings.darkMode)': 'Text(AppStrings.darkMode)',
    'Center(AppStrings.appVersion,': 'Text(AppStrings.appVersion,',
    'Center(AppStrings.logout,': 'Text(AppStrings.logout,',
  });

  // 4. analytics_screen.dart
  replaceInFile('lib/features/admin/screens/analytics_screen.dart', {
    'Center(color: Colors.white, fontSize: 12': 'TextStyle(color: Colors.white, fontSize: 12',
  });

  // 5. attendance_screen.dart
  replaceInFile('lib/features/student/screens/attendance_screen.dart', {
    '_color.withOpacity': '_color(context).withOpacity',
  });

  // 6. study_material_screen.dart
  replaceInFile('lib/features/student/screens/study_material_screen.dart', {
    '_color.withOpacity': '_color(context).withOpacity',
    '_iconColor.withOpacity': '_iconColor(context).withOpacity',
  });

  // 7. notifications_screen.dart
  replaceInFile('lib/features/student/screens/notifications_screen.dart', {
    '_color.withOpacity': '_color(context).withOpacity',
    '_iconColor.withOpacity': '_iconColor(context).withOpacity',
  });

  // 8. results_screen.dart
  replaceInFile('lib/features/student/screens/results_screen.dart', {
    'Color get _gradeColor {': 'Color _gradeColor(BuildContext context) {',
    'Color _gradeColor {': 'Color _gradeColor(BuildContext context) {',
  });

  // 9. fee_details_screen.dart
  replaceInFile('lib/features/student/screens/fee_details_screen.dart', {
    'Color get _statusColor {': 'Color _statusColor(BuildContext context) {',
    'Color get _statusColor =>': 'Color _statusColor(BuildContext context) =>',
  });
  
  // Let's also do a regex replacement for any `_color.withOpacity` in lib
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    var c = file.readAsStringSync();
    var orig = c;
    c = c.replaceAll('_color.withOpacity', '_color(context).withOpacity');
    c = c.replaceAll('_iconColor.withOpacity', '_iconColor(context).withOpacity');
    c = c.replaceAll('_gradeColor.withOpacity', '_gradeColor(context).withOpacity');
    c = c.replaceAll('_statusColor.withOpacity', '_statusColor(context).withOpacity');
    
    // Also fix results_screen.dart context error
    if (file.path.endsWith('results_screen.dart')) {
      c = c.replaceAll('Color get _gradeColor {', 'Color _gradeColor(BuildContext context) {');
    }
    
    // Also fee_details_screen.dart context error
    if (file.path.endsWith('fee_details_screen.dart')) {
      c = c.replaceAll('Color get _statusColor {', 'Color _statusColor(BuildContext context) {');
      c = c.replaceAll('Color get _statusColor =>', 'Color _statusColor(BuildContext context) =>');
      // Fix _InstallmentCard statusColor
      c = c.replaceAll('Color get _statusColor => status == FeeStatus.overdue', 'Color _statusColor(BuildContext context) => status == FeeStatus.overdue');
    }
    
    // Fix attendance_screen.dart context error
    if (file.path.endsWith('attendance_screen.dart')) {
      c = c.replaceAll('Color get _statusColor {', 'Color _statusColor(BuildContext context) {');
      c = c.replaceAll('Color get _statusColor =>', 'Color _statusColor(BuildContext context) =>');
    }
    
    if (c != orig) {
      file.writeAsStringSync(c);
      stderr.writeln('Fixed dynamically: ${file.path}');
    }
  }
}
