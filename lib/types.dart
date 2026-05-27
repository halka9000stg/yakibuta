import "dart:convert";

typedef EncodingTabRec = ({
    String key,
    Encoding encoding});
typedef Str2IntParser = Converter<String, List<int>>;
typedef OnError<E, R> = R Function(E);

typedef Fence = ({
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
      "&" => InstructionType.cmd,
      _ => throw 0,
  };
}
