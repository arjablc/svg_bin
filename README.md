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
[vector_graphics_compiler](pub.dev/packages/vector_graphics_compiler)
[vector_graphics](https://pub.dev/packages/vector_graphics)

## Features
- [x] generate .vec files
- [ ] generate  asset class
    - [ ] folder asset class 
    - [ ] category class
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

<!--TODO: add usages-->

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

I am a beginner so help me out here.
Very special thanks to [Avishek Subedi](https://github.com/Avishek-Subedi) dai.

