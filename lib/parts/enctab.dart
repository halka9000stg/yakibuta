import "dart:convert";

import "package:charset/charset.dart";
import "package:enough_convert/koi8.dart";
import "package:enough_convert/big5.dart";

import "package:yakibuta/parts/types.dart";
import "package:yakibuta/encodings/iso2022jp.dart";

class EncodingTab {
  List<EncodingTabRec> _recs;

  EncodingTab():
    this._recs = <EncodingTabRec>[];
  EncodingTab.from(Iterable<EncodingTabRec> recs):
    this._recs = recs.toList();

  bool hasKey(String key)
    => this._recs.any((EncodingTabRec r) => r.key == key);

  void add(String key, Encoding encoding, {
      String? group, String? series,
      int? nr, String? variant, bool showable = true}) {
    if(this.hasKey(key)) {
      throw 0;
    }
    this._recs.add(etr(
        key, encoding, group: group,
        series: series, nr: nr, variant: variant,
        showable: showable));
    this._recs.sort();
  }
  Encoding search(String cand){
    Iterable<EncodingTabRec> t
      = this._recs.where((EncodingTabRec r)
        => r.key == cand || r.encoding.name == cand);
    if(t.isNotEmpty) {
      return t.first.encoding;
    } else {
      throw 0;
    }
  }
  List<String> list([bool useCounter = false])
    => this._recs.indexed
      .map<String>(((int, EncodingTabRec) r)
        => (!useCounter ? "-" :  "${(r.$1 + 1).toString()}.") + " ${r.$2.key}:\t${r.$2.encoding.name}" + (r.$2.showable ? "\t(${r.$2.shows})" : ""))
      .toList();
  String showList([bool useCounter = false]) => "\a\n" + this.list(useCounter).join("\n") + "\v\r\0";
  
  static EncodingTab get dflt {
    final t = EncodingTab();
    // Unicodes
    t.add("u8", utf8, series: "UTF", group: "Unicode", nr: 8);
    t.add("u16", utf16, series: "UTF", group: "Unicode", nr: 16);
    t.add("u32", utf32, series: "UTF", group: "Unicode", nr: 32);
    // EUCs
    t.add("euc", eucJp, series: "EUC", group: "Unix", variant: "JP");
    t.add("euck", eucKr, series: "EUC", group: "Unix", variant: "KR");
    // CJKVs
    t.add("sjis", shiftJis, group: "CJKV", series: "JP");
    t.add("iso", iso2022jp, series: "ISO 2022", group: "CJKV", variant: "JP");
    t.add("big5", big5, group: "CJKV", series: "ZH");
    // ISO-8859s
    t.add("lat1", latin1, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 1);
    t.add("lat2", latin2, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 2);
    t.add("lat3", latin3, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 3);
    t.add("lat4", latin4, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 4);
    t.add("lat5", latin5, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 5);
    t.add("lat6", latin6, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 6);
    t.add("lat7", latin7, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 7);
    t.add("lat8", latin8, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 8);
    t.add("lat9", latin9, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 9);
    t.add("lat10", latin10, series: "ISO 8859", group: "ISO Extended ASCII-like", nr: 10);
    t.add("latc", latinCyrillic, series: "ISO 8859", group: "ISO Extended ASCII-like", variant: "Cyrillic");
    t.add("lata", latinArabic, series: "ISO 8859", group: "ISO Extended ASCII-like", variant: "Arabic");
    t.add("latg", latinGreek, series: "ISO 8859", group: "ISO Extended ASCII-like", variant: "Greek");
    t.add("lath", latinHebrew, series: "ISO 8859", group: "ISO Extended ASCII-like", variant: "Hebrew");
    t.add("latt", latinThai, series: "ISO 8859", group: "ISO Extended ASCII-like", variant: "Thai");
    // Others
    t.add("koi8r", Koi8rCodec(), series: "KOI8", variant: "R");
    t.add("koi8u", Koi8uCodec(), series: "KOI8", variant: "U");
    t.add("ascii", ascii, series: "US America", showable: false);
    return t;
  }
}