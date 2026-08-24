import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:svg_bin/src/asset_scanner.dart';
import 'package:svg_bin/src/config.dart';
import 'package:svg_bin/src/generator/dart_generator.dart';
import 'package:svg_bin/src/processors/svg_processor.dart';
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

    final assets = await AssetScanner(
      assetPath: '${root.path}/assets',
      projectPath: root.path,
      isExcluded: SvgProcessor().isGeneratedOutput,
    ).scan();
    final code = DartGenerator(generateAllGetter: true).generate(assets);

    expect(assets.map((asset) => asset.relativePath), [
      'icons/post/ico1.svg',
      'icons/post/ico3.svg',
      'icons/root.svg',
    ]);
    expect(
      SvgProcessor().outputFor(assets.first),
      '${root.path}/assets/icons-bin/post/ico1.svg.vec',
    );
    expect(code, contains('IconsPost get post => const IconsPost();'));
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

    final assets = await AssetScanner(
      assetPath: '${root.path}/assets',
      projectPath: root.path,
      isExcluded: SvgProcessor().isGeneratedOutput,
    ).scan();
    final code = DartGenerator().generate(assets);

    expect(assets.single.runtimePath, 'assets/icons/home-icon.SVG');
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

    final assets = await AssetScanner(
      assetPath: '${root.path}/assets',
      projectPath: root.path,
      isExcluded: SvgProcessor().isGeneratedOutput,
    ).scan();

    expect(
      () => DartGenerator().generate(assets),
      throwsA(isA<StateError>()),
    );
  });

  test('scans raw assets at arbitrary depth and excludes generated output',
      () async {
    final root = await Directory.systemTemp.createTemp('svg_bin_test_');
    addTearDown(() => root.delete(recursive: true));

    final assets = Directory('${root.path}/assets');
    await Directory('${assets.path}/illustrations/animals/birds')
        .create(recursive: true);
    await Directory('${assets.path}/illustrations-bin').create();
    await File('${assets.path}/illustrations/animals/birds/eagle.png')
        .writeAsBytes([0]);
    await File('${assets.path}/data.json').writeAsString('{}');
    await File('${assets.path}/illustrations-bin/eagle.png.vec')
        .writeAsBytes([0]);

    final scanned = await AssetScanner(
      assetPath: assets.path,
      projectPath: root.path,
      isExcluded: SvgProcessor().isGeneratedOutput,
    ).scan();
    final code = DartGenerator().generate(scanned);

    expect(scanned.map((asset) => asset.relativePath), [
      'data.json',
      'illustrations/animals/birds/eagle.png',
    ]);
    expect(code, contains("static const data = 'assets/data.json';"));
    expect(code, contains('IllustrationsAnimalsBirds get birds'));
  });
}
