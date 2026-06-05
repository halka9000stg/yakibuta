import "package:yakibuta/common/libmisc.dart";
import "package:yakibuta/parts/packer/value.dart";

abstract class PDirective {
  final String sym = "@";
  String get inst;
  PackId? get id;
}

abstract class PAnonDirective extends PDirective {
  @override
  final Null id = null;
}

abstract class PNamedDirective extends PDirective {
  @override
  PackId get id;
}

class ShbangPDve extends PAnonDirective {
  @override
  final String sym = "#!";
  final String cmd;
  final List<String> cmdArgs;
  
  ShbangPDve(this.cmd, this.cmdArgs);
  
  @override
  String get inst => cmdArgsJoin(this.cmd, this.cmdArgs);
}

class RunPDve extends PAnonDirective {
  @override
  final String inst = "run";
}

class RulePDve extends PNamedDirective {
  @override
  final String inst = "rule";
  @override
  final PackId id;
  
  RulePDve({required this.id});
}

class FusePDve extends PNamedDirective {
  @override
  final String inst = "fuse";
  @override
  final PackId id;
  
  FusePDve({required this.id});
}

class ConvPDve extends PNamedDirective {
  @override
  final String inst = "conv";
  @override
  final PackId id;
  
  ConvPDve({required this.id});
}