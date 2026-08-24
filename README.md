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


# SVG_BIN
A helper Flutter package that converts your `.svg` files to binary with the extension `.vec` using `vector_graphics_compiler` and provides a widget to render those .vec files using `vector_graphics` package.
- [vector_graphics_compiler](https://pub.dev/packages/vector_graphics_compiler)
- [vector_graphics](https://pub.dev/packages/vector_graphics)
### Note: **Under Construction**

## Features
- [x] generate .vec files
- [x] generate asset class
    - [x] folder asset class
    - [x] category class
- [x] caching: only recompiles changed SVGs (hash-based manifest)
- [x] configure input and generated Dart directories in `pubspec.yaml`
- [x] separate converting files and creating the dart file
- [ ] separate the bin folders out of the asset folder



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

Configure the source SVG and generated Dart directories in the consumer app's `pubspec.yaml`:

```yaml
svg_bin:
  input: assets
  output: lib/assets
  generate_all_getter: false
  transform_svg_to_vec: true
```

Both paths are relative to the app root. The generated file is `app_asset.dart` in the configured output directory. `generate_all_getter` is opt-in and adds a direct-files-only `List<String> get all` to generated classes. Set `transform_svg_to_vec` to `false` to skip `.vec` compilation and generate paths to the source SVG files instead; those paths cannot be rendered with `SvgBin`.

- Organize assets by folder and category:
```
assets/icons/post/ico1.svg
assets/icons/post/ico3.svg
```
- This generates nested asset getters and an `all` getter for each category.
- Make sure you have imported the bin folders into the `pubspec.yml` of your flutter project. (Don't want to mess with yml just yet).
- Then just do `dart run svg_bin` at root of your flutter project.
- To use the `.vec` assets use the `SvgBin()` widget
- **For the love of god** don't make your category or folder name same as some of the inbuilt classes in Dart and Flutter.

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
