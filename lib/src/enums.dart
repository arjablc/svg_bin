enum ArgsEnum {
  output(
      abbr: 'o',
      name: "output",
      help:
          "The file where the generated path class is kept. Note: Provide the filename and extension as well.");

  final String name;
  final String help;
  final String abbr;

  const ArgsEnum({required this.name, required this.abbr, required this.help});
}
