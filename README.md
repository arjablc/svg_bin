<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->


# Path Gen

`path_gen` generates typed Dart asset paths from your asset directories. It can also compile SVG files to `.vec` with [`vector_graphics_compiler`](https://pub.dev/packages/vector_graphics_compiler).
## Features
- [x] optionally generate .vec files
- [x] generate asset classes for arbitrary directory depth
- [x] scan raw assets such as PNG, JPEG, JSON, and SVG
- [x] cache the full asset pipeline with a hash-based manifest
- [x] configure input and generated Dart directories in `pubspec.yaml`



## Install

Add `path_gen` to the consumer app:

``` bash
flutter pub add path_gen
```

Run it from that app's root:

``` bash
dart run path_gen
```

Or install the executable globally:

```bash
dart pub global activate path_gen
path_gen
```

The global command reads the `path_gen` configuration from the `pubspec.yaml` in the current directory, so it does not need to be added as a dependency to each consumer app.

## Configuration

Configure the source asset and generated Dart directories in the consumer app's `pubspec.yaml`:

```yaml
path_gen:
  input: assets
  output: lib/assets
  generate_all_getter: false
  transform_svg_to_vec: true
  update_flutter_assets: true
```

Both paths are relative to the app root. The generated file is `app_asset.dart` in the configured output directory. `generate_all_getter` adds a direct-files-only `List<String> get all` to generated classes.

Assets are scanned recursively. Raw files such as PNG, JPEG, JSON, and SVG are used directly. With `transform_svg_to_vec: true`, SVG output is written to a sibling `*-bin` directory and its top-level directory is added to a managed block in the app's `flutter.assets`. Set `update_flutter_assets: false` to prevent that update. Set `transform_svg_to_vec` to `false` to keep raw SVG paths and render them with your preferred package, such as `flutter_svg`.

For example:
```
assets/illustrations/animals/birds/eagle.png
assets/icons/post/ico1.svg
```
generates `AppAsset.illustrations.animals.birds.eagle` and `AppAsset.icons.post.ico1`.

Then run `dart run path_gen` at the app root. Make sure generated `*-bin` directories are included under `flutter.assets` when SVG compilation is enabled.

For assets like:
```
assets/icons/post/ico1.svg
assets/icons/post/ico3.svg
```
after running the command:
```dart
SvgPicture.asset(AppAsset.icons.post.ico1)

final postIcons = AppAsset.icons.post.all;
```

## Compared with flutter_gen

Like `flutter_gen`, `path_gen` generates typed asset paths. Unlike `flutter_gen`, it runs as a command when you choose, uses no `build_runner`, and can optionally compile SVG files to `.vec`.

## Additional information

Very special thanks to [Avishek Subedi](https://github.com/Avishek-Subedi) dai.
