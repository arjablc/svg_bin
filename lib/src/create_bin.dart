import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:svg_bin/src/asset_scanner.dart';
import 'package:svg_bin/src/generator/dart_generator.dart';
import 'package:svg_bin/src/models/asset.dart';
import 'package:svg_bin/src/models/manifest.dart';
import 'package:svg_bin/src/processors/svg_processor.dart';

Future<void> generate(
  String outputPath, {
  String inputPath = 'assets',
  bool generateAllGetter = false,
  bool transformSvgToVec = true,
  bool force = false,
}) async {
  final cwd = Directory.current;
  final assetPath = path.normalize(
    path.isAbsolute(inputPath) ? inputPath : path.join(cwd.path, inputPath),
  );
  final assetDir = Directory(assetPath);

  if (!await assetDir.exists()) {
    stdout.writeln('Input directory not found: $inputPath');
    return;
  }

  stdout.writeln('Scanning assets...');
  final processor = SvgProcessor();
  final assets = await AssetScanner(
    assetPath: assetPath,
    projectPath: cwd.path,
    isExcluded: processor.isGeneratedOutput,
  ).scan();

  if (assets.isEmpty) {
    stdout.writeln('No assets found.');
    return;
  }

  final manifest = await Manifest.load(File(outputPath).parent.path);
  final diff = manifest.diff(assets);
  for (final entry in diff.removed.values) {
    await _deleteOutput(entry.output, processor);
  }

  final generatedAssets = <Asset>[];
  final entries = <String, AssetEntry>{};
  if (transformSvgToVec) {
    var compiledCount = 0;
    var skippedCount = 0;
    var errorCount = 0;

    for (final asset in assets) {
      if (!processor.supports(asset)) {
        generatedAssets.add(asset);
        entries[asset.relativePath] = AssetEntry(hash: asset.hash);
        continue;
      }
      final outputPath = processor.outputFor(asset);
      final needsCompile = force ||
          !diff.unchanged.containsKey(asset.relativePath) ||
          manifest[asset.relativePath]?.output == null;
      if (!needsCompile) {
        generatedAssets.add(asset.copyWith(
          runtimePath: path
              .relative(outputPath, from: cwd.path)
              .replaceAll(path.separator, '/'),
        ));
        entries[asset.relativePath] = AssetEntry(
          hash: asset.hash,
          output: path
              .relative(outputPath, from: cwd.path)
              .replaceAll(path.separator, '/'),
        );
        skippedCount++;
        continue;
      }

      final relativeSrc = path.relative(asset.sourcePath, from: cwd.path);
      final relativeOut = path.relative(outputPath, from: cwd.path);
      stdout.writeln('Compiling: $relativeSrc -> $relativeOut');

      final result = await processor.process(asset.sourcePath, outputPath);
      if (result.success) {
        generatedAssets.add(asset.copyWith(runtimePath: relativeOut));
        entries[asset.relativePath] = AssetEntry(
          hash: asset.hash,
          output: relativeOut,
        );
        compiledCount++;
      } else {
        generatedAssets.add(asset.copyWith(runtimePath: relativeOut));
        stderr.writeln('  Error: ${result.error}');
        errorCount++;
      }
    }

    stdout.writeln();
    if (compiledCount > 0) stdout.writeln('Compiled: $compiledCount file(s)');
    if (skippedCount > 0)
      stdout.writeln('Skipped (unchanged): $skippedCount file(s)');
    if (errorCount > 0) stderr.writeln('Errors: $errorCount file(s)');
  } else {
    for (final asset in assets) {
      generatedAssets.add(asset);
      entries[asset.relativePath] = AssetEntry(hash: asset.hash);
    }
  }

  manifest.replace(entries);
  await manifest.save();
  assets
    ..clear()
    ..addAll(generatedAssets);

  final generator = DartGenerator(generateAllGetter: generateAllGetter);
  final dartCode = generator.generate(assets);

  final dartFile = File(outputPath);
  final dartDir = dartFile.parent;
  if (!await dartDir.exists()) {
    await dartDir.create(recursive: true);
  }

  // Only write if content has changed
  final existingContent =
      await dartFile.exists() ? await dartFile.readAsString() : null;
  if (existingContent != dartCode) {
    await dartFile.writeAsString(dartCode);
    stdout.writeln('Generated: ${path.relative(outputPath, from: cwd.path)}');
  } else {
    stdout.writeln(
        'Skipped (unchanged): ${path.relative(outputPath, from: cwd.path)}');
  }
}

Future<void> _deleteOutput(String? output, SvgProcessor processor) async {
  if (output == null || !processor.isGeneratedOutput(output)) return;

  final file = File(path.isAbsolute(output)
      ? output
      : path.join(Directory.current.path, output));
  if (await file.exists()) {
    await file.delete();
  }
}
