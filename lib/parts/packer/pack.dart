import "package:yakibuta/parts/packer/directive.dart";

typedef PDveResult<D extends PDirective>
    = ({D pDve, int consumedLines, bool done});
typedef PDveEntry<D extends PDirective>
    = ({D pDve, int offset});

class Package {
  final List<PDveEntry> _pDves = <PDveEntry>[];
  
  Package();
  
  List<PDveEntry> get pDves
    => <PDveEntry>[...(this._pDves)];
  
  void parse(String src){
    this._pDves.clear();
  }
  void typeCheck(){}
  List<int> exec(List<int> input){
    return input;
  }
  
}

class Packer {}