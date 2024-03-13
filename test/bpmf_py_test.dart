import 'package:bpmf_py/bpmf_py.dart';
import 'package:test/test.dart';
import 'mandarin_sounds.dart';

void main() {
  test('BpSyllable:parser can skip spaces', () {
    final src = ' \tㄘㄨㄢˋ';
    final tgt = 'ㄘㄨㄢˋ';
    expect(BpSyllable.parseBopomofo(src).$1.bopomofo, tgt);
    expect(BpSyllable.parseAsciiPinyin("xi'an", pos: 2).$1.asciiPinyin, 'an');
  });

  test('BpSyllable:can convert bopomofo into standard pinyin', () {
    for (final (bpmf, py) in mandarinSounds) {
      final (syl, _) = BpSyllable.parseBopomofo(bpmf);
      expect(syl.pinyin, py);
    }
  });

  test('BpSyllable:can parse bopomofo and give it back', () {
    for (final (bpmf, _) in mandarinSounds) {
      final (syl, _) = BpSyllable.parseBopomofo(bpmf);
      expect(syl.toString(), bpmf);
    }
  });
  test('BpSyllable:can write and read ascii pinyin', () {
    for (final (bpmf, py) in mandarinSounds) {
      final (syl, _) = BpSyllable.parseBopomofo(bpmf);
      final asc = syl.asciiPinyin;
      final (syl2, _) = BpSyllable.parseAsciiPinyin(asc);
      expect(syl2.toString(), bpmf);
      expect(syl2.pinyin, py);
    }
  });
}
