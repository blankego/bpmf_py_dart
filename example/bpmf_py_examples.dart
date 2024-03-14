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
