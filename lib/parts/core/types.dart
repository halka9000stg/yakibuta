import "dart:convert";

class EncodingTabRec implements Comparable<EncodingTabRec> {
  final String key;
  final Encoding encoding;
  /// Alternative Names for the Encoding
  final List<String> alt;
  final String? group;
  final String? series;
  final int? nr;
  final String? variant;
  
  EncodingTabRec({
      required this.key,
      required this.encoding,
      this.alt = const <String>[],
      this.group, this.series, this.nr, this.variant});
  
  
  String asListView({
      int Function()? counter, int? allCount,
      required int Function(String key) tabCount}){
    int? count = counter == null ? null : counter();
    String mark = count == null ? "-" : "$count.";
    String pad  = " " * (count != null && allCount != null ? (allCount - 1).toString().length - count.toString().length : 0);
    String topBase = "$pad$mark ";
    String tabs = "\t" * tabCount(this.key);
    String altElms = this.alt.join(", ");
    String alts = altElms == "" ? "" : "\n\t\t($altElms)";
    return "$topBase${this.key}:$tabs${this.iana}$alts";
  }
  String get iana => this.encoding.name;
  String get shows {
    if(this.series == null || (this.nr == null && this.variant == null)) return "";
    
    String series_i = this.series!.replaceAll(" ", "-");
    String nr = this.nr == null ? "" : "-${this.nr}";
    String variant = this.variant == null ? "" : "-${this.variant}";
    
    return "$series_i$nr$variant";
  }
  String info() {
    List<String> lines = <String>[];
    lines.add("Key: ${this.key}");
    lines.add("IANA Registered Name: ${this.iana}");
    if(this.alt.isNotEmpty) lines.add("Alternative Names: " + this.alt.join(", "));
    String? series_i = this.series?.replaceAll(" ", "-");
    if(series_i != null) lines.add("Encoding Series: $series_i");
    return lines.join("\n") + "\n";
  }
  @override
  int compareTo(EncodingTabRec other){
    late int cnt;
    // group > series > (nr | variant) > key > encoding.name
    // non- null > null
    cnt = this.group.compareTo(other.group);
    if(cnt != 0) return cnt;
    
    cnt = this.series.compareTo(other.series);
    if(cnt != 0) return cnt;
    
    cnt = this.group.compareTo(other.group);
    if(cnt != 0) return cnt;
    
    cnt = this.nr.compareTo(other.nr);
    if(cnt != 0) return cnt;
    
    cnt = this.variant.compareTo(other.variant);
    if(cnt != 0) return cnt;
    
    return this.iana.compareTo(other.iana);
  }
}

EncodingTabRec etr(String key, Encoding encoding, 
    {List<String> alt = const <String>[],
     String? group, String? series, int? nr, String? variant})
  => EncodingTabRec(
    key: key, encoding: encoding, alt: alt,
    group: group, series: series, nr: nr, variant: variant);

extension EncodingTabRecEx  on Iterable<EncodingTabRec> {
  Iterable<String> listView({
      int Function(int index)? counter,
      required int Function(String key) tabCount})
    => this.indexed
      .map<String>(((int, EncodingTabRec) r)
        => r.$2.asListView(
          counter: counter != null ? () => counter(r.$1) : null,
          allCount: this.length, tabCount: tabCount));
}

int simpleCounter(int index) => index + 1;

extension ComparableExt<T extends Comparable<T>> on T? {
  int compareTo(T? other){
    T? self = this;
    if(self == null && other == null) {
      return 0;
    } else if (self != null && other != null) {
      return self.compareTo(other);
    } else if (self == null) {
      return 1;
    } else {
      return -1;
    }
  }
}

typedef Str2IntParser = Converter<String, List<int>>;
typedef OnError<E, R> = R Function(E);

typedef Fence = ({
    int at,
    InstructionType type,
    String inst,
    List<String> values});

extension ComparableSppl on EncodingTabRec {
  int compareTo(EncodingTabRec other)
    => this.key.compareTo(other.key);
}

enum InstructionType {
  core, cmd;
  
  factory InstructionType.investigate(String from) => switch(from.substring(0, 1)){
      ":" => InstructionType.core,
      "*" => InstructionType.cmd,
      _ => throw 0,
  };
}

extension NewLine on String {
  String nl([int count = 1]) => this + "\n" * count;
}

typedef MassageLine = ({int nr, String msg, Encoding enc, bool isSystem});

extension MassageExt on MassageLine {
  List<int> asBytes([Encoding? encodingOverride])
    => (encodingOverride ?? this.enc).encode(this.msg);
}