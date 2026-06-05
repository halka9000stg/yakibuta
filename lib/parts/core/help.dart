import "package:yakibuta/common/libmisc.dart";

class CharHelp {
  static String get usage => r"""【USAGE】
  `char ((:(<format><encoding>)?(<byte-array>|<native-string>)*)|(\*<command> <argument>*))*`
""";
  static String get help => CharHelp.usage.nl(2) + """"
  
more information: see https://pub.dev/packages/yakibuta""";
}