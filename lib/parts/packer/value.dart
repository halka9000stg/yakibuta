import "dart:convert";

import "package:yakibuta/parts/core/enctab.dart";
import "package:yakibuta/parts/core/manager.dart" show ParseInstruction;


extension type PackId._(String str){
  PackId(String src): this._(PackId.validate(src));
  static String validate(String target)
    => target;
}

extension type EncInst._(String str){
  EncInst(String src): this._(EncInst.validate(src));
  
  ParseInstruction get pInst
    => ParseInstruction.from(this.str.substring(0, 1));
  String get encName => this.str.substring(1);
  Encoding encoding(EncodingTab tab)
    => tab.search(this.encName);
  static String validate(String target)
    => target;
}

typedef EncodedString
  = ({EncInst enc, List<int> string});