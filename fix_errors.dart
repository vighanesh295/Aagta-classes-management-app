import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    List<String> lines = file.readAsLinesSync();
    bool changed = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Fix bad replacements
      if (line.contains('Theme.of(context).colorScheme.secondaryenGradient')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondaryenGradient', 'const LinearGradient(colors: [Colors.transparent, Colors.transparent])');
        changed = true;
      }
      if (line.contains('Theme.of(context).colorScheme.secondarySurface')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondarySurface', 'Theme.of(context).colorScheme.secondary.withOpacity(0.1)');
        changed = true;
      }
      if (line.contains('Theme.of(context).colorScheme.secondaryBorder')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondaryBorder', 'Theme.of(context).colorScheme.secondary.withOpacity(0.3)');
        changed = true;
      }
      if (line.contains('Theme.of(context).colorScheme.secondaryDark')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondaryDark', 'Theme.of(context).colorScheme.secondary');
        changed = true;
      }
      if (line.contains('Theme.of(context).colorScheme.secondaryLight')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondaryLight', 'Theme.of(context).colorScheme.secondary');
        changed = true;
      }
      if (line.contains('Theme.of(context).colorScheme.secondaryMuted')) {
        line = line.replaceAll('Theme.of(context).colorScheme.secondaryMuted', 'Theme.of(context).colorScheme.secondary.withOpacity(0.6)');
        changed = true;
      }

      // Fix const_eval_method_invocation
      if (line.contains('Theme.of(context)')) {
        // Find if there's a 'const ' in the same line before Theme.of, or we just aggressively remove 'const ' if Theme.of is in the line.
        // But 'const ' might be before a completely different widget in the same line.
        // A simple fix: if line has 'Theme.of(context)' and 'const ', just replace 'const ' with ''
        if (line.contains('const ') && !line.contains('const Offset')) {
          line = line.replaceAll('const ', '');
          changed = true;
        }
      }

      // Some files might have 'static Theme.of(context)' which is invalid.
      // Usually, this was 'static const Color something = AppColors.something'
      // If we see 'static Theme.of(context)', we might need to manually fix it, but let's check if it exists.
      
      lines[i] = line;
    }

    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
      stderr.writeln('Fixed \${file.path}');
    }
  }
}
