extension NewLine on String {
  String nl([int count = 1]) => this + "\n" * count;
}

int simpleCounter(int index) => index + 1;

String cmdArgsJoin(String cmd, List<String> args, {
    String delim = "", String argPre = "", String argPost = ""})
  => cmd + (args.isNotEmpty ? delim + argPre : "") + args.join(delim) + (args.isNotEmpty ? argPost : "");