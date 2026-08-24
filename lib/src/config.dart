import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class PathGenConfig {
  final String input;
  final String output;
  final bool generateAllGetter;
  final bool transformSvgToVec;
  final bool updateFlutterAssets;

  const PathGenConfig({
    this.input = 'assets',
    this.output = 'lib/assets',
    this.generateAllGetter = false,
    this.transformSvgToVec = true,
    this.updateFlutterAssets = true,
  });

  factory PathGenConfig.fromPubspec(String contents) {
    final document = loadYaml(contents);
    if (document is! YamlMap || document['path_gen'] is! YamlMap) {
      return const PathGenConfig();
    }

    final config = document['path_gen'] as YamlMap;
    return PathGenConfig(
      input: _pathValue(config['input'], 'assets'),
      output: _pathValue(config['output'], 'lib/assets'),
      generateAllGetter: _boolValue(config['generate_all_getter'], false),
      transformSvgToVec: _boolValue(config['transform_svg_to_vec'], true),
      updateFlutterAssets: _boolValue(config['update_flutter_assets'], true),
    );
  }

  static Future<PathGenConfig> load(Directory projectDir) async {
    final pubspec = File(path.join(projectDir.path, 'pubspec.yaml'));
    if (!await pubspec.exists()) return const PathGenConfig();
    return PathGenConfig.fromPubspec(await pubspec.readAsString());
  }

  static String _pathValue(Object? value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;

  static bool _boolValue(Object? value, bool fallback) =>
      value is bool ? value : fallback;
}
