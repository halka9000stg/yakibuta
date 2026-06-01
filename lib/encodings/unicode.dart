import "dart:convert";

const NativeUnicodeCodec unicode = NativeUnicodeCodec();

class NativeUnicodeCodec extends Encoding {
  @override
  final String name = "Unicode-CodePoints";
  @override
  final Converter<String, List<int>> encoder = const NativeUnicodeEncoder();
  @override
  final Converter<List<int>, String> decoder = const NativeUnicodeDecoder();
  const NativeUnicodeCodec();
}
class NativeUnicodeEncoder extends Converter<String, List<int>> {
  const NativeUnicodeEncoder();
  @override
  List<int> convert(String src)
    => src.runes.toList();
}
class NativeUnicodeDecoder extends Converter<List<int>, String> {
  const NativeUnicodeDecoder();
  @override
  String convert(List<int> src)
    => src.map<String>((int se) => String.fromCharCode(se)).join("");
}