import "dart:io";
import "dart:convert";

import "package:yakibuta/parts/core/conv.dart";

abstract class IOChan<IxD, OxD> {
  IxD read();
  void write(OxD src);
  void process(Converter<IxD, OxD> cvr)
      => this.write(cvr.convert(this.read()));
}

class StdIOChanS2B extends IOChan<String, List<int>> {
  final Encoding encoding;
  
  StdIOChanS2B([this.encoding = systemEncoding]);
  
  @override
  String read() => stdin.readAllAsString();
  @override
  void write(List<int> src) => stdout.add(src);
}

// if in is file, out is file too.
abstract class FSIOChanS2B<FS extends FileSystemEntity> extends IOChan<String, List<int>> {
  FS get inFile;
  FS get outFile;
  Encoding get encoding;
  
  static FSIOChanS2B investigate({
      required FileSystemEntity inFile,
      FileSystemEntity? outFile,
      Encoding encoding = systemEncoding}){
    throw 0;
  }
  static FSIOChanS2B investigateFrom({
      required String iPath, String? oPath,
      Encoding encoding = systemEncoding}){
        FileSystemEntityType ty = FileSystemEntity.typeSync(iPath);
        return switch(ty){
          .file => FileIOChanS2B.from(iPath: iPath, oPath: oPath, encoding: encoding),
          .directory => DirIOChanS2B.from(iPath: iPath, oPath: oPath, encoding: encoding),
          _ => throw 0,
        };
  }
}

class FileIOChanS2B extends FSIOChanS2B<File>{
  @override
  final File inFile;
  @override
  final File outFile;
  @override
  final Encoding encoding;
  
  FileIOChanS2B({
        required File inFile, File? outFile,
        this.encoding = systemEncoding}):
    this.inFile = inFile,
    this.outFile
      = outFile
          ?? File(FileIOChanS2B.in2out(inFile.path)) {
    if(!this.inFile.existsSync()) throw 0;
    if(!this.outFile.existsSync()){
      this.outFile.createSync(recursive: true);
    }
  }
  FileIOChanS2B.from({
        required String iPath, String? oPath,
        this.encoding = systemEncoding}):
    this.inFile = File(iPath),
    this.outFile
      = File(oPath ?? FileIOChanS2B.in2out(iPath)) {
    if(!this.inFile.existsSync()) throw 0;
    if(!this.outFile.existsSync()){
      this.outFile.createSync(recursive: true);
    }
  }
    
  @override
  String read()  => this.inFile
      .readAsStringSync(encoding: this.encoding);
  @override
  void write(List<int> src) => this.outFile
      .writeAsBytes(src);

  static String in2out(String iPath, [String app = "out"]) {
    if(!iPath.contains(".")) throw 0;
    Iterable<String> t = iPath.split(".");
    return t.take(t.length - 1)
      .followedBy(<String>[app, t.last]).join(".");
  }
}

class DirIOChanS2B extends FSIOChanS2B<Directory>{
  @override
  final Directory inFile;
  @override
  final Directory outFile;
  @override
  final Encoding encoding;
  late List<File> _iFiles;
  int _curr = -1;
  
  DirIOChanS2B({
        required Directory inFile, Directory? outFile,
        this.encoding = systemEncoding}):
    this.inFile = inFile,
    this.outFile
      = outFile
          ?? Directory(FileIOChanS2B.in2out(inFile.path)) {
        if(!this.inFile.existsSync()) throw 0;
        if(!this.outFile.existsSync()){
          this.outFile.createSync(recursive: true);
        }
      this.init();
   }
  DirIOChanS2B.from({
        required String iPath, String? oPath,
        this.encoding = systemEncoding}):
    this.inFile = Directory(iPath),
    this.outFile
      = Directory(oPath ?? FileIOChanS2B.in2out(iPath)) {
        if(!this.inFile.existsSync()) throw 0;
        if(!this.outFile.existsSync()){
          this.outFile.createSync(recursive: true);
        }
      this.init();
  }
  
  bool get done => this._curr + 1 == this._iFiles.length;
  int get curr => this._curr;
  FileIOChanS2B get currChan => FileIOChanS2B(
      inFile: this._iFiles[this._curr],
      outFile: File("${this.outFile.path}/${this._iFiles[this._curr].uri.pathSegments.last}"),
      encoding: this.encoding);

  void init(){
    this._iFiles = this.inFile
        .listSync().whereType<File>().toList();
    this._curr = 0;
  }

  void next(){
    if(this.done){
      this._curr = -1;
    }else{
      this._curr += 1;
    }
  }
    
  @override
  String read()  => this.currChan.read();
  @override
  void write(List<int> src) => this.currChan.write(src);
  @override
  void process(Converter<String, List<int>> cvr){
    while(!this.done){
      this.currChan.process(cvr);
      this.next();
    }
  }

  static String in2out(String iPath, [String app = "out"])
      => "${iPath}_$app";
}