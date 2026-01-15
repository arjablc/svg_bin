import 'dart:io';

import 'package:path/path.dart' as path;

class AssetFile {
  final String name;
  final String sourcePath;
  final String outputPath;

  AssetFile({
    required this.name,
    required this.sourcePath,
    required this.outputPath,
  });
}

class AssetCategory {
  final String name;
  final List<AssetFile> files;

  AssetCategory({
    required this.name,
    required this.files,
  });
}

class AssetFolder {
  final String name;
  final List<AssetFile> files;
  final List<AssetCategory> categories;

  AssetFolder({
    required this.name,
    required this.files,
    required this.categories,
  });

  List<AssetFile> get allFiles {
    final all = <AssetFile>[...files];
    for (final cat in categories) {
      all.addAll(cat.files);
    }
    return all;
  }
}

class AssetTree {
  final List<AssetFolder> folders;

  AssetTree({required this.folders});

  List<AssetFile> get allFiles {
    final all = <AssetFile>[];
    for (final folder in folders) {
      all.addAll(folder.allFiles);
    }
    return all;
  }

  static Future<AssetTree> buildFromDirectory(
    String assetDir, {
    String extension = '.svg',
    String outputSuffix = '-bin',
    String outputExtension = '.vec',
  }) async {
    final dir = Directory(assetDir);
    if (!await dir.exists()) {
      return AssetTree(folders: []);
    }

    final folders = <AssetFolder>[];
    final topLevelEntities = await dir.list().toList();

    for (final entity in topLevelEntities) {
      if (entity is! Directory) continue;
      if (path.basename(entity.path).endsWith(outputSuffix)) continue;

      final folder = await _buildFolder(
        entity,
        assetDir,
        extension,
        outputSuffix,
        outputExtension,
      );
      if (folder.files.isNotEmpty || folder.categories.isNotEmpty) {
        folders.add(folder);
      }
    }

    return AssetTree(folders: folders);
  }

  static Future<AssetFolder> _buildFolder(
    Directory dir,
    String assetRoot,
    String extension,
    String outputSuffix,
    String outputExtension,
  ) async {
    final folderName = path.basename(dir.path);
    final files = <AssetFile>[];
    final categories = <AssetCategory>[];

    final entities = await dir.list().toList();

    for (final entity in entities) {
      final entityName = path.basename(entity.path);

      if (entity is File && entityName.endsWith(extension)) {
        final baseName = path.basenameWithoutExtension(entityName);
        final outputDir = '${dir.path}$outputSuffix';
        final outputFile = '$entityName$outputExtension';

        files.add(AssetFile(
          name: baseName,
          sourcePath: entity.path,
          outputPath: path.join(outputDir, outputFile),
        ));
      } else if (entity is Directory && !entityName.endsWith(outputSuffix)) {
        final category = await _buildCategory(
          entity,
          dir.path,
          extension,
          outputSuffix,
          outputExtension,
        );
        if (category.files.isNotEmpty) {
          categories.add(category);
        }
      }
    }

    return AssetFolder(
      name: folderName,
      files: files,
      categories: categories,
    );
  }

  static Future<AssetCategory> _buildCategory(
    Directory dir,
    String parentPath,
    String extension,
    String outputSuffix,
    String outputExtension,
  ) async {
    final categoryName = path.basename(dir.path);
    final files = <AssetFile>[];

    final entities = await dir.list().toList();

    for (final entity in entities) {
      if (entity is! File) continue;

      final entityName = path.basename(entity.path);
      if (!entityName.endsWith(extension)) continue;

      final baseName = path.basenameWithoutExtension(entityName);
      final outputDir = path.join('$parentPath$outputSuffix', categoryName);
      final outputFile = '$entityName$outputExtension';

      files.add(AssetFile(
        name: baseName,
        sourcePath: entity.path,
        outputPath: path.join(outputDir, outputFile),
      ));
    }

    return AssetCategory(
      name: categoryName,
      files: files,
    );
  }
}
