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
  void add(String key, Encoding encoding) {
    if(this.hasKey(key)) {
      throw 0;
    }
    this._recs.add((key: key, encoding: encoding));
    this._recs.sort((EncodingTabRec a, EncodingTabRec b) => a.compareTo(b));
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
        => (!useCounter ? "-" :  "${(r.$1 + 1).toString()}.") + " ${r.$2.key}: ${r.$2.encoding.name}")
      .toList();
  String showList([bool useCounter = false]) => "\a\n" + this.list(useCounter).join("\n") + "\v\r\0";
  
  static EncodingTab get dflt {
    final t = EncodingTab();
    // Unicodes
    t.add("u8", utf8);
    t.add("u16", utf16);
    t.add("u32", utf32);
    // EUCs
    t.add("euc", eucJp);
    t.add("euck", eucKr);
    // CJKVs
    t.add("sjis", shiftJis);
    t.add("iso", iso2022jp);
    t.add("big5", big5);
    // ISO-8859s
    t.add("lat1", latin1);
    t.add("lat2", latin2);
    t.add("lat3", latin3);
    t.add("lat4", latin4);
    t.add("lat5", latin5);
    t.add("lat6", latin6);
    t.add("lat7", latin7);
    t.add("lat8", latin8);
    t.add("lat9", latin9);
    t.add("lat10", latin10);
    t.add("latc", latinCyrillic);
    t.add("lata", latinArabic);
    t.add("latg", latinGreek);
    t.add("lath", latinHebrew);
    t.add("latt", latinThai);
    // Others
    t.add("koi8r", Koi8rCodec());
    t.add("koi8u", Koi8uCodec());
    t.add("ascii", ascii);
    return t;
  }
}