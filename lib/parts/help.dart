import "package:yakibuta/types.dart" show NewLine;

class CharHelp {
  static String get usage => r"""【USAGE】
  `char ((:(<format><encoding>)?(<byte-array>|<native-string>)*)|(\*<command> <argument>*))*`
""";
  static String get help => CharHelp.usage.nl(2) + """"
""";
}