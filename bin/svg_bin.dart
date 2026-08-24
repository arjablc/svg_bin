import 'dart:io';

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:path/path.dart' as path;
import 'package:svg_bin/src/config.dart';
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

  final config = await SvgBinConfig.load(Directory.current);
  final outDir = results.option(ArgsEnum.output.name) ??
      path.join(config.output, defaultAssetFile);
  final force = results.flag('force');

  final outputDir = File(outDir).parent;
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  await generate(
    outDir,
    inputPath: config.input,
    generateAllGetter: config.generateAllGetter,
    transformSvgToVec: config.transformSvgToVec,
    force: force,
  );
}
