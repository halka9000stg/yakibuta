import "dart:convert";

import "package:charset/charset.dart";
import "package:enough_convert/koi8.dart";
import "package:enough_convert/big5.dart";

import "package:yakibuta/parts/types.dart";
import "package:yakibuta/parts/error.dart";
import "package:yakibuta/encodings/iso2022jp.dart";
import "package:yakibuta/encodings/unicode.dart";

class EncodingTab {
  List<EncodingTabRec> _recs;

  EncodingTab():
    this._recs = <EncodingTabRec>[];
  EncodingTab.from(Iterable<EncodingTabRec> recs):
    this._recs = recs.toList();

  bool hasKey(String key)
    => this._recs.any((EncodingTabRec r) => r.key == key);

  void add(String key, Encoding encoding, {
      List<String> alt = const <String>[],
      String? group, String? series,
      int? nr, String? variant}) {
    if(this.hasKey(key)) {
      throw EncodingKeyUsedErr(key, encoding, this);
    }
    this._recs.add(etr(
        key, encoding, alt: alt, group: group,
        series: series, nr: nr, variant: variant));
    this._recs.sort();
  }
  Encoding search(String cand){
    Iterable<EncodingTabRec> t
      = this._recs.where((EncodingTabRec r)
        => toLC(r.key) == toLC(cand) || toLC(r.encoding.name) == toLC(cand));
    if(t.isNotEmpty) {
      return t.first.encoding;
    } else {
      throw NoSuchAsEncodingErr(cand, this._recs);
    }
  }
  List<String> list([bool useCounter = false])
    => this._recs.indexed
      .map<String>(((int, EncodingTabRec) r)
        => (!useCounter ? "-" :  (" " * (((this._recs.indexed.lastOrNull?.$1 ?? 0).toString().length) - (r.$1 + 1).toString().length)) + "${(r.$1 + 1).toString()}.") + " ${r.$2.key}:" + ("\t" * (r.$2.key.length <= 2 ? 2 : 1)) + r.$2.encoding.name)
      .toList();
  String showList([bool useCounter = false]) => "\a\n" + this.list(useCounter).join("\n") + "\v\r\0";
  
  static EncodingTab get dflt {
    final t = EncodingTab();
    // Unicodes
    t.add("u8", utf8.renamedUC, series: "UTF", group: "Unicode", nr: 8);
    t.add("u16", utf16.renamedUC, series: "UTF", group: "Unicode", nr: 16);
    t.add("u32", utf32.renamedUC, series: "UTF", group: "Unicode", nr: 32);
    t.add("uni", unicode, series: "CodePoints", group: "Unicode");
    // EUCs
    t.add("euc", eucJp.renamedUC, series: "EUC", group: "Unix", variant: "JP");
    t.add("euck", eucKr.renamedUC, series: "EUC", group: "Unix", variant: "KR");
    // CJKVs
    t.add("sjis", shiftJis.renamed("Shift_JIS"), group: "CJKV", series: "JP");
    t.add("iso", iso2022jp, series: "ISO 2022", group: "CJKV", variant: "JP");
    t.add("big5", big5, group: "CJKV", series: "ZH");
    // ISO-8859s
    t.add("lat1", latin1.renamedUC, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 1);
    t.add("lat2", latin2.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 2);
    t.add("lat3", latin3.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 3);
    t.add("lat4", latin4.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 4);
    t.add("lat5", latin5.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 9);
    t.add("lat6", latin6.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 10);
    t.add("lat7", latin7.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 13);
    t.add("lat8", latin8.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 14);
    t.add("lat9", latin9.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 15);
    t.add("lat10", latin10.renamedBy(_latins), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 16);
    t.add("latc", latinCyrillic.renamed(_latins_i(5)), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 5);
    t.add("lata", latinArabic.renamed(_latins_i(6)), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 6);
    t.add("latg", latinGreek.renamed(_latins_i(7)), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 7);
    t.add("lath", latinHebrew.renamed(_latins_i(8)), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 8);
    t.add("latt", latinThai.renamed("TIS-620"), series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 11);
    // Others
    t.add("koi8r", Koi8rCodec(), series: "KOI8", variant: "R");
    t.add("koi8u", Koi8uCodec(), series: "KOI8", variant: "U");
    t.add("ascii", ascii.renamedUC, series: "US America");
    return t;
  }
}

typedef StrConv = String Function(String);

extension StrConvExt on StrConv {
  StrConv fuse(StrConv other)
    => (String input) => other(this(input));
}

final StrConv toUC = (String input) => input.toUpperCase();
final StrConv toLC = (String input) => input.toLowerCase();
final StrConv _latins = (String input) {
  if(!toLC(input).startsWith("latin-")){
    return input;
  }
  int nrLat = int.parse(input.split("-").last);
  int nr = switch(nrLat){
    <= 4 => nrLat,
    5 => 9,
    6 => 10,
    >= 7 => nrLat + 6,
    _ => throw 0,
  };
  return _latins_i(nr);
};
String _latins_i(int nr) => "ISO-8859-$nr";

class RenamedEncoding<E extends Encoding> extends Encoding {
  @override
  final String name;
  final E underlying;
  
  RenamedEncoding(this.underlying, String newName):
    this.name = newName;
  RenamedEncoding.by(E underlying, StrConv renameRule):
    this.underlying = underlying,
    this.name = renameRule(underlying.name);
    
    @override
    Converter<String, List<int>> get encoder => this.underlying.encoder;
    @override
    Converter<List<int>, String> get decoder => this.underlying.decoder;
}

extension RenamedEncodingExt<E extends Encoding> on E {
  Encoding renamed(String name)
    => RenamedEncoding<E>(this, name);
  Encoding renamedBy(StrConv renameRule)
    => RenamedEncoding.by(this, renameRule);
  Encoding renamedUCTo(String name)
    => this.renamed(toUC(name));
  Encoding renamedUCBy(StrConv renameRule)
    => RenamedEncoding.by(this, renameRule.fuse(toUC));
  Encoding get renamedUC
    => RenamedEncoding.by(this, toUC);
}