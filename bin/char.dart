import "package:yakibuta/yakibuta.dart";
import "package:yakibuta/help.dart";
import "package:yakibuta/types.dart" show NewLine;

void main(List<String> args){
  final t = EncodingTab.dflt;
  final m = Manager(t);

  if(args.isEmpty){
    print(CharHelp.usage.nl(2));
    print("【Available Encodings】");
    print(t.showList(true));
    return;
  }
  
	//:(n|d|b|x)(u8|u16|jis)
 if(!Manager.re.hasMatch(args.first)) {
    main(<String>[":xascii"].followedBy(args).toList());
    return;
  }
  if(args.last != ":"){
    main(args.followedBy(<String>[":"]).toList());
    return;
  }
  
  print(args);
  
  m.printAs(m.process(args));
}