import 'dart:io';

void main() {
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var c = file.readAsStringSync();
    final orig = c;
    
    // Strip const from parent widgets that contain Theme.of
    c = c.replaceAll(RegExp(r'const\s+(Center|Padding|BoxDecoration|Icon|TextStyle|Text|PremiumCard|CircularPercentIndicator)\s*\('), r'$1(');
    
    // fee_management_screen.dart
    c = c.replaceAll('Widget _FeeVal(String l, String v, Color c) => Column(children: [', 'Widget _FeeVal(BuildContext context, String l, String v, Color c) => Column(children: [');
    c = c.replaceAll("_FeeVal('Total'", "_FeeVal(context, 'Total'");
    c = c.replaceAll("_FeeVal('Paid'", "_FeeVal(context, 'Paid'");
    c = c.replaceAll("_FeeVal('Remaining'", "_FeeVal(context, 'Remaining'");
    
    // settings_screen.dart
    c = c.replaceAll('Widget _SectionTitle(String title) => Padding(', 'Widget _SectionTitle(BuildContext context, String title) => Padding(');
    c = c.replaceAll("_SectionTitle('Appearance')", "_SectionTitle(context, 'Appearance')");
    c = c.replaceAll("_SectionTitle('Notifications')", "_SectionTitle(context, 'Notifications')");
    c = c.replaceAll("_SectionTitle('Account')", "_SectionTitle(context, 'Account')");
    
    // fee_details_screen.dart
    c = c.replaceAll('Color get _statusColor => status == FeeStatus.overdue ? Theme.of(context).colorScheme.error', 'Color _statusColor(BuildContext context) => status == FeeStatus.overdue ? Theme.of(context).colorScheme.error');
    c = c.replaceAll('Color get _statusColor => status == FeeStatus.paid ? Colors.green', 'Color _statusColor(BuildContext context) => status == FeeStatus.paid ? Colors.green');
    
    // replace get uses with context
    // This is naive, so we just target the ones we know
    c = c.replaceAll('color: _statusColor,', 'color: _statusColor(context),');
    c = c.replaceAll('backgroundColor: _statusColor', 'backgroundColor: _statusColor(context)');
    c = c.replaceAll('color: _statusColor\n', 'color: _statusColor(context)\n');
    c = c.replaceAll('color: _statusColor}', 'color: _statusColor(context)}');
    c = c.replaceAll('color: _statusColor)', 'color: _statusColor(context))');
    
    // attendance_screen.dart
    c = c.replaceAll('Color get _color {', 'Color _color(BuildContext context) {');
    c = c.replaceAll('color: _color,', 'color: _color(context),');
    c = c.replaceAll('color: _color)', 'color: _color(context))');
    
    // notifications_screen.dart
    c = c.replaceAll('Color get _iconColor {', 'Color _iconColor(BuildContext context) {');
    c = c.replaceAll('color: _iconColor,', 'color: _iconColor(context),');
    c = c.replaceAll('color: _iconColor)', 'color: _iconColor(context))');
    c = c.replaceAll('backgroundColor: _iconColor', 'backgroundColor: _iconColor(context)');
    
    // study_material_screen.dart
    // results_screen.dart
    c = c.replaceAll('Color get _gradeColor {', 'Color _gradeColor(BuildContext context) {');
    c = c.replaceAll('color: _gradeColor,', 'color: _gradeColor(context),');
    c = c.replaceAll('color: _gradeColor)', 'color: _gradeColor(context))');
    c = c.replaceAll('backgroundColor: _gradeColor', 'backgroundColor: _gradeColor(context)');
    
    if (c != orig) {
      file.writeAsStringSync(c);
      stderr.writeln('Fixed: ${file.path}');
    }
  }
}
