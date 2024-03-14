import 'package:bpmf_py/bpmf_py.dart';
import 'package:bpmf_py/bpmf_codes.dart';

void main() {
  //You can create a mandarin syllable directly with the contructor.

  const shuai4 = BpmfSyllable($sh, $u, $ai, 4);

  print(shuai4);

  ///outputs: ㄕㄨㄞˋ

  // `$sh, $u, $ai` are just integer charCode, cuz dart doesn't have a char type
  // we have to use integers, bpmf_codes defined the full set of characters used
  // by bopomofo and pinyin:
  //    lower case ones represent bopomofo symbols  - eg. $eng for 'ㄥ'
  //    upper case ones represent vanilla latin letters - eg. $Z for 'z'
  //    $1 - $5 are bopomofo tonemarks

  //
}
