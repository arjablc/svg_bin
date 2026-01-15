import 'dart:io';

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:svg_bin/src/constants.dart';
import 'package:svg_bin/src/create_bin.dart';
import 'package:svg_bin/src/enums.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      ArgsEnum.h.name,
      abbr: ArgsEnum.h.abbr,
      help: ArgsEnum.h.help,
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Force regeneration of all assets, ignoring cache',
      defaultsTo: false,
      negatable: false,
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

  final isHelp = results.flag(ArgsEnum.h.name);
  if (isHelp) {
    stdout.write(intro);
    stdout.writeln(parser.usage);
    exit(0);
  }

  stdout.write(intro);

  final outDir = results.option(ArgsEnum.output.name)!;
  final force = results.flag('force');

  final outputDir = File(outDir).parent;
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  await generate(outDir, force: force);
}
