import "dart:convert";
import "dart:io";

import "package:yakibuta/types.dart";

class IntParser extends Converter<String, int> {
  final int radix;
  
  const IntParser(this.radix);
  
  int convert(String src)
    => int.parse(src, radix: this.radix);
}
class AsListConv<E> extends Converter<E, List<E>>{
  List<E> convert(E el) => <E>[el];
}
extension AsListConvFuse<R, S> on Converter<R, S> {
  Converter<R, List<S>> asListFuse()
    => this.fuse(AsListConv<S>());
}
class ErrorHandleConv<S, T, E> extends Converter<S, T> {
  final Converter<S, T> underlying;
  final OnError<E, T> onError;
  
  ErrorHandleConv(this.underlying, this.onError);
  
  T convert(S src) {
    try{
      return this.underlying.convert(src);
    } on E catch(e){
      return this.onError(e);
    }
  }
}

class CmdExec extends Converter<Fence, Fence> {
  Fence convert(Fence src) => switch(src.type) {
    InstructionType.core => src,
    InstructionType.cmd => switch(src.inst) {
      "file" => (type: InstructionType.core, inst: "d" + src.values[0], values: File(src.values[1]).readAsBytesSync().map<String>((int byte) => byte.toString()).toList()),
      "stdin" => src,
      "suspend" => (type: src.type, inst: "%SUSPENDED%", values: <String>[]),
      _ => src,
    }
  };
}

iso-8859-1

dst/conv.dart



