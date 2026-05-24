import 'dart:io';

void main() {
  final files = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var c = file.readAsStringSync();
    if (!c.contains('\$1')) continue;
    
    if (file.path.endsWith('premium_card.dart')) {
      c = c.replaceAll('\$1({', 'PremiumCard({');
    }
    
    c = c.replaceAll('\$1(Icons.', 'Icon(Icons.');
    c = c.replaceAllMapped(RegExp(r'\$1\(([' "'" '"])'), (m) => 'Text(${m.group(1)}');
    c = c.replaceAll('style: \$1(', 'style: TextStyle(');
    c = c.replaceAll('decoration: \$1(', 'decoration: BoxDecoration(');
    c = c.replaceAll('\$1(gradient:', 'BoxDecoration(gradient:');
    c = c.replaceAll('\$1(padding:', 'Padding(padding:');
    c = c.replaceAll('\$1(radius:', 'CircularPercentIndicator(radius:');
    c = c.replaceAll('\$1(\n', 'Center(\n');
    c = c.replaceAll('\$1(child:', 'Center(child:');
    
    c = c.replaceAllMapped(RegExp(r'(^|\s|return\s+)\$1\('), (m) => '${m.group(1)}Center(');
    
    file.writeAsStringSync(c);
    stderr.writeln('Reverted \$1 in ${file.path}');
  }
}
