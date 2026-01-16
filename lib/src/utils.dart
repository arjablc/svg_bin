/// Util function to change the case
library;

class Utils {
  /// Splits input into words by detecting separators and case boundaries.
  /// Handles: snake_case, kebab-case, space separated, dot.separated,
  /// camelCase, PascalCase, and mixed formats.
  static List<String> _splitIntoWords(String input) {
    if (input.isEmpty) return [];

    // First, replace common separators with a single separator
    var normalized = input
        .replaceAll(RegExp(r'[-_.\s]+'), ' ')
        .trim();

    // Split on spaces and camelCase/PascalCase boundaries
    final words = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < normalized.length; i++) {
      final char = normalized[i];

      if (char == ' ') {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString());
          buffer.clear();
        }
      } else if (i > 0 &&
          _isUpperCase(char) &&
          buffer.isNotEmpty &&
          !_isUpperCase(normalized[i - 1])) {
        // camelCase boundary: lowercase followed by uppercase
        words.add(buffer.toString());
        buffer.clear();
        buffer.write(char);
      } else if (i > 0 &&
          i < normalized.length - 1 &&
          _isUpperCase(char) &&
          _isUpperCase(normalized[i - 1]) &&
          !_isUpperCase(normalized[i + 1]) &&
          normalized[i + 1] != ' ') {
        // Handle acronyms: "XMLParser" -> "XML", "Parser"
        words.add(buffer.toString());
        buffer.clear();
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      words.add(buffer.toString());
    }

    return words.where((w) => w.isNotEmpty).toList();
  }

  static bool _isUpperCase(String char) {
    return char.toUpperCase() == char && char.toLowerCase() != char;
  }

  /// Converts any input format to PascalCase.
  /// Handles: snake_case, kebab-case, space separated, camelCase, etc.
  static String toPascalCase(String input) {
    final words = _splitIntoWords(input);
    if (words.isEmpty) return input;

    return words
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join();
  }

  /// Converts any input format to camelCase.
  /// Handles: snake_case, kebab-case, space separated, PascalCase, etc.
  static String toCamelCase(String input) {
    final words = _splitIntoWords(input);
    if (words.isEmpty) return input;

    return words.asMap().entries.map((entry) {
      final word = entry.value;
      if (entry.key == 0) {
        return word.toLowerCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();
  }

  // Legacy methods kept for backwards compatibility
  static String kebabToPascalCase(String input) => toPascalCase(input);
  static String snakeToCamelCase(String input) => toCamelCase(input);
  static String snakeTOPascalCase(String input) => toPascalCase(input);
  static String kebabToCamelCase(String input) => toCamelCase(input);
}
