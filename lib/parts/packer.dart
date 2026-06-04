extension type PackId._(String str){
  PackId(String src): this._(PackId.validate(src));
  static String validate(String target)
    => target;
}

abstract class PDirective {
  final String inst;
  final PackId? id;
  
  PDirective(this.inst, this.id);
}
abstract class PAnonDirective extends PDirective {
  @override
  final Null id = null;
  
  PAnonDirective(super.inst);
}
abstract class PNamedDirective {
  @override
  final PackId id;
  
  PAnonDirective({required super.inst, required this.id});
}

class Package {}

class Packer {}