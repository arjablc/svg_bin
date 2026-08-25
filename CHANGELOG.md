# Changelog

## 1.4.2

- Fixed generated `flutter.assets` entries: every directory containing outputs under a `*-bin/` tree is now registered, including nested ones.

## 1.4.1

- Renamed the package to `path_gen`.
- Generate typed Dart paths for recursively scanned assets.
- Optionally compile SVG files to `.vec`.
- Automatically add generated `*-bin/` directories to `flutter.assets`.
- Removed the Flutter widget API; render generated paths with your preferred Flutter package.
