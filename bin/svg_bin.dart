import 'dart:io';

import 'package:svg_bin/src/create_bin.dart';
import 'package:args/args.dart';
import 'package:svg_bin/src/constants.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'cat',
      abbr: 'c',
      defaultsTo: false,
      negatable: false,
      help: "whether to create category classes or not",
    )
    ..addOption('path',
        abbr: 'p',
        defaultsTo:
            "$defaultAssetFolder${Platform.pathSeparator}$defaultAssetFile",
        help: "The file where the generated path class is kept");

  try {
    final ArgResults res = parser.parse(args);
  } catch (e) {
    stderr
      ..write(e.toString())
      ..writeln("Args error")
      ..writeln()
      ..write(parser.usage);
  }
  //await generate();
}
