# SVG Bin Example

This example demonstrates how to use the `svg_bin` package to convert SVG files to binary `.vec` format and display them in a Flutter app.

## Project Structure

```
example/
├── assets/
│   └── icons/
│       ├── star.svg              # Root level icon
│       ├── st-icons/             # Kebab-case category folder
│       │   ├── home-icon.svg
│       │   └── settings_icon.svg
│       └── nav_icons/            # Snake_case category folder
│           ├── arrow-left.svg
│           └── arrow_right.svg
├── lib/
│   ├── assets/
│   │   └── app_asset.dart        # Generated file
│   └── main.dart
└── pubspec.yaml
```

## How to Run

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate the `.vec` files and asset classes:
   ```bash
   dart run svg_bin
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Naming Convention Normalization

The package automatically normalizes folder and file names to proper Dart naming conventions:

| Input (any format) | Class Name (PascalCase) | Variable Name (camelCase) |
|--------------------|------------------------|---------------------------|
| `st-icons` | `StIcons` | `stIcons` |
| `nav_icons` | `NavIcons` | `navIcons` |
| `home-icon` | - | `homeIcon` |
| `settings_icon` | - | `settingsIcon` |
| `arrow-left` | - | `arrowLeft` |
| `arrow_right` | - | `arrowRight` |

## Usage in Code

```dart
import 'package:svg_bin/svg_bin.dart';
import 'assets/app_asset.dart';

// Basic usage
SvgBin(AppAsset.icons.star)

// With size
SvgBin(
  AppAsset.icons.stIcons.homeIcon,
  width: 32,
  height: 32,
)

// With color filter
SvgBin(
  AppAsset.icons.star,
  width: 32,
  height: 32,
  colorFilter: ColorFilter.mode(
    Colors.amber,
    BlendMode.srcIn,
  ),
)
```
