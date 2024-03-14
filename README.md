# **bmpf_py** A bopomofo and pinyin library

## Features

- It handles parsing of Bopomofo (注音符號) and Hanyu Pinyin (漢語拼音), two of the most popular phonetic notations of modern standard Mandarin;
- It supports parsing of Pinyin written with tone mark diacritics.
- It recognizes _ascii pinyin_ in which tones are represented with trailing numbers and the letter 'v' is used as the replacement of the less accessible 'ü';
- It supports mutual conversion between Bopomofo and Pinyin;
- It supports mutual conversion between the ascii pinyin and the standard form, which is toned with marks;
- It's lightweight and efficient both cpu- and memory-wise'
- It stands alone having no dependency;
- It's thoroughly tested;
- It's easy to use. It consists of only a single class, provided with simple and intuitive properties and methods.
- It only handles pinyin in lower case;

# **bmpf_py** 專注注音拼音處理

## 特點

- 對「注音符號」和「漢語拼音」進行綴字分析，識別音節（含聲調），生成音節對象（BpSyllable）
- 支持非標準 ASCII 拼音（以 v 代 ü，以數字標調）
- 實現注音、拼音、ASCII 拼音兩兩相互轉換
- 輕量、高效
- 無外部依賴
- 充分測試
- 簡潔易用。只包括一個class，並配備直觀應手的 props 和 methods
- 只支持小寫拼音

# Usage · 用法

```dart
import 'package:bpmf_py/bpmf_py.dart';
import 'package:bpmf_py/bpmf_codes.dart';

void main() {
  //You can create a mandarin syllable directly with the contructor.

  const shuai4 = BpmfSyllable($sh, $u, $ai, 4);

  print(shuai4); //outputs: ㄕㄨㄞˋ

  // `$sh, $u, $ai` are just integer charCode, cuz dart doesn't have a char type
  // we have to use integers, bpmf_codes defined the full set of characters used
  // by bopomofo and pinyin:
  //    lower case ones represent bopomofo symbols  - eg. $eng for 'ㄥ'
  //    upper case ones represent vanilla latin letters - eg. $Z for 'z'
  //    $1 - $5 are bopomofo tonemarks

  var txt = '\t ㄎㄨㄟˋ ㄖㄣˊ';
  //Parse bopomofo
  var (syl, pos) = BpmfSyllable.parseBopomofo('\t ㄎㄨㄟˋ ㄖㄣˊ');
  //It skips spaces and returns the first recognized syllable and the
  //new position of the letter immediately after the syllable

  print(syl); //outputs: 'ㄎㄨㄟˋ'

  //Continue to parse the next syllable
  (syl, pos) = BpmfSyllable.parseBopomofo(txt, pos: pos);
  print(syl); //outputs: 'ㄖㄣˊ'

  //If you don't care about the continuous parsing you can simply use the factory
  //method, ignore the position.
  syl = BpmfSyllable.fromBopomofo(txt);
  print("'$syl' again!"); //outputs: 'ㄎㄨㄟˋ' again!

  //parsing pinyin and ascii pinyin are similar:
  txt = 'ráo';
  syl = BpmfSyllable.fromPinyin(txt);
  print(syl.pinyin); //outputs:'ráo'

  txt = 'lve4';
  syl = BpmfSyllable.fromAsciiPinyin(txt);
  print(syl.pinyin); //outputs:'lüè'

  //try BpmfSyllable.parsePinyin and BpmfSyllable.parseAsciiPinyin yourself!

  //The syllable object is equatable and comparable
  syl = BpmfSyllable($r, $u, $ang, 3); // a fabricated sound
  final syl2 = BpmfSyllable.fromAsciiPinyin('ruang3');
  assert(syl == syl2);

  final syllables = ['zhuan4', 'an3', 'an1', 'bo2', 'qi3']
      .map(BpmfSyllable.fromAsciiPinyin)
      .toList();
  syllables.sort((a, b) => a.compareTo(b));
  print(
      syllables.map((x) => x.asciiPinyin)); //out: (bo2, qi3, zhuan4, an1, an3)
  //The order conforms to the order of bopomofo: b p ... i u ü

  //For you convenience the following helper functions are also provided:
  print(pinyinToAsciiPinyin('ráo'));  //outputs: rao2
  print(asciiPinyinToPinyin('rao2')); //outputs: ráo
  print(bopomofoToPinyin('ㄑㄩㄥ'));   //outputs: 'qiōng'
  print(pinyinToBopomofo('qiōng'));   //outputs: 'ㄑㄩㄥ
  print(asciiPinyinToBopomofo('qiong1'));   //outputs: 'ㄑㄩㄥ
  print(bopomofoToAsciiPinyin('ㄑㄩㄥ'));   //outputs: 'qiong1
}

```
