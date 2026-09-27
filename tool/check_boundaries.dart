import 'dart:io';

void main() {
  final violations = <String>[];
  final directive = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');
  for (final root in ['packages/core/lib', 'packages/ui/lib', 'example/lib']) {
    for (final file in Directory(
      root,
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        final isCore = root == 'packages/core/lib';
        final isPackage = root.startsWith('packages/');
        final forbidden =
            (isCore && (uri.startsWith('package:') || uri == 'dart:ui')) ||
            (isPackage && uri.contains('starter_example')) ||
            (isPackage && uri.contains('riverpod')) ||
            (!isCore && uri.startsWith('package:core/src/')) ||
            (root == 'example/lib' && uri.startsWith('package:ui/src/'));
        if (forbidden) violations.add('${file.path}: $uri');
      }
    }
  }
  if (violations.isNotEmpty) {
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln('Package dependency boundaries passed.');
  }
}
