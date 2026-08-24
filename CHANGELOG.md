## Unreleased
Feat: Scan recursive mixed asset directories and generate arbitrary-depth APIs.
Feat: Track all assets in a relative-path manifest and remove stale compiled output.

## 0.4.1
Fix: Generate category assets in a stable order so `all` is deterministic.
Docs: Document category directories and category `all` getters.
Test: Cover nested category asset generation.

## 0.4.0
Feat: Universal casing normalization for generated classes.
    - Class names are now properly normalized to PascalCase
    - Variable names are normalized to camelCase
    - Handles any input format: snake_case, kebab-case, space separated, dot.separated, camelCase, PascalCase, and mixed formats
    - Added example project demonstrating usage

## 0.3.0
Feat: Added caching for pre-generated SVG files using hash-based manifest.
    - Only recompiles SVGs that have changed, significantly improving build times
    - Added tree traversal structure for asset paths
    - Refactored codebase: separated dart generator and svg processor into dedicated modules

## 0.2.1
Chore: Upgrade packages

## 0.2.0
Feat: Added arguments to the cli for now the -o or --output options are added, also added the help (--help or -h).

## 0.1.310
Fix: Use the icon asset variable name rather than putting the whole path, making the "all" a getter.

## 0.1.300
Bugfix: fixed the bug where you got vector_graphics_compiler is not found.

## 0.1.3
Bugfix: fixed the bug where you got `vector_graphics_compiler` is not found.

## 0.1.210
Bugfix: Fixed a bug where accessing properties of category class was not possible.
Minor: Added feature for colorFilter for the SvgBin widget.

## 0.1.1
Updated readme.
    - Specified the output dir and file

## 0.1.0
Initial version supports generating the vec files,
    - generating the assets file with the folder and category class
