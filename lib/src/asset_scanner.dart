import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:svg_bin/src/models/asset.dart';

class AssetScanner {
  final String assetPath;
  final String projectPath;
  final bool Function(String relativePath) isExcluded;

  const AssetScanner({
    required this.assetPath,
    required this.projectPath,
    required this.isExcluded,
  });

  Future<List<Asset>> scan() async {
    final assets = <Asset>[];
    final directory = Directory(assetPath);

    await for (final entity in directory.list(recursive: true)) {
      if (entity is! File) continue;

      final relativePath = path.relative(entity.path, from: assetPath);
      if (isExcluded(relativePath)) continue;

      assets.add(Asset(
        sourcePath: entity.path,
        relativePath: relativePath,
        type: path.extension(entity.path).toLowerCase(),
        hash: (await sha256.bind(entity.openRead()).first).toString(),
        runtimePath: _runtimePath(entity.path),
      ));
    }

    assets.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return assets;
  }

  String _runtimePath(String sourcePath) => path
      .relative(sourcePath, from: projectPath)
      .replaceAll(path.separator, '/');
}
