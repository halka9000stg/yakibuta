import "dart:convert";

import "package:yakibuta/yakibuta.dart";

void main(List<String> args) {
  // (<in> (<out>)?)? :<inst> <oenc>
  // 
  final t = EncodingTab.dflt;
  final m = Manager(t);

  if(args.isEmpty){
    print(CharHelp.usage.nl(2));
    print("【Available Encodings】");
    print(t.showList(true));
    return;
  }
  
  int? instIndex = args.indexed
      .where(((int, String) e)
          => Manager.re.hasMatch(e.$2))
      .where(((int, String) e) => e.$2.substring(0, 1) == ":")
      .map<int>(((int, String) e) => e.$1).firstOrNull;

  if(instIndex == null){
    print(CharHelp.usage.nl(2));
    print("【Available Encodings】");
    print(t.showList(true));
    return;
  }
  
  String inst = args[instIndex].substring(1);
  String ienc = inst.substring(1);
  String oenc = args.length == instIndex + 1
      ? ienc : args[instIndex + 1];
  Encoding rEnc = t.search(ienc);
  
  // if 0, stdin to stdout
  // if 1, fs to fs, and 0 is both in and out
  // if 2 or later, fs to fs, 0 is in, 1 is out
  IOChan<String, List<int>> ch = switch(instIndex){
    0 => StdIOChanS2B(rEnc),
    1 => FSIOChanS2B.investigateFrom(
        iPath: args[0], encoding: rEnc),
     _ => FSIOChanS2B.investigateFrom(
        iPath: args[0], oPath: args[1], encoding: rEnc),
  };
  
  Str2IntParser conv = ParseInstruction
    .from(inst.substring(0, 1))
    .parserOf(rEnc).fuse(
        TransConverter(rEnc, t.search(oenc)));
  
  ch.process(conv);
}