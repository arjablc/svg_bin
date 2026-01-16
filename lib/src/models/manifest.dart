import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class AssetEntry {
  final String hash;
  final String output;
  final DateTime compiledAt;

  AssetEntry({
    required this.hash,
    required this.output,
    required this.compiledAt,
  });

  factory AssetEntry.fromJson(Map<String, dynamic> json) {
    return AssetEntry(
      hash: json['hash'] as String,
      output: json['output'] as String,
      compiledAt: DateTime.parse(json['compiled_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'output': output,
        'compiled_at': compiledAt.toIso8601String(),
      };
}

class Manifest {
  static const String _version = '1.0';
  static const String _fileName = '.manifest.json';

  final String _outputDir;
  final Map<String, AssetEntry> _assets;
  DateTime _generatedAt;

  Manifest._({
    required String outputDir,
    required Map<String, AssetEntry> assets,
    required DateTime generatedAt,
  })  : _outputDir = outputDir,
        _assets = assets,
        _generatedAt = generatedAt;

  String get manifestPath => path.join(_outputDir, _fileName);

  static Future<Manifest> load(String outputDir) async {
    final manifestFile = File(path.join(outputDir, _fileName));

    if (!await manifestFile.exists()) {
      return Manifest._(
        outputDir: outputDir,
        assets: {},
        generatedAt: DateTime.now(),
      );
    }

    try {
      final content = await manifestFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final assetsJson = json['assets'] as Map<String, dynamic>? ?? {};
      final assets = assetsJson.map(
        (key, value) => MapEntry(
          key,
          AssetEntry.fromJson(value as Map<String, dynamic>),
        ),
      );

      return Manifest._(
        outputDir: outputDir,
        assets: assets,
        generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      stderr.writeln('Warning: Could not parse manifest, starting fresh: $e');
      return Manifest._(
        outputDir: outputDir,
        assets: {},
        generatedAt: DateTime.now(),
      );
    }
  }

  Future<bool> needsRecompile(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) return false;

    final currentHash = await _computeHash(file);
    final entry = _assets[sourcePath];

    if (entry == null) return true;
    return entry.hash != currentHash;
  }

  Future<String> _computeHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  Future<void> update(String sourcePath, String outputPath) async {
    final file = File(sourcePath);
    final hash = await _computeHash(file);

    _assets[sourcePath] = AssetEntry(
      hash: hash,
      output: outputPath,
      compiledAt: DateTime.now(),
    );
  }

  void remove(String sourcePath) {
    _assets.remove(sourcePath);
  }

  bool hasEntry(String sourcePath) => _assets.containsKey(sourcePath);

  AssetEntry? getEntry(String sourcePath) => _assets[sourcePath];

  Future<void> save() async {
    _generatedAt = DateTime.now();

    final json = {
      'version': _version,
      'generated_at': _generatedAt.toIso8601String(),
      'assets': _assets.map((key, value) => MapEntry(key, value.toJson())),
    };

    final dir = Directory(_outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(manifestPath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }
}
