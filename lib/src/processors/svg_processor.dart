import 'dart:io';

import 'package:path/path.dart' as path;

abstract class ResourceProcessor {
  String get inputExtension;
  String get outputExtension;

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
  @override
  String get inputExtension => '.svg';

  @override
  String get outputExtension => '.vec';

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
        error.isNotEmpty ? error : 'Compilation failed with exit code ${result.exitCode}',
      );
    }

    return ProcessResult.ok();
  }
}
