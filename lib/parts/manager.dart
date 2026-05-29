import "dart:convert";
import "dart:io";

import "package:yakibuta/parts/types.dart";
import "package:yakibuta/parts/enctab.dart";
import "package:yakibuta/parts/conv.dart";
import "package:yakibuta/parts/help.dart";

enum ParseInstruction {
  hexInt("x"), binInt("b"), decInt("d"),
  nativeStr("n");

  const ParseInstruction(this.code);

  final String code;
  
  ErrorHandleConv<String, List<int>, ArgumentError> parserOf(Encoding encoding)
    => ErrorHandleConv<String, List<int>, ArgumentError>(switch(this) {
      .nativeStr => encoding.encoder,
      .hexInt => IntParser(16).asListFuse(),
      .binInt => IntParser(2).asListFuse(),
      .decInt=> IntParser(10).asListFuse(),
  }, (ArgumentError e){
    print(e.runtimeType);
    print(e);
    return <int>[];
});
  
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

class Manager {
  final EncodingTab _tab;
  Encoding _enc = utf8;
  bool _obyteMode = false;
  bool _ofileMode = false;
  late File _f;

  Manager(EncodingTab tab):
    this._tab = tab;
  
  
  String _oencSet(String enc){
    this._enc = this._tab.search(enc);
    return this._enc.name;
  }
  String _ofileModeSet(String path){
    this._ofileMode = true;
    this._f = File(path);
    return path;
  }
  String _obyteModeSet(){
    this._obyteMode = true;
    return "Binary output mode";
  }
  
  List<int> fenceIndexes(List<String> argsOf) {
    List<int> ret = <int>[];
    late int tmp;
    int cout = 0;
    
    do {
      tmp = argsOf.indexWhere((String a) => Manager.re.hasMatch(a), (ret.lastOrNull ?? -1) + 1);
      
      //print("[${++cout}] tmp: ${tmp}");
      if(tmp == -1){
        break;
      }
      ret.add(tmp);
      if(ret.last + 1 >= argsOf.length){
        break;
      }
    } while(true);
    return ret;
  }
  List<Fence> getFences(List<String> argsOf) {
    List<int> ixs = this.fenceIndexes(argsOf);
    List<Fence> fcs = <Fence>[];
    for(int i = 0; i < ixs.length; i++) {
      fcs.add((
        at: i,
        type: InstructionType.investigate(argsOf[ixs[i]]),
        inst: argsOf[ixs[i]].substring(1),
        values: argsOf.sublist(
              ixs[i] + 1,
              i + 1 >= ixs.length ? null : ixs[i + 1])
            .map<String>((String s)
              => (s.startsWith("?:") || s.startsWith("?*"))
                ? s.substring(1) : s)
            .toList()
          ));
    }
    return fcs.map<Fence>((Fence f) => (f.inst == "" && f.type == InstructionType.core) ? (inst: "xascii", type: f.type, values: f.values, at: f.at) : f).toList();
  }
  List<MassageLine> process(List<String> argsOf)
    => this.getFences(argsOf)
      .asIterable()
      .transform<Iterable<Fence>>(FenceTypeSorter())
      .map<Fence>(CmdExec(this).convert)
      .transform<Iterable<Fence>>(FenceArranger())
      .map<MassageLine>((Fence f) => switch(f.type){
        .core => (nr: f.at, msg: this._tab
          .search(f.inst.substring(1)).decode(
            f.values.map<List<int>>(
               ParseInstruction.from(
                      f.inst.substring(0, 1))
                   .parserOf(
                       this._tab.search(f.inst.substring(1)))
                         .convert)
              .expand<int>((Iterable<int> i) => i).toList()), isSystem: false, enc: this._tab.search(f.inst.substring(1))),
        .cmd => (nr: f.at, msg: switch(f.inst){
            "list" => this._tab.showList(true),
            "usage" => CharHelp.usage,
            "help" => CharHelp.help,
            "oenc" => this._oencSet(f.values[0]),
            "ofile" => this._ofileModeSet(f.values[0]),
            "ob" => this._obyteModeSet(),
            "suspend" => "%SUSPENDED%",
            _ => "",
          }, isSystem: true, enc: this._enc),
    }).toList();
    
  void printAs(List<MassageLine> res, {bool debug = false}){
    List<int> buf = <int>[];
    List<int> bufL = <int>[];

    if(debug){
      print(".len: ${res.length}.smes: ${res.where(( MassageLine ml) => ml.isSystem).toList()} .aml: ${this}");
    }
    
    for(int i = 0; i < res.length; i++){
      if(res[i].isSystem && debug){
        print("");
        print("------- Begin System Massage ------");
        print(res[i].msg);
        print("------- End System Massage --------");
        continue;
      }
      if(this._obyteMode){
        bufL = this._enc.encode("xh{" + res[i].enc.encode(res[i].msg).map<String>((int b) => b.toRadixString(16)).join(" ") + "}");
      }else {
        bufL = this._enc.encode(res[i].msg);
      }
      buf.addAll(bufL);
      //buf.addAll(this._enc.encode("\n"));
    }
    if(this._ofileMode){
      this._f.writeAsBytes(buf);
    }else{
      stdout.add(buf);
      stdout.write("\n");
    }
  }
    
  static RegExp re
    = RegExp(r"(:([a-z][a-zA-Z0-9_-]+)?)|(\*[a-z][a-zA-Z0-9_-]*)");
}