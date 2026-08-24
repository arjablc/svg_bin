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


> [!WARNING]
> This package started as one off util and I decided I should publish it to pub.dev, at that time I was only concerned with 
> compiling vectors and then generating the app assets dart file with file paths.
> With time I wanted something more than that, and the name svg_bin won't do it any justice. 
> I am moving to a new package on pub.dev. Come along to path_gen
>
> This package is discontinued and will no longer receive updates or support. Please avoid using it in new projects.
> 

# SVG_BIN
A Flutter asset generator that optionally converts SVG files to `.vec` with `vector_graphics_compiler` and generates typed asset paths.
- [vector_graphics_compiler](https://pub.dev/packages/vector_graphics_compiler)
- [vector_graphics](https://pub.dev/packages/vector_graphics)
## Features
- [x] generate .vec files
- [x] generate asset classes for arbitrary directory depth
- [x] scan raw assets such as PNG, JPEG, JSON, and SVG
- [x] cache the full asset pipeline with a hash-based manifest
- [x] configure input and generated Dart directories in `pubspec.yaml`



## Getting started

- Install the package using following command inside your flutter project.

``` bash
flutter pub add svg_bin
```

- Generate the vec files using the following command
``` bash
dart run svg_bin
```
- The `AppAsset` class is generated inside `/lib/assets/app_asset.dart` by default.
- Render the .vec with the `SvgBin()` widget


## Usage

Configure the source asset and generated Dart directories in the consumer app's `pubspec.yaml`:

```yaml
svg_bin:
  input: assets
  output: lib/assets
  generate_all_getter: false
  transform_svg_to_vec: true
```

Both paths are relative to the app root. The generated file is `app_asset.dart` in the configured output directory. `generate_all_getter` adds a direct-files-only `List<String> get all` to generated classes.

Assets are scanned recursively. Raw files such as PNG, JPEG, and JSON are used directly. With `transform_svg_to_vec: true`, SVG output is written to a sibling `*-bin` directory and must be declared in the app's `flutter.assets`; those generated directories are excluded from scanning. Set it to `false` to use raw SVG paths instead. `SvgBin` only renders compiled `.vec` paths.

For example:
```
assets/illustrations/animals/birds/eagle.png
assets/icons/post/ico1.svg
```
generates `AppAsset.illustrations.animals.birds.eagle` and `AppAsset.icons.post.ico1`.

Then run `dart run svg_bin` at the app root. Make sure generated `*-bin` directories are included under `flutter.assets` when SVG compilation is enabled.

For assets like:
```
assets/icons/post/ico1.svg
assets/icons/post/ico3.svg
```
after running the command
```dart
SvgBin(
  AppAsset.icons.post.ico1,
)

final postIcons = AppAsset.icons.post.all;
```

## Additional information

Very special thanks to [Avishek Subedi](https://github.com/Avishek-Subedi) dai.
