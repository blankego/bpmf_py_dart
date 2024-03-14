import 'package:bpmf_py/bpmf_py.dart';
import 'package:bpmf_py/bpmf_codes.dart';
import 'package:test/test.dart';
import 'mandarin_sounds.dart';

void main() {
  test('BpmfSyllable:parser can skip spaces', () {
    final src = " \t'ㄘㄨㄢˋ";
    final tgt = 'ㄘㄨㄢˋ';
    expect(BpmfSyllable.parseBopomofo(src).$1.bopomofo, tgt);
    expect(BpmfSyllable.parseAsciiPinyin("xi'an", pos: 2).$1.asciiPinyin, 'an');
  });

  test('BpmfSyllable:can convert bopomofo into standard pinyin', () {
    for (final (bpmf, py) in mandarinSounds) {
      final (syl, _) = BpmfSyllable.parseBopomofo(bpmf);
      expect(syl.pinyin, py);
    }
  });

  test('BpmfSyllable:can parse bopomofo and give it back', () {
    for (final (bpmf, _) in mandarinSounds) {
      final (syl, _) = BpmfSyllable.parseBopomofo(bpmf);
      expect(syl.toString(), bpmf);
    }
  });
  test('BpmfSyllable:can write and read ascii pinyin', () {
    for (final (bpmf, py) in mandarinSounds) {
      final (syl, _) = BpmfSyllable.parseBopomofo(bpmf);
      final asc = syl.asciiPinyin;
      final (syl2, _) = BpmfSyllable.parseAsciiPinyin(asc);
      expect(syl2.toString(), bpmf);
      expect(syl2.pinyin, py);
    }
  });

  test('BpmfSyllable:has a unique hash code', () {
    final cnt = mandarinSounds.length;
    final hashCodeSet = mandarinSounds
        .map((e) => BpmfSyllable.parseBopomofo(e.$1).$1.hashCode)
        .toSet();
    expect(hashCodeSet.length, cnt);
  });

  test('BpmfSyllable:has correct order', () {
    var sylsOrig =
        mandarinSounds.map((e) => BpmfSyllable.fromBopomofo(e.$1)).toList();
    var sylsSorted = [...sylsOrig];
    sylsSorted.sort();
    for (var i = 0; i < sylsSorted.length; ++i) {
      var s = sylsSorted[i];
      var s0 = sylsOrig[i];
      expect(s, s0);
    }
  });

  test('BpmfSyllable:is equatable', () {
    final s1 = BpmfSyllable($r, $u, $ang, 3);
    final s2 = BpmfSyllable.fromAsciiPinyin('ruang3');
    expect(s1 == s2, true);
  });
}
