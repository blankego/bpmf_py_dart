import 'package:bpmf_py/bpmf_py.dart';
import 'package:test/test.dart';
import 'mandarin_sounds.dart';

void main() {
  test('BpSyllable:parser can skip spaces', () {
    final src = ' \tㄘㄨㄢˋ';
    final tgt = 'ㄘㄨㄢˋ';
    expect(BpSyllable.parseBopomofo(src).$1.bopomofo, tgt);
  });

  test('BpSyllable:can convert bopomofo into standard pinyin', () {
    for (final (bpmf, py) in mandarinSounds) {
      final (syl, _) = BpSyllable.parseBopomofo(bpmf);
      expect(syl.pinyin, py);
    }
  });
}
