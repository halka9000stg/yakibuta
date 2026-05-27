import "dart:convert";

typedef EncodingTabRec = ({
    String key,
    Encoding encoding});
typedef Str2IntParser = Converter<String, int>;
typedef IterableSelector<T> = T Function(List<T>);
typedef Fence = ({
    InstructionType type,
    String inst,
    List<String> values});

extension ComparableSppl on EncodingTabRec {
  int compareTo(EncodingTabRec other)
    => this.key.compareTo(other.key);
}

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
  List<String> get list
    => this._recs
      .map<String>((EncodingTabRec r)
        => "- ${r.key}: ${r.encoding.name}")
      .toList();
  String get showList => "\a\n" + this.list.join("\n") + "\v\r\0";
  
  static EncodingTab get dflt {
    final t = EncodingTab();
    t.add("ascii", ascii);
    t.add("u8", utf8);
    t.add("lat1", latin1);
    return t;
  }
}

class IntParser extends Str2IntParser {
  final int radix;
  
  const IntParser(this.radix);
  
  int convert(String src)
    => int.parse(src, radix: this.radix);
}

IterableSelector<T> _iea<T>(int offset)
  => (List<T> from) => from.elementAt(offset);

class SingleSelector<T> extends Converter<List<T>, T> {
  final IterableSelector<T> selector;
 
  SingleSelector(this.selector);
  SingleSelector.partOf(int offset):
    this.selector = _iea<T>(offset);

  T convert(List<T> from)
    => this.selector(from);
}

enum ParseInstruction {
  hexInt("x"), binInt("b"), decInt("d"),
  nativeStr("n");

  const ParseInstruction(this.code);

  final String code;
  
  Str2IntParser parserOf(Encoding encoding)
    => switch(this) {
      .nativeStr => encoding.encoder.fuse<int>(SingleSelector<int>.partOf(0)),
      .hexInt => IntParser(8),
      .binInt => IntParser(2),
      .decInt=> IntParser(10),
  };
  
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

enum InstructionType {
  core, cmd;
  
  factory InstructionType.investigate(String from) => switch(from.substring(0, 1)){
      ":" => InstructionType.core,
      "&" => InstructionType.cmd,
      _ => throw 0,
  };
}

class Manager {
  final EncodingTab _tab;

  Manager(EncodingTab tab):
    this._tab = tab;

  List<int> fenceIndexes(List<String> argsOf) {
    List<int> ret = <int>[];
    late int tmp;
    
    do {
      tmp = argsOf.indexWhere((String a) => Manager.re.hasMatch(a), ret.lastOrNull ?? 0);
      if(tmp == -1 || tmp + 1 >= argsOf.length){
        break;
      }
      ret.add(tmp);
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
              i + 1 >= ixs.length ? argsOf.length : ixs[i + 1])
            .map<String>((String s)
              => (s.startsWith("?:") || s.startsWith("?&"))
                ? s.substring(1) : s)
            .toList()
          ));
    }
    return fcs;
  }
  static RegExp re
    = RegExp(r"(:([a-z][a-zA-Z0-9_-]+)?)|(&[a-z][a-zA-Z0-9_-]*)");
}

void main(List<String> args){
  final t = EncodingTab.dflt;
  final m = Manager(t);
  if(args.isEmpty){
    print(t.showList);
    return;
  }

	//:(n|d|b|o)(u8|u16|jis)
  //if(args.fi) return 0;
  print(
    ascii.decode(
      args.map<int>((String a)
        => int.parse(a, radix: 16)).toList()));
}