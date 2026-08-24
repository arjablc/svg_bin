import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:svg_bin/src/generator/dart_generator.dart';
import 'package:svg_bin/src/models/asset_tree.dart';

void main() {
  test('generates nested category getters and all', () async {
    final root = await Directory.systemTemp.createTemp('svg_bin_test_');
    addTearDown(() => root.delete(recursive: true));

    final post = Directory('${root.path}/assets/icons/post');
    await post.create(recursive: true);
    await File('${post.path}/ico1.svg').writeAsString('<svg/>');
    await File('${post.path}/ico3.svg').writeAsString('<svg/>');

    final tree = await AssetTree.buildFromDirectory('${root.path}/assets');
    final folder = tree.folders.single;
    final category = folder.categories.single;
    final code = DartGenerator().generate(tree);

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
    expect(
      code,
      contains('List<String> get all => [\n    ico1,\n    ico3,\n  ];'),
    );
  });
}
