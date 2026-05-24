import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalFixed = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    final original = content;

    // ── 1. Fix invalid Colors.xLight getters ──────────────────────────────
    content = content.replaceAll('Colors.blueLight', 'Colors.blue.withOpacity(0.1)');
    content = content.replaceAll('Colors.greenLight', 'Colors.green.withOpacity(0.1)');
    content = content.replaceAll('Colors.orangeLight', 'Colors.orange.withOpacity(0.1)');
    content = content.replaceAll('Colors.redLight', 'Colors.red.withOpacity(0.1)');
    content = content.replaceAll('Colors.purpleLight', 'Colors.purple.withOpacity(0.1)');

    // ── 2. Fix invalid ColorScheme.errorLight getter ───────────────────────
    content = content.replaceAll(
      'Theme.of(context).colorScheme.errorLight',
      'Theme.of(context).colorScheme.error.withOpacity(0.1)',
    );
    content = content.replaceAll(
      'colorScheme.errorLight',
      'colorScheme.error.withOpacity(0.1)',
    );

    // ── 3. Fix static const lists that reference Theme.of(context) ─────────
    // Pattern: static const _items = [...Theme.of(context)...] 
    // => convert to instance build method variable
    // These were already fixed manually in teacher_dashboard; scan for any remaining.

    // ── 4. Fix "const" keyword before expressions with Theme.of(context) ───
    // Remove 'const ' from lines that contain Theme.of(context) 
    final lines = content.split('\n');
    final fixed = <String>[];
    for (final line in lines) {
      if (line.contains('Theme.of(context)') && line.contains('const ')) {
        // Don't strip const from import lines
        if (!line.trimLeft().startsWith('import')) {
          fixed.add(line.replaceAll('const ', ''));
          continue;
        }
      }
      fixed.add(line);
    }
    content = fixed.join('\n');

    // ── 5. Fix Undefined name 'context' in static/class-level positions ────
    // Pattern: static list or field referencing Theme.of(context)
    // These appear as "static const _items = [...Theme.of(context)...]" or  
    // top-level functions. Detect and do nothing here (requires manual fix per file).

    if (content != original) {
      file.writeAsStringSync(content);
      totalFixed++;
      stderr.writeln('Fixed: ${file.path}');
    }
  }

  stderr.writeln('\nTotal files fixed: $totalFixed');
}
