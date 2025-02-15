import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:svg_bin/src/utils.dart';

//Future<void> main() async {
//  await generate();
//}

Future<void> generate() async {
  final cwd = Directory.current;
  final assetFolder = 'assets';
  final lineTerm = Platform.lineTerminator;

  final assetPath = path.join(cwd.path, assetFolder);

  final assetDir = Directory(assetPath);
  //checks if the assets folder is present or not
  if (await assetDir.exists() == false) {
    stdout.writeln("Plese put assets into /assets folder at root of project");
  }

  final folderFileMap = <String, Map<String, String>>{};
  final subEntityList = assetDir.listSync(recursive: true, followLinks: false);
  for (var fsEnitity in subEntityList) {
    // this is the parent folder of the files
    final folderPath = fsEnitity.parent.path;

    final entityStat = fsEnitity.statSync();
    // if the entity is not a file then don't run
    if (entityStat.type != FileSystemEntityType.file) continue;

    final fileBase = path.basename(fsEnitity.path);
    // Don't run the parser if file is other than SVG,
    // TODO: introduce a flag to enable ttfs
    if (!fileBase.endsWith('.svg')) continue;

    final folderBase = path.basename(folderPath);

    // if the folder is already generated one then continue
    if (folderPath.endsWith('bin')) continue;
    //
    final binFolderPath = '$folderPath-bin';
    //
    final binFolderDir = Directory(binFolderPath);
    // Now the 'something-bin' folder is created
    if (!binFolderDir.existsSync()) binFolderDir.createSync();

    final binFileBase = '$fileBase.vec';

    // populate the folder file map
    final currentFolderFileMap =
        folderFileMap.putIfAbsent(folderBase, () => {});

    currentFolderFileMap[fileBase] = 'assets/$folderBase/$binFileBase';

    //INFO: Now comes the part where you conver the svgs into vec files
    stdout.writeln("Converting $folderBase/$fileBase -> $binFileBase");

    // runs this is the home directory
    final result = await Process.run('dart', [
      'run',
      'vector_graphics_compiler',
      '- i',
      path.join(folderPath, fileBase),
      '- o',
      path.join(binFolderPath, binFileBase),
    ]);
    stderr.write(result.stderr);
  }

  Map<String, String> catCache = {};
  //INFO: Now the dart file generation
  final fileBuffer = StringBuffer()
    ..writeln('//WARN: Generated File Don\'t edit by hand')
    ..writeln()
    ..write(addAssetClassBuffer(folderFileMap))
    ..writeln()
    ..writeAll(
      folderFileMap.keys.map(
        (folder) {
          final className = Utils.kebabToPascalCase(folder);
          final folderClassBuff = StringBuffer('final class $className {')
            ..writeln()
            ..writeln('const $className ();')
            ..writeAll(
              folderFileMap[folder]!.entries.map(
                (e) {
                  final assetName = e.key.split('.').first;
                  final containsCat = assetName.contains('-');
                  if (!containsCat) {
                    return "String get $assetName => '${e.value}'; $lineTerm";
                  }
                  return '';
                },
              ),
            )
            ..writeAll(folderFileMap[folder]!.entries.map((e) {
              final lineTerm = Platform.lineTerminator;
              final assetName = e.key.split('.').first;
              if (!assetName.contains('-')) return '';
              final assetCategory = assetName.split('-').first;
              if (catCache.containsKey(assetCategory)) {
                return '';
              } else {
                catCache[assetCategory] = 'hello';
                final assetCatPascal = Utils.snakeTOPascalCase(assetCategory);
                final assetCatCamel = Utils.snakeToCamelCase(assetCategory);

                return 'static const $assetCatCamel = $assetCatPascal ( ); $lineTerm';
              }
            }))
            ..writeln('}');

          return folderClassBuff;
        },
      ),
    );

  await File(path.join(
          cwd.path, 'lib', 'src', 'core', 'app_assets', 'assets.dart'))
      .writeAsString(fileBuffer.toString());
}

StringBuffer addCategoryClassBuffer(Map<String, Map<String, String>> map) {
  final lineTerm = Platform.lineTerminator;
  return StringBuffer()
    ..writeAll(
      map.entries.map(
        (e) {
          final assetNameWithCategory =
              Utils.kebabToPascalCase(e.key.split('.').first);
          if (!assetNameWithCategory.contains('-')) return '';
          final split = assetNameWithCategory.split('-');
          final assetCategory = split.first;
          final assetName = split[1];
          final assetCatPascal = Utils.snakeTOPascalCase(assetCategory);
          final categoryBuff = StringBuffer()
            ..writeln('final class $assetCatPascal { ')
            ..writeAll(
              map.entries.map(
                (e) {
                  return "String get $assetName => '${e.value}'; $lineTerm";
                },
              ),
            );
          return categoryBuff;
        },
      ),
    );
}

StringBuffer addAssetClassBuffer(Map<String, Map<String, String>> map) {
  final lineTerm = Platform.lineTerminator;
  return StringBuffer()
    ..write('final class AppAsset {')
    ..writeAll(map.keys.map((key) {
      final className = Utils.kebabToPascalCase(key);
      //INFO: static const className = ClassName();
      return '\t static const asset$className = Asset$className() ; $lineTerm';
    }))
    ..writeln()
    ..writeln('}');
}
