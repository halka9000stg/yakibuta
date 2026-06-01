import "dart:convert";

import "package:yakibuta/parts/types.dart";
import "package:yakibuta/parts/enctab.dart";
import "package:yakibuta/parts/manager.dart";

abstract class YakibutaErr implements Exception {}

abstract class EncodingRecErr extends YakibutaErr {
  final String candidate;
  EncodingRecErr(this.candidate);
}

class NoSuchAsEncodingErr extends EncodingRecErr {
  List<EncodingTabRec> recs;
  
  NoSuchAsEncodingErr(super.candidate, this.recs);
  
  @override
  String toString() => "NoSuchAsEncodingErr: The Encoding key or name \"${this.candidate}\" is not exist in availables. \nAvailable keys are: " + this.recs.map<String>((EncodingTabRec r) => "\"${r.key}\"").join(", ") + "\nAvailable names are: " + this.recs.map<String>((EncodingTabRec r) => "\"${r.encoding.name}\"").join(", ") + ".";
}
class EncodingKeyUsedErr extends EncodingRecErr {
  final Encoding encoding;
  final EncodingTab tab;
  
  EncodingKeyUsedErr(super.candidate, this.encoding, this.tab);
  
  @override
  String toString() => "EncodingKeyUsedErr: \"${this.candidate}\" for \"${this.encoding.name}\", is used for \"${this.tab.search(this.candidate)}\" already.";
}

class NoSuchAsParseInstructionErr extends YakibutaErr {
  final String candidate;
  final List<String> insts;
  
  NoSuchAsParseInstructionErr(this.candidate, this.insts); 
  NoSuchAsParseInstructionErr.of(this.candidate):
    this.insts = ParseInstruction.values.map<String>((ParseInstruction i) => i.code).toList(); 
  
  @override
  String toString() => "NoSuchAsParseInstructionErr: The parse instruction \"${this.candidate}\" is not exist in availables. \nAvailable instructions are: " + this.insts.map<String>((String s) => "\"$s\"").join(", ") + ".";
}