import "dart:convert";

import "package:yakibuta/types.dart";
import "package:yakibuta/conv.dart";

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
    t.add("ascii", ascii);
    t.add("u8", utf8);
    t.add("lat1", latin1);
    return t;
  }
}

enum ParseInstruction {
  hexInt("x"), binInt("b"), decInt("d"),
  nativeStr("n");

  const ParseInstruction(this.code);

  final String code;
  
  ErrorHandleConv<String, List<int>, ArgumentError> parserOf(Encoding encoding)
    => ErrorHandleConv<String, List<int>, ArgumentError>(switch(this) {
      .nativeStr => encoding.encoder,
      .hexInt => IntParser(16).asListFuse(),
      .binInt => IntParser(2).asListFuse(),
      .decInt=> IntParser(10).asListFuse(),
  }, (ArgumentError e){
    print(e.runtimeType);
    print(e);
    return <int>[];
});
  
  factory ParseInstruction.from(String s) {
    Iterable<ParseInstruction> cand
      = ParseInstruction.values
        .where((ParseInstruction i) => i.code == s);
    if(cand.isEmpty) {
      throw 0;
    }
    return cand.first;
  }
}

class Manager {
  final EncodingTab _tab;

  Manager(EncodingTab tab):
    this._tab = tab;

  List<int> fenceIndexes(List<String> argsOf) {
    List<int> ret = <int>[];
    late int tmp;
    int cout = 0;
    
    do {
      tmp = argsOf.indexWhere((String a) => Manager.re.hasMatch(a), (ret.lastOrNull ?? -1) + 1);
      
      //print("[${++cout}] tmp: ${tmp}");
      if(tmp == -1){
        break;
      }
      ret.add(tmp);
      if(ret.last + 1 >= argsOf.length){
        break;
      }
    } while(true);
    return ret;
  }
  List<Fence> getFences(List<String> argsOf) {
    List<int> ixs = this.fenceIndexes(argsOf);
    List<Fence> fcs = <Fence>[];
    for(int i = 0; i < ixs.length; i++) {
      fcs.add((
        type: InstructionType.investigate(argsOf[ixs[i]]),
        inst: argsOf[ixs[i]].substring(1),
        values: argsOf.sublist(
              ixs[i] + 1,
              i + 1 >= ixs.length ? null : ixs[i + 1])
            .map<String>((String s)
              => (s.startsWith("?:") || s.startsWith("?&"))
                ? s.substring(1) : s)
            .toList()
          ));
    }
    return fcs.map<Fence>((Fence f) => (f.inst == "" && f.type == InstructionType.core) ? (inst: "xascii", type: f.type, values: f.values) : f).toList();
  }
  List<String> process(List<String> argsOf)
    => this.getFences(argsOf)
      .map<String>((Fence f) => switch(f.type){
        .core => this._tab
          .search(f.inst.substring(1)).decode(
            f.values.map<List<int>>(
               ParseInstruction.from(
                      f.inst.substring(0, 1))
                   .parserOf(
                       this._tab.search(f.inst.substring(1)))
                         .convert)
              .expand<int>((Iterable<int> i) => i).toList()),
        .cmd => "",
    }).toList();
    
  static RegExp re
    = RegExp(r"(:([a-z][a-zA-Z0-9_-]+)?)|(&[a-z][a-zA-Z0-9_-]*)");
}