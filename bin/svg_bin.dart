import 'dart:io';
import 'package:args/args.dart' show ArgParser, ArgResults;

import 'package:svg_bin/src/constants.dart';
import 'package:svg_bin/src/create_bin.dart';
import 'package:svg_bin/src/enums.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    //..addFlag(
    //  'cat',
    //  abbr: 'c',
    //  defaultsTo: false,
    //  negatable: false,
    //  help: "whether to create category classes or not",
    //)
    ..addFlag(
      ArgsEnum.h.name,
      abbr: ArgsEnum.h.abbr,
      help: ArgsEnum.h.help,
    )
    ..addOption(
      ArgsEnum.output.name,
      abbr: ArgsEnum.output.abbr,
      help: ArgsEnum.output.help,
      defaultsTo: "$defaultAssetFolder$defaultAssetFile",
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    stderr
      ..write(e.message)
      ..writeln()
      ..write(parser.usage);
    exit(1);
  }

  stdout.write(intro);
  //INFO: wont ever be null because of the default value
  final outDir = results.option(ArgsEnum.output.name)!;
  final isHelp = results.flag(ArgsEnum.h.name) as bool?;

  if (isHelp != null && isHelp == true) {
    stdout.write(parser.usage);
    exit(0);
  }

  if (validOutputDir(outDir)) {
    await generate(outDir);
  } else {
    await generate(outDir);
  }
}

bool validOutputDir(String path) {
  final Directory dir = File(path).parent;
  if (dir.existsSync()) {
    return true;
  }
  dir.createSync(recursive: true);
  return false;
}
