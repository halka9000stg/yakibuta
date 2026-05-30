import "dart:convert";

class EncodingTabRec implements Comparable<EncodingTabRec> {
  final String key;
  final Encoding encoding;
  final String? group;
  final String? series;
  final int? nr;
  final String? variant;
  final bool showable;
  
  EncodingTabRec({
      required this.key,
      required this.encoding,
      this.group, this.series, this.nr, this.variant,
      this.showable = true});
  
  
  String get shows {
    if(!this.showable) return "";
    if(this.series == null || (this.nr == null && this.variant == null)) return "";
    
    String series_ = this.series!.replaceAll(" ", "-");
    String nr = this.nr == null ? "" : "-${this.nr}";
    String variant = this.variant == null ? "" : "-${this.variant}";
    
    return "$series_$nr$variant";
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
    
    return this.encoding.name.compareTo(other.encoding.name);
  }
}

EncodingTabRec etr(String key, Encoding encoding, 
    {String? group, String? series, int? nr, String? variant, bool showable = true})
  => EncodingTabRec(
    key: key, encoding: encoding,
    group: group, series: series, nr: nr, variant: variant, showable: showable);

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
  List<int> asBytes([Encoding? encoding_override])
    => (encoding_override ?? this.enc).encode(this.msg);
}