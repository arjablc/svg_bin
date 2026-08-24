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
  final String sourcePath;
  final List<AssetFile> files;

  AssetCategory({
    required this.name,
    required this.sourcePath,
    required this.files,
  });
}

class AssetFolder {
  final String name;
  final String sourcePath;
  final List<AssetFile> files;
  final List<AssetCategory> categories;

  AssetFolder({
    required this.name,
    required this.sourcePath,
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
    bool transformSvgToVec = true,
  }) async {
    final dir = Directory(assetDir);
    if (!await dir.exists()) {
      return AssetTree(folders: []);
    }

    final folders = <AssetFolder>[];
    final topLevelEntities = await dir.list().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // Check for nested svg subdirectory pattern
    // e.g., assets/hello/svg, assets/bro/svg → unified Svg class
    final nestedSvgDirs = await _findNestedSvgDirs(
      topLevelEntities,
      extension,
      outputSuffix,
    );

    if (nestedSvgDirs.isNotEmpty) {
      final unifiedFolder = await _buildUnifiedSvgFolder(
        nestedSvgDirs,
        extension,
        outputSuffix,
        outputExtension,
        transformSvgToVec,
      );
      if (unifiedFolder.files.isNotEmpty ||
          unifiedFolder.categories.isNotEmpty) {
        folders.add(unifiedFolder);
      }
    }

    for (final entity in topLevelEntities) {
      if (entity is! Directory) continue;
      if (path.basename(entity.path).endsWith(outputSuffix)) continue;

      // Skip directories that are part of the nested svg pattern
      if (nestedSvgDirs.any((e) => e.parentPath == entity.path)) continue;

      final folder = await _buildFolder(
        entity,
        extension,
        outputSuffix,
        outputExtension,
        transformSvgToVec,
      );
      if (folder.files.isNotEmpty || folder.categories.isNotEmpty) {
        folders.add(folder);
      }
    }

    return AssetTree(folders: folders);
  }

  /// Represents a nested svg directory pattern (e.g., assets/hello/svg)
  static Future<List<_NestedSvgDir>> _findNestedSvgDirs(
    List<FileSystemEntity> topLevelEntities,
    String extension,
    String outputSuffix,
  ) async {
    final nestedDirs = <_NestedSvgDir>[];

    for (final entity in topLevelEntities) {
      if (entity is! Directory) continue;
      if (path.basename(entity.path).endsWith(outputSuffix)) continue;

      final svgSubdir = Directory(path.join(entity.path, 'svg'));
      if (await svgSubdir.exists()) {
        // Check if it contains svg files
        final svgFiles = await svgSubdir
            .list()
            .where((e) => _isSourceFile(e, extension))
            .toList();
        if (svgFiles.isNotEmpty) {
          nestedDirs.add(_NestedSvgDir(
            parentPath: entity.path,
            parentName: path.basename(entity.path),
            svgDirPath: svgSubdir.path,
          ));
        }
      }
    }

    return nestedDirs;
  }

  /// Build a unified folder from multiple nested svg directories
  static Future<AssetFolder> _buildUnifiedSvgFolder(
    List<_NestedSvgDir> nestedDirs,
    String extension,
    String outputSuffix,
    String outputExtension,
    bool transformSvgToVec,
  ) async {
    final categories = <AssetCategory>[];

    for (final nested in nestedDirs) {
      final files = <AssetFile>[];
      final svgDir = Directory(nested.svgDirPath);
      final entities = await svgDir.list().toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      for (final entity in entities) {
        if (entity is! File) continue;
        final entityName = path.basename(entity.path);
        if (!_isSourceFile(entity, extension)) continue;

        final baseName = path.basenameWithoutExtension(entityName);
        // Output goes to svg-bin next to svg directory
        final outputDir = path.join(nested.parentPath, 'svg$outputSuffix');

        files.add(AssetFile(
          name: baseName,
          sourcePath: entity.path,
          outputPath: _outputPath(
            entity.path,
            outputDir,
            entityName,
            outputExtension,
            transformSvgToVec,
          ),
        ));
      }

      if (files.isNotEmpty) {
        categories.add(AssetCategory(
          name: nested.parentName,
          sourcePath: nested.parentPath,
          files: files,
        ));
      }
    }

    return AssetFolder(
      name: 'svg',
      sourcePath: nestedDirs.first.parentPath,
      files: [],
      categories: categories,
    );
  }

  static Future<AssetFolder> _buildFolder(
    Directory dir,
    String extension,
    String outputSuffix,
    String outputExtension,
    bool transformSvgToVec,
  ) async {
    final folderName = path.basename(dir.path);
    final files = <AssetFile>[];
    final categories = <AssetCategory>[];

    final entities = await dir.list().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final entity in entities) {
      final entityName = path.basename(entity.path);

      if (entity is File && _isSourceFile(entity, extension)) {
        final baseName = path.basenameWithoutExtension(entityName);
        final outputDir = '${dir.path}$outputSuffix';

        files.add(AssetFile(
          name: baseName,
          sourcePath: entity.path,
          outputPath: _outputPath(
            entity.path,
            outputDir,
            entityName,
            outputExtension,
            transformSvgToVec,
          ),
        ));
      } else if (entity is Directory && !entityName.endsWith(outputSuffix)) {
        final category = await _buildCategory(
          entity,
          dir.path,
          extension,
          outputSuffix,
          outputExtension,
          transformSvgToVec,
        );
        if (category.files.isNotEmpty) {
          categories.add(category);
        }
      }
    }

    return AssetFolder(
      name: folderName,
      sourcePath: dir.path,
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
    bool transformSvgToVec,
  ) async {
    final categoryName = path.basename(dir.path);
    final files = <AssetFile>[];

    final entities = await dir.list().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final entity in entities) {
      if (entity is! File) continue;

      final entityName = path.basename(entity.path);
      if (!_isSourceFile(entity, extension)) continue;

      final baseName = path.basenameWithoutExtension(entityName);
      final outputDir = path.join('$parentPath$outputSuffix', categoryName);

      files.add(AssetFile(
        name: baseName,
        sourcePath: entity.path,
        outputPath: _outputPath(
          entity.path,
          outputDir,
          entityName,
          outputExtension,
          transformSvgToVec,
        ),
      ));
    }

    return AssetCategory(
      name: categoryName,
      sourcePath: dir.path,
      files: files,
    );
  }

  static bool _isSourceFile(FileSystemEntity entity, String extension) =>
      entity is File && path.extension(entity.path).toLowerCase() == extension;

  static String _outputPath(
    String sourcePath,
    String outputDir,
    String fileName,
    String outputExtension,
    bool transformSvgToVec,
  ) =>
      transformSvgToVec
          ? path.join(outputDir, '$fileName$outputExtension')
          : sourcePath;
}

/// Helper class to track nested svg directory patterns
class _NestedSvgDir {
  final String parentPath;
  final String parentName;
  final String svgDirPath;

  _NestedSvgDir({
    required this.parentPath,
    required this.parentName,
    required this.svgDirPath,
  });
}
