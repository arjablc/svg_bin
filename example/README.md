# Path Gen Example

This example demonstrates recursive asset-path generation in Flutter. It uses `flutter_svg` to render the generated SVG paths.

## Project Structure

```
example/
├── assets/
│   └── icons/
│       ├── star.svg              # Root level icon
│       ├── st-icons/             # Kebab-case nested folder
│       │   ├── home-icon.svg
│       │   └── settings_icon.svg
│       └── nav_icons/            # Snake_case nested folder
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

2. Generate the asset classes:
   ```bash
   dart run path_gen
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
import 'package:flutter_svg/flutter_svg.dart';
import 'assets/app_asset.dart';

// Basic usage
SvgPicture.asset(AppAsset.icons.star)

// With size
SvgPicture.asset(
  AppAsset.icons.stIcons.homeIcon,
  width: 32,
  height: 32,
)

// With color filter
SvgPicture.asset(
  AppAsset.icons.star,
  width: 32,
  height: 32,
  colorFilter: ColorFilter.mode(
    Colors.amber,
    BlendMode.srcIn,
  ),
)
```
