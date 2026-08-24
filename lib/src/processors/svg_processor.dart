import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_gen/src/models/asset.dart';

abstract class ResourceProcessor {
  String get id;
  String get version;

  bool supports(Asset asset);
  String outputFor(Asset asset);
  bool isGeneratedOutput(String relativePath);
  Future<ProcessResult> process(String inputPath, String outputPath);
}

class ProcessResult {
  final bool success;
  final String? error;

  ProcessResult({required this.success, this.error});

  factory ProcessResult.ok() => ProcessResult(success: true);
  factory ProcessResult.failed(String error) =>
      ProcessResult(success: false, error: error);
}

class SvgProcessor implements ResourceProcessor {
  static const _inputExtension = '.svg';
  static const _outputExtension = '.vec';

  @override
  String get id => 'svg_to_vec';

  @override
  String get version => '1';

  @override
  bool supports(Asset asset) => asset.type == _inputExtension;

  @override
  String outputFor(Asset asset) {
    final segments = path.split(asset.relativePath);
    final sourceRoot = segments.length == 1
        ? path.dirname(asset.sourcePath)
        : List<String>.filled(segments.length - 1, '')
            .fold(asset.sourcePath, (root, _) => path.dirname(root));
    final outputRoot = path.join(
      path.dirname(sourceRoot),
      '${path.basename(sourceRoot)}-bin',
    );

    return path.joinAll([
      outputRoot,
      if (segments.length > 2) ...segments.sublist(1, segments.length - 1),
      '${path.basename(asset.relativePath)}$_outputExtension',
    ]);
  }

  @override
  bool isGeneratedOutput(String relativePath) =>
      path.split(relativePath).any((part) => part.endsWith('-bin'));

  @override
  Future<ProcessResult> process(String inputPath, String outputPath) async {
    final outputDir = Directory(path.dirname(outputPath));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final result = await Process.run('dart', [
      'run',
      'vector_graphics_compiler',
      '-i',
      inputPath,
      '-o',
      outputPath,
    ]);

    if (result.exitCode != 0) {
      final error = result.stderr.toString().trim();
      return ProcessResult.failed(
        error.isNotEmpty
            ? error
            : 'Compilation failed with exit code ${result.exitCode}',
      );
    }

    return ProcessResult.ok();
  }
}
