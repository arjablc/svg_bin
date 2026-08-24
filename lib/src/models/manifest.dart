import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:svg_bin/src/models/asset.dart';

class AssetEntry {
  final String hash;
  final String? output;
  final String? processor;
  final String? processorVersion;

  const AssetEntry({
    required this.hash,
    this.output,
    this.processor,
    this.processorVersion,
  });

  factory AssetEntry.fromJson(Map<String, dynamic> json) => AssetEntry(
        hash: json['hash'] as String,
        output: json['output'] as String?,
        processor: json['processor'] as String?,
        processorVersion: json['processor_version'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'output': output,
        'processor': processor,
        'processor_version': processorVersion,
      };
}

class ManifestDiff {
  final Map<String, Asset> added;
  final Map<String, Asset> modified;
  final Map<String, Asset> unchanged;
  final Map<String, AssetEntry> removed;

  const ManifestDiff({
    required this.added,
    required this.modified,
    required this.unchanged,
    required this.removed,
  });
}

class Manifest {
  static const String _version = '2.0';
  static const String _fileName = '.manifest.json';

  final String _outputDir;
  Map<String, AssetEntry> _assets;

  Manifest._({
    required String outputDir,
    required Map<String, AssetEntry> assets,
  })  : _outputDir = outputDir,
        _assets = assets;

  String get manifestPath => path.join(_outputDir, _fileName);

  static Future<Manifest> load(String outputDir) async {
    final manifestFile = File(path.join(outputDir, _fileName));

    if (!await manifestFile.exists()) {
      return Manifest._(outputDir: outputDir, assets: {});
    }

    try {
      final json =
          jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
      final assetsJson = json['assets'] as Map<String, dynamic>? ?? {};

      return Manifest._(
        outputDir: outputDir,
        assets: assetsJson.map(
          (key, value) => MapEntry(
            key,
            AssetEntry.fromJson(value as Map<String, dynamic>),
          ),
        ),
      );
    } catch (error) {
      stderr
          .writeln('Warning: Could not parse manifest, starting fresh: $error');
      return Manifest._(outputDir: outputDir, assets: {});
    }
  }

  ManifestDiff diff(List<Asset> assets) {
    final current = {for (final asset in assets) asset.relativePath: asset};
    final added = <String, Asset>{};
    final modified = <String, Asset>{};
    final unchanged = <String, Asset>{};

    for (final entry in current.entries) {
      final previous = _assets[entry.key];
      if (previous == null) {
        added[entry.key] = entry.value;
      } else if (previous.hash == entry.value.hash) {
        unchanged[entry.key] = entry.value;
      } else {
        modified[entry.key] = entry.value;
      }
    }

    final removed = Map<String, AssetEntry>.fromEntries(
      _assets.entries.where((entry) => !current.containsKey(entry.key)),
    );

    return ManifestDiff(
      added: added,
      modified: modified,
      unchanged: unchanged,
      removed: removed,
    );
  }

  AssetEntry? operator [](String relativePath) => _assets[relativePath];

  void replace(Map<String, AssetEntry> assets) => _assets = assets;

  Future<void> save() async {
    final directory = Directory(_outputDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    await File(manifestPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': _version,
        'generated_at': DateTime.now().toIso8601String(),
        'assets': _assets.map((key, value) => MapEntry(key, value.toJson())),
      }),
    );
  }
}
