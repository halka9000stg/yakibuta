import "dart:convert";
import "dart:io";

import "package:yakibuta/types.dart";
import "package:yakibuta/yakibuta.dart" show Manager;

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
class ErrorHandleConv<S, T, E extends Object> extends Converter<S, T> {
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
  Manager _m;
  CmdExec(Manager manager):
    this._m = manager;
  Fence convert(Fence src) => switch(src.type) {
    InstructionType.core => src,
    InstructionType.cmd => switch(src.inst) {
      "file" => (type: InstructionType.core, inst: "d" + src.values[0], values: File(src.values[1]).readAsBytesSync().map<String>((int byte) => byte.toString()).toList(), at: src.at),
      "stdin" => src,
      _ => src,
    }
  };
}

class FenceTypeSorter extends Converter<Iterable<Fence>, Iterable<Fence>> {
  Iterable<Fence> convert(Iterable<Fence> fences)
    => fences
      .where((Fence f)
          => f.type == InstructionType.cmd)
      .followedBy(
         fences.where((Fence f)
             => f.type == InstructionType.core))
      .transform<Iterable<Fence>>(
         FenceLineRecounter.recounter);
}

class FenceArranger extends Converter<Iterable<Fence>, Iterable<Fence>> {
  Iterable<Fence> convert(Iterable<Fence> fence)
    => fence.any((Fence f)
        => f.type == InstructionType.cmd
              && f.inst == "suspend")
      ? fence.take(
         fence.toList().indexWhere((Fence f)
           => f.type == InstructionType.cmd
              && f.inst == "suspend") + 1)
        .transform<Iterable<Fence>>(
           FenceLineRecounter.recounter)
      : fence;
}

class FenceLineRecounter extends Converter<Iterable<Fence>, Iterable<Fence>> {
  Iterable<Fence> convert(Iterable<Fence> fence)
    => fence.indexed
      .map<Fence>(((int, Fence) fe) => (
          at: fe.$1, type: fe.$2.type,
          inst: fe.$2.inst, values: fe.$2.values));
  static FenceLineRecounter recounter
    = FenceLineRecounter();
}

extension ConverterApplier<S> on S {
  T transform<T>(Converter<S, T> converter)
      => converter.convert(this);
}

extension AsIterable<E> on Iterable<E> {
  Iterable<E> asIterable() => this;
}