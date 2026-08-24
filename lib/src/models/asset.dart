import 'package:path/path.dart' as path;

class Asset {
  final String sourcePath;
  final String relativePath;
  final String type;
  final String hash;
  final String runtimePath;

  const Asset({
    required this.sourcePath,
    required this.relativePath,
    required this.type,
    required this.hash,
    required this.runtimePath,
  });

  String get name => path.basenameWithoutExtension(relativePath);

  Asset copyWith({String? runtimePath}) => Asset(
        sourcePath: sourcePath,
        relativePath: relativePath,
        type: type,
        hash: hash,
        runtimePath: runtimePath ?? this.runtimePath,
      );
}
