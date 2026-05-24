import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // We can confidently replace AppColors inside build methods where `Theme.of(context)` works.
    // For simpler replacements, we assume `context` is available in most places like Widget build methods.
    
    // Remove the old import if present
    if (content.contains("import '../../../core/constants/app_colors.dart';")) {
      content = content.replaceAll("import '../../../core/constants/app_colors.dart';", "");
      changed = true;
    }
    if (content.contains("import '../../core/constants/app_colors.dart';")) {
      content = content.replaceAll("import '../../core/constants/app_colors.dart';", "");
      changed = true;
    }
    
    // Replacements
    final Map<String, String> replacements = {
      'AppColors.goldSurface': 'Theme.of(context).colorScheme.secondary.withOpacity(0.1)',
      'AppColors.goldBorder': 'Theme.of(context).colorScheme.secondary.withOpacity(0.3)',
      'AppColors.gold': 'Theme.of(context).colorScheme.secondary',
      'AppColors.goldDark': 'Theme.of(context).colorScheme.secondary',
      'AppColors.goldLight': 'Theme.of(context).colorScheme.secondary',
      'AppColors.navy': 'Theme.of(context).colorScheme.primary',
      'AppColors.white': 'Colors.white',
      'AppColors.offWhite': 'Theme.of(context).scaffoldBackgroundColor',
      'AppColors.darkBg': 'Theme.of(context).scaffoldBackgroundColor',
      'AppColors.darkSurface': 'Theme.of(context).cardTheme.color',
      'AppColors.darkCard': 'Theme.of(context).cardTheme.color',
      'AppColors.textLight': 'Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey',
      'AppColors.textMedium': 'Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey',
      'AppColors.textDark': 'Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black',
      'AppColors.borderGrey': 'Theme.of(context).dividerColor',
      'AppColors.lightGrey': 'Theme.of(context).dividerColor.withOpacity(0.1)',
      'AppColors.error': 'Theme.of(context).colorScheme.error',
      'AppColors.errorLight': 'Theme.of(context).colorScheme.error.withOpacity(0.1)',
      'AppColors.success': 'Colors.green',
      'AppColors.successLight': 'Colors.green.withOpacity(0.1)',
      'AppColors.warning': 'Colors.orange',
      'AppColors.warningLight': 'Colors.orange.withOpacity(0.1)',
      'AppColors.info': 'Colors.blue',
      'AppColors.infoLight': 'Colors.blue.withOpacity(0.1)',
      'AppColors.goldenGradient': 'const LinearGradient(colors: [Colors.transparent, Colors.transparent])', // nullify gradients
    };

    for (final entry in replacements.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
      stderr.writeln('Updated \${file.path}');
    }
  }
}
