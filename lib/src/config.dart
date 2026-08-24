import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class SvgBinConfig {
  final String input;
  final String output;
  final bool generateAllGetter;
  final bool transformSvgToVec;

  const SvgBinConfig({
    this.input = 'assets',
    this.output = 'lib/assets',
    this.generateAllGetter = false,
    this.transformSvgToVec = true,
  });

  factory SvgBinConfig.fromPubspec(String contents) {
    final document = loadYaml(contents);
    if (document is! YamlMap || document['svg_bin'] is! YamlMap) {
      return const SvgBinConfig();
    }

    final config = document['svg_bin'] as YamlMap;
    return SvgBinConfig(
      input: _pathValue(config['input'], 'assets'),
      output: _pathValue(config['output'], 'lib/assets'),
      generateAllGetter: _boolValue(config['generate_all_getter'], false),
      transformSvgToVec: _boolValue(config['transform_svg_to_vec'], true),
    );
  }

  static Future<SvgBinConfig> load(Directory projectDir) async {
    final pubspec = File(path.join(projectDir.path, 'pubspec.yaml'));
    if (!await pubspec.exists()) return const SvgBinConfig();
    return SvgBinConfig.fromPubspec(await pubspec.readAsString());
  }

  static String _pathValue(Object? value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;

  static bool _boolValue(Object? value, bool fallback) =>
      value is bool ? value : fallback;
}
