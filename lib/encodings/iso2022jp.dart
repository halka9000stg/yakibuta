import "dart:convert";
import "package:jcombu/jcombu.dart" show convertJis;

final Iso2022jpCodec iso2022jp = Iso2022jpCodec();

class Iso2022jpCodec extends Encoding {
  @override
  final String name = "ISO-2022-JP";
  @override
  Converter<String, List<int>> get encoder {
    throw UnimplementedError();
  }
  @override
  final Converter<List<int>, String> decoder = Iso2022jpDecoder();
}

class Iso2022jpDecoder extends Converter<List<int>, String> {
  String convert(List<int> src) => convertJis(src);
}