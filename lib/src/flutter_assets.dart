import 'dart:io';

Iterable<String> flutterAssetDirectories(Iterable<String> outputs) sync* {
  for (final output in outputs) {
    final segments = output.split('/');
    final binIndex = segments.indexWhere((segment) => segment.endsWith('-bin'));
    if (binIndex >= 0) yield '${segments.take(binIndex + 1).join('/')}/';
  }
}

Future<void> syncFlutterAssets(File pubspec, Iterable<String> assets) async {
  if (!await pubspec.exists()) return;
  final desired = assets.toSet().toList()..sort();
  final original = await pubspec.readAsString();
  final lines = original.split('\n');
  final start =
      lines.indexWhere((line) => line.trim() == '# path_gen:assets:start');
  final end =
      lines.indexWhere((line) => line.trim() == '# path_gen:assets:end');

  if (start >= 0 && end > start) {
    lines.removeRange(start, end + 1);
  }
  if (desired.isEmpty) {
    final updated = lines.join('\n');
    if (updated != original) await pubspec.writeAsString(updated);
    return;
  }

  final flutterIndex = lines.indexWhere(
    (line) => RegExp(r'^flutter:\s*(?:#.*)?$').hasMatch(line),
  );
  if (flutterIndex < 0) {
    if (lines.isNotEmpty && lines.last.isNotEmpty) lines.add('');
    lines.addAll(_assetBlock('', desired, includeAssetsKey: true));
  } else {
    final flutterIndent = _indent(lines[flutterIndex]);
    final blockEnd = _blockEnd(lines, flutterIndex, flutterIndent);
    final assetsIndex =
        _assetsIndex(lines, flutterIndex + 1, blockEnd, flutterIndent);

    if (assetsIndex < 0) {
      lines.insertAll(
        flutterIndex + 1,
        _assetBlock(' ' * (flutterIndent + 2), desired, includeAssetsKey: true),
      );
    } else {
      lines.insertAll(
        assetsIndex + 1,
        _assetBlock(' ' * (_indent(lines[assetsIndex]) + 2), desired),
      );
    }
  }

  var updated = lines.join('\n');
  if (original.endsWith('\n') && !updated.endsWith('\n')) updated += '\n';
  if (updated != original) await pubspec.writeAsString(updated);
}

List<String> _assetBlock(
  String indent,
  List<String> assets, {
  bool includeAssetsKey = false,
}) {
  final assetIndent = includeAssetsKey ? '$indent  ' : indent;
  return [
    if (includeAssetsKey) '${indent}assets:',
    '$assetIndent# path_gen:assets:start',
    ...assets.map((asset) => '$assetIndent- $asset'),
    '$assetIndent# path_gen:assets:end',
  ];
}

int _blockEnd(List<String> lines, int start, int indent) {
  for (var index = start + 1; index < lines.length; index++) {
    final line = lines[index];
    if (line.trim().isNotEmpty && _indent(line) <= indent) return index;
  }
  return lines.length;
}

int _assetsIndex(List<String> lines, int start, int end, int flutterIndent) {
  for (var index = start; index < end; index++) {
    final line = lines[index];
    if (_indent(line) > flutterIndent && line.trim() == 'assets:') {
      return index;
    }
  }
  return -1;
}

int _indent(String line) => line.length - line.trimLeft().length;
