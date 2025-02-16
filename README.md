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
A helper flutter pacakge that converts your `.svg` files to binary with the extension `.vec` using `vector_graphics_compiler` and provides a widget to render those .vec files using `vector_graphics` package.
- [vector_graphics_compiler](pub.dev/packages/vector_graphics_compiler)
- [vector_graphics](https://pub.dev/packages/vector_graphics)
### Note: **Under Construction**

## Features
- [x] generate .vec files
- [x] generate  asset class
    - [x] folder asset class 
    - [x] category class
- [ ] add args parser to toggle category modes
- [ ] add args parser to change assets directory (input) and assets class directory(output)



## Getting started

- Install the package using following command inside your flutter project.

``` bash
flutter pub add svg_bin
```

- Generate the vec files using the following command
``` bash
dart run svg_bin
```

- Render the .vec with the `SvgBin()` widget


## Usage

**Currently this supports only one input direcotry which will be `/assets` in your flutter root.**
- Rename your assets to be in the following format:
```
assets/subfolder/category_name-asset_name.svg
```
- This will generate the main asset class, the sub folder class and the category name class, with String getters that will have the actual path of the asset.
- Make sure you have imported the bin folders into the `pubspec.yml` of your flutter project. (Don't want to mess with yml just yet).
- Then just do `dart run svg_bin` at root of your flutter project.
- To use the `.vec` assets use the `SvgBin()` widget
- **For the love of god** don't make your category or folder name same as some of the inbuilt classes in Dart and Flutter.

for a asset like 
```
assets/icons/finance-money.svg
```
after running the command
```dart
SvgBin(
    AppAsset.icons.finance.money,
    height: 100,
    width: 100,
    

)
```

## Additional information

I am a beginner so help me out here.
Very special thanks to [Avishek Subedi](https://github.com/Avishek-Subedi) dai.

