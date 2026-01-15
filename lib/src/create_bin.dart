import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:svg_bin/src/generator/dart_generator.dart';
import 'package:svg_bin/src/models/asset_tree.dart';
import 'package:svg_bin/src/models/manifest.dart';
import 'package:svg_bin/src/processors/svg_processor.dart';

Future<void> generate(
  String outputPath, {
  bool force = false,
}) async {
  final cwd = Directory.current;
  const assetFolder = 'assets';
  final assetPath = path.join(cwd.path, assetFolder);
  final assetDir = Directory(assetPath);

  if (!await assetDir.exists()) {
    stdout.writeln("Please put assets into /assets folder at root of project");
    return;
  }

  final outputDir = File(outputPath).parent.path;
  final manifest = await Manifest.load(outputDir);

  stdout.writeln('Scanning assets...');
  final tree = await AssetTree.buildFromDirectory(assetPath);

  if (tree.folders.isEmpty) {
    stdout.writeln('No assets found.');
    return;
  }

  final processor = SvgProcessor();
  var compiledCount = 0;
  var skippedCount = 0;
  var errorCount = 0;

  for (final file in tree.allFiles) {
    final needsCompile = force || await manifest.needsRecompile(file.sourcePath);

    if (!needsCompile) {
      skippedCount++;
      continue;
    }

    final relativeSrc = path.relative(file.sourcePath, from: cwd.path);
    final relativeOut = path.relative(file.outputPath, from: cwd.path);
    stdout.writeln('Compiling: $relativeSrc -> $relativeOut');

    final result = await processor.process(file.sourcePath, file.outputPath);

    if (result.success) {
      await manifest.update(file.sourcePath, file.outputPath);
      compiledCount++;
    } else {
      stderr.writeln('  Error: ${result.error}');
      errorCount++;
    }
  }

  stdout.writeln();
  if (compiledCount > 0) {
    stdout.writeln('Compiled: $compiledCount file(s)');
  }
  if (skippedCount > 0) {
    stdout.writeln('Skipped (unchanged): $skippedCount file(s)');
  }
  if (errorCount > 0) {
    stderr.writeln('Errors: $errorCount file(s)');
  }

  final generator = DartGenerator(assetRoot: assetFolder);
  final dartCode = generator.generate(tree);

  final dartFile = File(outputPath);
  final dartDir = dartFile.parent;
  if (!await dartDir.exists()) {
    await dartDir.create(recursive: true);
  }
  await dartFile.writeAsString(dartCode);
  stdout.writeln('Generated: ${path.relative(outputPath, from: cwd.path)}');

  await manifest.save();
  stdout.writeln('Manifest saved: ${path.relative(manifest.manifestPath, from: cwd.path)}');
}
