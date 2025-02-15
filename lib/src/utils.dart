void main() {
  final snake = 'hello_world';
  final kebab = 'hello-world';
  final snake2 = 'Mawa';
  final snake3 = 'mawa';

  print(Utils.snakeToCamelCase(snake));
  print(Utils.snakeTOPascalCase(snake));
  print(Utils.kebabToPascalCase(kebab));
  print(Utils.kebabToCamelCase(kebab));
  print(Utils.snakeToCamelCase(snake2));
  print(Utils.snakeToCamelCase(snake3));
}

class Utils {
  static String kebabToPascalCase(String input) {
    return kebabToCamelCase(input).replaceFirstMapped(
      RegExp(r'^\w'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }

  static String snakeToCamelCase(String input) {
    if (input.contains('_')) {
      return input.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (Match match) => match.group(1)!.toUpperCase(),
      );
    }
    return input[0].toLowerCase() + input.substring(1);
  }

  static String snakeTOPascalCase(String input) {
    final camelCase = snakeToCamelCase(input);
    return camelCase[0].toUpperCase() + camelCase.substring(1);
  }

  static String kebabToCamelCase(String input) {
    final regex = RegExp(r'-(\w)');
    return input.replaceAllMapped(
      regex,
      (match) {
        final matchedString = match.group(0)!;
        return matchedString[1].toUpperCase();
      },
    );
  }
}
