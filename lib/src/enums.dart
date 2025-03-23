enum ArgsEnum {
  output(
      abbr: 'o',
      name: "output",
      help:
          "The file where the generated path class is kept.\n Note: Provide the filename and extension as well."),
  h(abbr: 'h', name: "help", help: "Prints this help message");

  final String name;
  final String help;
  final String abbr;

  const ArgsEnum({required this.name, required this.abbr, required this.help});
}
