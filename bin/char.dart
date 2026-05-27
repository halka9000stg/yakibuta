import "package:yakibuta/yakibuta.dart";

void main(List<String> args){
  final t = EncodingTab.dflt;
  final m = Manager(t);

  if(args.isEmpty){
    print(t.showList(true));
    return;
  }
  
	//:(n|d|b|x)(u8|u16|jis)
 if(!Manager.re.hasMatch(args.first)) {
    main(<String>[":xascii"].followedBy(args).toList());
    return;
}
  print(args);
  
  String res = m.process(args).join("");
  
  print(res);
}