extension type PackId._(String str){
  PackId(String src): this._(PackId.validate(src));
  static String validate(String target)
    => target;
}

abstract class PDirective {
  final String inst;
  final PackId? id;
  
  PDirective(this.inst, this.id);
  PDirective.only(this.inst): this.id = null;
}
abstract class PAnonDirective extends PDirective {
  @override
  final Null id = null;
  
  PAnonDirective(String inst): super.only(inst);
}
abstract class PNamedDirective extends PDirective {
  @override
  final PackId id;
  
  PNamedDirective({required String inst, required this.id}): super.only(inst);
}

class Package {}

class Packer {}