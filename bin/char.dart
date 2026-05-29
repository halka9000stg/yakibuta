import "package:yakibuta/yakibuta.dart";

void main(List<String> args){
  final t = EncodingTab.dflt;
  final m = Manager(t);

  if(args.isEmpty){
    print(CharHelp.usage.nl(2));
    print("【Available Encodings】");
    print(t.showList(true));
    return;
  }
  
  bool debug = args.first == "-";
  
	//:(n|d|b|x)(u8|u16|jis)
 if(!Manager.re.hasMatch(args[debug ? 1 : 0])) {
    main(debug ? <String>["-", ":xascii"].followedBy(args.skip(1)).toList() : <String>[":xascii"].followedBy(args).toList());
    return;
  }
  if(args.last != ":"){
    main(args.followedBy(<String>[":"]).toList());
    return;
  }
  
  if(debug){
    print(args);
  }
  
  m.printAs(
    m.process(debug ? args.skip(1).toList(): args),
      debug: debug);
}