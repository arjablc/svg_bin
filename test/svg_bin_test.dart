import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:svg_bin/src/config.dart';
import 'package:svg_bin/src/generator/dart_generator.dart';
import 'package:svg_bin/src/models/asset_tree.dart';
import 'package:svg_bin/src/utils.dart';

void main() {
  test('reads directories from the svg_bin pubspec section', () {
    final defaults = SvgBinConfig.fromPubspec('name: example');
    final config = SvgBinConfig.fromPubspec('''
svg_bin:
  input: assets/source
  output: lib/generated
  generate_all_getter: true
  transform_svg_to_vec: false
''');

    expect(defaults.generateAllGetter, isFalse);
    expect(defaults.transformSvgToVec, isTrue);
    expect(config.input, 'assets/source');
    expect(config.output, 'lib/generated');
    expect(config.generateAllGetter, isTrue);
    expect(config.transformSvgToVec, isFalse);
  });

  test('generates direct-file all getters when enabled', () async {
    final root = await Directory.systemTemp.createTemp('svg_bin_test_');
    addTearDown(() => root.delete(recursive: true));

    final icons = Directory('${root.path}/assets/icons');
    final post = Directory('${icons.path}/post');
    await post.create(recursive: true);
    await File('${icons.path}/root.svg').writeAsString('<svg/>');
    await File('${post.path}/ico1.svg').writeAsString('<svg/>');
    await File('${post.path}/ico3.svg').writeAsString('<svg/>');

    final tree = await AssetTree.buildFromDirectory('${root.path}/assets');
    final folder = tree.folders.single;
    final category = folder.categories.single;
    final code = DartGenerator(generateAllGetter: true).generate(tree);

    expect(folder.name, 'icons');
    expect(category.name, 'post');
    expect(category.files.map((file) => file.name), ['ico1', 'ico3']);
    expect(
      category.files.map((file) => file.outputPath),
      everyElement(contains('icons-bin/post/')),
    );
    expect(code, contains('Post get post => Post();'));
    expect(code, contains('String get ico1'));
    expect(code, contains('String get ico3'));
    expect(code, contains('List<String> get all => [\n    root,\n  ];'));
    expect(
      code,
      contains('List<String> get all => [\n    ico1,\n    ico3,\n  ];'),
    );
  });

  test('omits all getters and keeps raw SVG paths when configured', () async {
    final root = await Directory.systemTemp.createTemp('svg_bin_test_');
    addTearDown(() => root.delete(recursive: true));

    final icons = Directory('${root.path}/assets/icons');
    await icons.create(recursive: true);
    await File('${icons.path}/home-icon.SVG').writeAsString('<svg/>');

    final tree = await AssetTree.buildFromDirectory(
      '${root.path}/assets',
      transformSvgToVec: false,
    );
    final file = tree.folders.single.files.single;
    final code = DartGenerator().generate(tree);

    expect(file.outputPath, file.sourcePath);
    expect(code, contains("String get homeIcon => '"));
    expect(code, contains('.SVG\';'));
    expect(code, isNot(contains('List<String> get all')));
  });

  test('normalizes generated Dart identifiers', () {
    expect(Utils.toPascalCase('123-icons'), 'Asset123Icons');
    expect(Utils.toCamelCase('123-icons'), 'asset123Icons');
    expect(Utils.toPascalCase('XMLParser'), 'XmlParser');
    expect(Utils.toCamelCase('class'), 'classAsset');
    expect(Utils.toCamelCase('home@icon'), 'homeIcon');
  });

  test('rejects names that generate the same member', () async {
    final root = await Directory.systemTemp.createTemp('svg_bin_test_');
    addTearDown(() => root.delete(recursive: true));

    final icons = Directory('${root.path}/assets/icons');
    await icons.create(recursive: true);
    await File('${icons.path}/home-icon.svg').writeAsString('<svg/>');
    await File('${icons.path}/home_icon.svg').writeAsString('<svg/>');

    final tree = await AssetTree.buildFromDirectory('${root.path}/assets');

    expect(
      () => DartGenerator().generate(tree),
      throwsA(isA<StateError>()),
    );
  });
}
