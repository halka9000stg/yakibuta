import "dart:convert";

import "package:charset/charset.dart";

class ByteOrderConv extends Converter<List<int>, List<int>>{
  final Encoding underlying;
  final ByteOrder order;
  final bool addBom;
  final bool reverse;//true => decode, false => encode
  
  ByteOrderConv(this.underlying, {
      this.order = ByteOrder.be,
      this.addBom = false,
      this.reverse = false});
 
  List<int> convert(List<int> src){
    if(!ByteOrderCodec.target.any((Encoding te) => this.underlying == te)){
      return src;
    }
    print("utf (${this.underlying.name})\n");
    //if reverse
    //  true: in is auto-detec., out is be with bom
    //  false: in is be with bom, out is order
    
    ByteOrder outBom = this.reverse ? ByteOrder.be : this.order;
    
    bool hasBeBom = ByteOrderCodec.hasBomOf(src, this.underlying, ByteOrder.be);
    bool hasLeBom = ByteOrderCodec.hasBomOf(src, this.underlying, ByteOrder.le);
    print("BE BOM: $hasBeBom\nLE BOM: $hasLeBom");
    //false-false...be, true-false..be,
    //false-true...le, true-false..non,
    ByteOrder curBom = hasLeBom ? ByteOrder.le : ByteOrder.be;
    print("Cur BO: $curBom");
    print("Out BO: $outBom");
    print("Is Needed to Switch: ${curBom != outBom}");
    List<int> nuked = (hasBeBom || hasLeBom) ? src.skip(ByteOrderCodec.bomLen(this.underlying, curBom)).toList() : src;
    List<int> arranged = (curBom == outBom) ? nuked : ByteOrderCodec.switchOrder(nuked, this.underlying);
    return this.addBom ? ByteOrderCodec.bom(this.underlying, outBom).followedBy(arranged).toList() : arranged;
  }
}
class ByteOrderCodec extends Encoding {
  static List<Encoding> target = <Encoding>[
      utf8, utf16, utf32];
  
  final Encoding underlying;
  final ByteOrder order;
  final bool addBom;
      
  String get name {
    if(!ByteOrderCodec.target.any((Encoding te) => this.underlying == te)){
      return this.underlying.name;
    }
    return this.underlying.name + this.order.name
        + (this.addBom ? " with BOM" : "");
  }
  
  ByteOrderCodec(this.underlying, {
      this.order = ByteOrder.be,
      this.addBom = false});

  Converter<List<int>, String> get decoder
    => ByteOrderConv(this.underlying,
          order: order, addBom: addBom, reverse: true)
      .fuse(this.underlying.decoder);
  Converter<String, List<int>> get encoder
    => this.underlying.encoder
      .fuse(ByteOrderConv(this.underlying,
          order: order, addBom: addBom));

  static List<int> bom(Encoding e, ByteOrder o) => switch(e){
    utf8 => <int>[0xef, 0xbb, 0xbf],
    utf16 => switch(o) {
        .be => <int>[0xfe, 0xff],
        .le => <int>[0xff, 0xfe],
      },
    utf32 => switch(o) {
        .be => <int>[0x0, 0x0, 0xfe, 0xff],
        .le => <int>[0xff, 0xfe, 0x0, 0x0],
      },
    _ => <int>[],
  };
  static int bomLen(Encoding e, [ByteOrder? o])
      => o != null
        ? ByteOrderCodec.bom(e, o).length
        : ByteOrder.values
           .map<int>((ByteOrder oel)
              => ByteOrderCodec.bom(e, oel).length)
           .reduce((int prev, int curr)
              => prev > curr ? prev : curr);
  static bool hasBomOf(
      List<int> target, Encoding e, [ByteOrder? o])
    => o == null 
      ? ByteOrder.values
          .map<bool>((ByteOrder oel)
              => ByteOrderCodec.hasBomOf(target, e, oel))
          .reduce((bool prev, bool curr) => prev || curr)
      : target.take(ByteOrderCodec.bomLen(e, o))
          .indexed.map<bool>(((int, int) elm) 
              => ByteOrderCodec.bom(e, o)[elm.$1] == elm.$2)
          .reduce((bool prev, bool curr) => prev && curr);
  static int? unitSize(Encoding e) => switch(e) {
    utf8 => null,
    utf16 => 1,
    utf32 => 2,
    _ => null,
  };
  static List<int> switchOrder(List<int> target, Encoding enc){
    int? us = ByteOrderCodec.unitSize(enc);
    if(us == null){
      return target;
    }
    
    List<int> temp = <int>[...target];
    int pus = us * 2;
    int lenm = target.length % pus;
    int lenc = target.length ~/ pus;
    
    if(lenm != 0){
      temp.addAll(
          List<int>.generate(pus - lenm, (int _) => 0));
    }
    
    List<int> ret = <int>[];
    
    for(int i = 0; i < lenc; i++){
      ret.addAll(temp.sublist(pus * i + us, pus * (i + 1)));
      ret.addAll(temp.sublist(pus * i, pus * i + us));
    }
    
    return ret;
  }
}

enum ByteOrder {
  be("BE"), le("LE");
  
  const ByteOrder(this.name);
  
  final String name;
  ByteOrder get reversed => switch(this){
    .be => .le,
    .le => .be,
  };
}

extension WithByteOrder on Encoding {
  Encoding withByteOrder({
      ByteOrder order = ByteOrder.be,
      bool addBom = false})
    => ByteOrderCodec(this,
      order: order, addBom: addBom);
}