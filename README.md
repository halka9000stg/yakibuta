# yakibuta(叉焼/焼豚): char show

![Pub Version](https://img.shields.io/pub/v/yakibuta?style=plastic&link=https%3A%2F%2Fpub.dev%2Fpackages%2Fyakibuta)  
![Pub Points](https://img.shields.io/pub/points/yakibuta?style=plastic&link=https%3A%2F%2Fpub.dev%2Fpackages%2Fyakibuta)
![Pub Likes](https://img.shields.io/pub/likes/yakibuta?style=plastic)  
![Pub Publisher](https://img.shields.io/pub/publisher/yakibuta?style=plastic&cacheSeconds=60)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/yakibuta?style=plastic&cacheSeconds=86400&link=https%3A%2F%2Fpub.dev%2Fpackages%2Fyakibuta)


A CLI lightweight toolkit for checking chars through encodings.

Available `char` as command, and `cc28` as alias of it. Please run `dart pub global activate yakibuta` for to use.

The command receives byte array or native string of char. Each chars will be delimited with space.

## Basic Usage

`char ((:(<format><encoding>)?(<byte-array>|<native-string>)*)|(\*<command> <argument>*))*`

Each inputs or arguments are surrounded by Fences, `:` for normal input, and `*` for (Sub-)Commands.

`:` Fence can be followed by Format (`b`, `x` and `d` for each binary, hexadecimal and decimal integer, and `n` for native string) and Encoding (Special Abbreviation Names or IANA Registered Names). Default Input Encoding is US-ASCII, and it of Output is UTF-8 (or Terminal Default).

For example, 

`char :dascii 67 104 97 114 :` and `char : 43 68 61 72 :`  shows `Char`, `char :xu8 e5 8f 89 e7 84 bc :` shows `叉焼`.

`*` can be followed by (sub-)command instruction and few arguments. Available Sub-Commands are Bellow.

For example, 

`char *ob *oenc u8 :nu8  叉焼 :` shows `xh{e5 8f 89 e7 84 bc}`.

## Available Encodings

- UTF-8/16BE/36BE
- EUC-JP/KR
- Shit-JIS
- ISO-2022-JP
- Big5
- ISO-8859-1〜15 (Latin 1〜9, Cyrillic, Arabic, Greek, Hebrew, Thai)
- KOI8-U/R
- ASCII (US-ASCII)

Bellows are now planning to add:

and more...

## Sub-Commands
- `usage`
  - format: `usage`
  - desc: Shows the Usage of the Command
- `help` (not fully-implemented yet)
  - format: `help`
  - desc: Shows the Help of the Command
- `stdin` (unimplemented yet)
  - format: `stdin <encoding>`
  - desc: Reads Input from Stdin instead of Arguments
- `file`
  - format: `file <encoding> <file-path>`
  - desc: Reads Input from File instead of Arguments
- `ofile`
  - format: `ofile <file-path>`
  - desc: Writes Output to File instead of Stdout
- `oenc`
  - format: `oenc <encoding>`
  - desc: Changes Output Encoding instead of default of Terminal
- `ob` 
  - format: `ob`
  - desc: Changes Output Mode to Show Binary Arrays as Hex String
- `suspend`
  - format: `suspend`
  - desc: Suspends following Arguments (Current Implementation is Deletion)