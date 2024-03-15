import 'src/py_maps.dart';
import 'src/spell_tree.dart';
import 'src/bpmf_codes.dart';

class BpmfSyllable implements Comparable<BpmfSyllable> {
  //#region fields and ctor
  //The following three fields are all charcode of corresponding bopomofo symbols
  final int init;
  final int med;
  final int rime;

  //Tone is a number between 1 and 5,
  // which represents level,rising,dipping, falling and neutral respectively
  // 0 for unknown if the pinyin in ascii form is unmarked
  final int tone;

  static const BpmfSyllable empty = BpmfSyllable(0, 0, 0, 0);

  const BpmfSyllable(this.init, this.med, this.rime, this.tone);

  factory BpmfSyllable.fromBopomofo(String bpmf) => parseBopomofo(bpmf).$1;

  factory BpmfSyllable.fromAsciiPinyin(String ascPy) =>
      parseAsciiPinyin(ascPy).$1;

  factory BpmfSyllable.fromPinyin(String py) => parsePinyin(py).$1;

  //#endregion

  //#region structural props

  ///四呼：0開，1齊，2合，3撮
  int get sihu => switch (med) { $i => 1, $u => 2, $yu => 3, _ => 0 };

  //#endregion

  //#region implementation of interfaces
  @override
  String toString() => bopomofo;

  @override
  int compareTo(BpmfSyllable other) => hashCode - other.hashCode;

  ///It has unique hash code and the hash code is in correct order
  @override
  int get hashCode =>
      tone +
      (rime == 0 ? 0 : rime - $s) * 41 +
      (med == 0 ? 0 : med - $er) * 41 * 41 +
      (init == 0 ? 40 : init - $b) * 41 * 41 * 41;

  @override
  bool operator ==(covariant BpmfSyllable other) => other.hashCode == hashCode;

  operator >(BpmfSyllable other) => compareTo(other) > 0;
  operator >=(BpmfSyllable other) => this > other || this == other;
  operator <(BpmfSyllable other) => !(this >= other);
  operator <=(BpmfSyllable other) => this < other || this == other;
  //#endregion

  //#region props
  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  String get pinyin {
    if (isEmpty) return '';

    final buf = StringBuffer(pyInit);
    final (m, nuc, coda) = _pyRimeParts;
    if (m > 0) buf.writeCharCode(m);
    final nucStr = pyUntonedToTonedNucMap[nuc]![tone - 1];
    buf.write(nucStr);
    if (coda.isNotEmpty) buf.write(coda);
    return buf.toString();
  }

  String get asciiPinyin {
    if (isEmpty) return '';

    final buf = StringBuffer(pyInit)
      ..write(medRimeToAscii[(_pySihu, _pyRime)]!)
      ..write(const ['', '1', '2', '3', '4', '5'][tone]);
    return buf.toString();
  }

  String get pyInit => initialPyMap[init == 0 ? med : init] ?? '';

  int get _pySihu => switch (init) {
        0 => switch (med) {
            $i => switch (rime) { 0 || $en || $eng => $i, _ => 0 },
            $u => rime == 0 ? $u : 0,
            $yu => $u,
            _ => med,
          },
        $j || $q || $x when med == $yu => rime == $eng ? $yu : $u,
        _ => med,
      };

  ///eliminate yeh!
  int get _pyRime => init == 0 && med == $i && rime == $eh ? $e : rime;

  ///Y，W视作声母; 可标调元音字母视作韻腹; 标调字母后面的部分视作韻尾,一切以拼写形式为准而非声韵结构 ，如：
  ///yu视作 y+0+u+0、xun, 視為 x+0+u+n，juan視為 j+u+a+n ，gui 视作 g+u+i+0
  (int, int, String) get _pyRimeParts {
    //jqx

    var m = 0;
    var nuc = 0;
    String? coda;
    switch ((med, rime)) {
      // i,u,ü standalone -> 0 + nuc + 0
      case (> 0, 0):
        m = 0;
        coda = '';
        //jü qü xü yü -> ju qu xu yu
        if (init case $j || $q || $x || 0 when med == $yu) {
          nuc = $U;
        } //else look it up from the dict
      //w_ -> w + 0 + _
      case ($u, _) when init == 0:
        m = 0;
      //üe,üan after jqxy -> u + e,an
      case ($yu, $eh || $an) when init == 0 || (init >= $j && init <= $x):
        m = $U;

      //j/q/x/y+ün -> j/q/x/y + 0 + u + n
      case ($yu, $en) when init >= $j && init <= $x || init == 0:
        (m, nuc) = (0, $U);
      //? + (i|u|ü)n -> ? + 0 + (i|u|ü) + n : ü is reserved for special cases
      case (> 0, $en):
        (m, nuc) = (0, switch (med) {  $i => $I, $u => $U, _ => $YU});

      //?iong -> ? + i + o + ng | yong -> y + 0 + o + ng
      case ($yu, $eng):
        (m, nuc) = (init > 0 ? $I : 0, $O);
      //?(i|o)ng -> ? + 0 + (i|o) + ng
      case (> 0, $eng):
        (m, nuc) = (0, med == $u ? $O : $I);

      //y_  -> y + 0 + _
      case ($i, _) when init == 0:
        m = 0;
      default:
        m = switch (med) { $i => $I, $u => $U, $yu => $YU, _ => 0 };
    }

    //if nuc is not yet
    if (nuc == 0) {
      if (rime == $ou && m == $I) {
        //iu
        (nuc, coda) = ($U, '');
      } else if (rime == $ei && m == $U) {
        //ui
        (nuc, coda) = ($I, '');
      } else {
        (nuc, coda) = pyRimeNucCodaMap[rime == 0 ? med : rime]!;
      }
    } else {
      coda ??= switch (rime) {
        $ai || $ei => 'i',
        $ao => 'o',
        $ou => 'u',
        $an || $en => 'n',
        $ang || $eng => 'ng',
        $er => 'r',
        _ => '',
      };
    }
    return (m, nuc, coda);
  }

  String get bopomofo {
    if (isEmpty) return '';

    final buf = StringBuffer();
    if (tone == 5) buf.writeCharCode(toneMarks[4]);
    if (init > 0) buf.writeCharCode(init);
    if (med > 0) buf.writeCharCode(med);
    if (rime > 0) buf.writeCharCode(rime);
    if (tone > 1 && tone != 5) buf.writeCharCode(toneMarks[tone - 1]);

    return buf.toString();
  }

  //#endregion

  //#region parsers

  static int skipSpaces(String str, int pos) {
    for (;; pos++) {
      if (str.codeUnitAt(pos) case $space || $fullspace || $tab || $apos) {
        continue;
      }
      return pos;
    }
  }

  /// It parses the string starting from the character pointed by the pos.
  /// If well-formed spelling of a syllable is found it contructs a corresponding
  /// mandarin syllable object, returns it with the next starting points in the string
  /// If the text is ill-formed instead of throwing an error
  /// its returns a empty syllable with the pos kept unchanged
  static (BpmfSyllable, int) parseBopomofo(String txt, {int pos = 0}) {
    int idx = skipSpaces(txt, pos);
    int letter = txt.codeUnitAt(idx);
    final len = txt.length;

    //初始化聲介韻調
    int i = 0, m = 0, r = 0, t = 0;

    //首字母是否輕聲
    if (letter == $5) {
      t = 5;
      letter = txt.codeUnitAt(++idx);
    }

    //聲母
    if (letter >= $b && letter < $a) {
      i = letter;
      if (++idx < len) letter = txt.codeUnitAt(idx);
    }

    //介音及iuü韻腹
    if (idx < len && letter >= $i && letter <= $yu) {
      m = letter;
      if (++idx < len) letter = txt.codeUnitAt(idx);
    }

    //韻母
    if (idx < len && letter >= $a && letter <= $er) {
      r = letter;
      if (++idx < len) letter = txt.codeUnitAt(idx);
    }

    //Test whether essential parts of the syllable exist
    if (!(m > 0 || r > 0 || i >= $zh && i <= $s)) {
      // throw ArgumentError('Invalid bopomofo spelling: $txt');
      return (empty, pos); //return empty, and original starting point
    }

    //聲調
    if (t == 0) {
      //非輕聲

      if (idx < len) {
        if (const [$1, $2, $3, $4].indexOf(letter) case int toneNum && >= 0) {
          t = toneNum + 1;
          idx++;
        }
      } else {
        //陰平不標
        t = 1;
      }
    }

    return (BpmfSyllable(i, m, r, t), idx);
  }

  static (BpmfSyllable, int) parseAsciiPinyin(String pinyin, {int pos = 0}) {
    var (i, p1) = parsePinyinInitial(pinyin, pos: pos);

    if (ascPyRimeTree.findMatch(pinyin, p1) case ((var m, var r), var p2)?) {
      var t = 0;
      if (p2 < pinyin.length) {
        if (pinyin.codeUnitAt(p2) case > 48 && < 54 && var toneCode) {
          /* 48:'0' < x < 54:'6'*/
          t = toneCode - 48;
          p2++;
        }
      }
      (i, m, r) = _pinyinToSylStructure(i, m, r);
      return (BpmfSyllable(i, m, r, t), p2);
    }
    return (empty, pos);
  }

  ///Translate pinyin into actual syllabic structure
  static (int init, int med, int rime) _pinyinToSylStructure(
      int init, int med, int rime) {
    //W,Y
    bool isW = init == $u;
    bool isY = init == $i;
    if (isW || isY) init = 0;

    if (isW) {
      //wu,w_ -> u, u_
      med = $u;
    } else if (isY) {
      //yan -> ian, yuan -> üan
      med = med == $u || med == $yu ? $yu : $i;
      //ye -> ye(h)
      if (med == $i && rime == $e) rime = $eh;
    } else if (init case $j || $q || $x when med == $u) {
      //juan -> jüan
      med = $yu;
    } else if (init case >= $zh && <= $s when med == $i && rime == 0) {
      //zh+i -> zhi
      med = 0;
    }
    return (init, med, rime);
  }

  static (BpmfSyllable, int) parsePinyin(String pinyin, {int pos = 0}) {
    var (i, p1) = parsePinyinInitial(pinyin, pos: pos);

    if (pyRimeTree.findMatch(pinyin, p1)
        case ((var m, var r, var t), var p2)?) {
      (i, m, r) = _pinyinToSylStructure(i, m, r);
      return (BpmfSyllable(i, m, r, t), p2);
    }
    return (empty, pos);
  }

  static (int, int) parsePinyinInitial(String py, {int pos = 0}) {
    int idx = skipSpaces(py, pos);

    var firstLetter = py.codeUnitAt(idx);
    if ((firstLetter >= $A && firstLetter <= $Z) ||
        pyVowels.contains(firstLetter)) {
      if (pyFirstLetterMap[firstLetter] case int init) {
        idx++;

        //zh, ch, sh
        if (init case $z || $c || $s when py.codeUnitAt(idx) == $H) {
          idx++;
          init = switch (init) { $z => $zh, $c => $ch, _ => $sh };
        }

        return (init, idx);
      }
    }

    return (0, idx);
  }

  //#endregion
}

//#region helper functions

String pinyinToBopomofo(String py) => BpmfSyllable.fromPinyin(py).bopomofo;

String bopomofoToPinyin(String bpmf) => BpmfSyllable.fromBopomofo(bpmf).pinyin;

String asciiPinyinToBopomofo(String ascPy) =>
    BpmfSyllable.fromAsciiPinyin(ascPy).bopomofo;

String bopomofoToAsciiPinyin(bpmf) =>
    BpmfSyllable.fromBopomofo(bpmf).asciiPinyin;

String asciiPinyinToPinyin(String ascPy) =>
    BpmfSyllable.fromAsciiPinyin(ascPy).pinyin;

String pinyinToAsciiPinyin(String py) =>
    BpmfSyllable.fromPinyin(py).asciiPinyin;

//#endregion
