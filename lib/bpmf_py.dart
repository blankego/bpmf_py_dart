import 'src/py_maps.dart';
import 'src/spell_tree.dart';
import 'src/bpmf_codes.dart';

class BpSyllable {
  //#region fields and ctor
  //The following three fields are all charcode of corresponding bopomofo symbols
  final int init;
  final int med;
  final int rime;

  //Tone is a number between 1 and 5,
  // which represents level,rising,dipping, falling and neutral respectively
  // 0 for unknown if the pinyin in ascii form is unmarked
  final int tone;

  const BpSyllable(this.init, this.med, this.rime, this.tone);

  //#endregion

  //#region structural props

  ///四呼：0開，1齊，2合，3撮
  int get sihu => switch (med) { $i => 1, $u => 2, $yu => 3, _ => 0 };

  //#endregion

  //#region props

  @override
  String toString() => bopomofo;

  String get pinyin {
    final buf = StringBuffer(pyInit);
    final (m, nuc, coda) = _pyRimeParts;
    if (m > 0) buf.writeCharCode(m);
    final nucStr = pyUntonedToTonedNucMap[nuc]![tone - 1];
    buf.write(nucStr);
    if (coda.isNotEmpty) buf.write(coda);
    return buf.toString();
  }

  String get asciiPinyin {
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
    final buf = StringBuffer();
    if (tone == 5) buf.writeCharCode(toneMarks[4]);
    if (init > 0) buf.writeCharCode(init);
    if (med > 0) buf.writeCharCode(med);
    if (rime > 0) buf.writeCharCode(rime);
    if (tone > 1 && tone != 5) buf.writeCharCode(toneMarks[tone - 1]);

    return buf.toString();
  }

  //#endregion

  static int skipSpaces(String str, int pos) {
    for (;; pos++) {
      if (str.codeUnitAt(pos) case $space || $fullspace || $tab || $apos) {
        continue;
      }
      return pos;
    }
  }

  static (BpSyllable, int) parseBopomofo(String bopomofo, {int pos = 0}) {
    int letter = bopomofo.codeUnitAt(pos = skipSpaces(bopomofo, pos));
    final len = bopomofo.length;
    //初始化聲介韻調
    int i = 0, m = 0, r = 0, t = 0;

    //首字母是否輕聲
    if (letter == $5) {
      t = 5;
      letter = bopomofo.codeUnitAt(++pos);
    }

    //聲母
    if (letter >= $b && letter < $a) {
      i = letter;
      if (++pos < len) letter = bopomofo.codeUnitAt(pos);
    }

    //介音及iuü韻腹
    if (pos < len && letter >= $i && letter <= $yu) {
      m = letter;
      if (++pos < len) letter = bopomofo.codeUnitAt(pos);
    }

    //韻母
    if (pos < len && letter >= $a && letter <= $er) {
      r = letter;
      if (++pos < len) letter = bopomofo.codeUnitAt(pos);
    }

    //Test whether essential parts of the syllable exist
    if (!(m > 0 || r > 0 || i >= $zh && i <= $s)) {
      throw ArgumentError('Invalid bopomofo spelling: $bopomofo');
    }

    //聲調
    if (t == 0) {
      //非輕聲

      if (pos < len) {
        if (const [$1, $2, $3, $4].indexOf(letter) case int toneNum && >= 0) {
          t = toneNum + 1;
          pos++;
        }
      } else {
        //陰平不標
        t = 1;
      }
    }

    return (BpSyllable(i, m, r, t), pos);
  }

  static (BpSyllable, int) parseAsciiPinyin(String pinyin, {int pos = 0}) {
    var (i, p1) = parsePinyinInitial(pinyin, pos: pos);
    //W,Y
    bool isW = i == $u;
    bool isY = i == $i;
    if (isW || isY) i = 0;

    if (ascPyRimeTree.findMatch(pinyin, p1) case ((var m, var r), var p2)?) {
      var t = 0;
      if (p2 < pinyin.length) {
        if (pinyin.codeUnitAt(p2)
            case > 48 && < 54 && var toneCode /* '1' < x < '5'*/) {
          t = toneCode - 48;
          p2++;
        }
      }

      //dealing with pinyin quirks

      if (isW) {
        //wu,w_ -> u, u_
        m = $u;
      } else if (isY) {
        //yan -> ian, yuan -> üan
        m = m == $u || m == $yu ? $yu : $i;
        //ye -> ye(h)
        if (m == $i && r == $e) r = $eh;
      } else if (i case $j || $q || $x when m == $u) {
        //juan -> jüan
        m = $yu;
      } else if (i case >= $zh && <= $s when m == $i && r == 0) {
        //zh+i -> zhi
        m = 0;
      }

      return (BpSyllable(i, m, r, t), p2);
    }
    throw ArgumentError('"$pinyin" is not valid pinyin');
  }

  static (int, int) parsePinyinInitial(String py, {int pos = 0}) {
    pos = skipSpaces(py, pos);
    var firstLetter = py.codeUnitAt(pos);
    if (firstLetter < $A || firstLetter > $Z) {
      throw ArgumentError(
          'The letter ${py[pos]} at $pos of "$py" is invalid pinyin initial');
    }
    var i = pyFirstLetterMap[firstLetter];
    if (i == null) return (0, pos);
    pos++;
    if (i case $z || $c || $s when py.codeUnitAt(pos) == $H) {
      pos++;
      i = switch (i) { $z => $zh, $c => $ch, _ => $sh };
    }
    return (i, pos);
  }
}

//#region maps

const pyRimeNucCodaMap = {
  $a: ($A, ''),
  $o: ($O, ''),
  $e: ($E, ''),
  $eh: ($E, ''),
  $ai: ($A, 'i'),
  $ei: ($E, 'i'),
  $ao: ($A, 'o'),
  $ou: ($O, 'u'),
  $an: ($A, 'n'),
  $en: ($E, 'n'),
  $ang: ($A, 'ng'),
  $eng: ($E, 'ng'),
  $er: ($E, 'r'),
  $i: ($I, ''),
  $u: ($U, ''),
  $yu: ($YU, ''),
  0: ($I, ''), //(r)i
};

const pyUntonedToTonedNucMap = {
  $A: 'āáǎàa',
  $E: 'ēéěèe',
  $I: 'īíǐìi',
  $O: 'ōóǒòo',
  $U: 'ūúǔùu',
  $YU: 'ǖǘǚǜü',
};

final Map<int, int> pyTonedToUntonedNucMap = (() => {
      for (final MapEntry(:key, :value) in pyUntonedToTonedNucMap.entries)
        for (final ch in value.codeUnits) ch: key
    })();

const pyFirstLetterMap = {
  $B: $b,
  $P: $p,
  $M: $m,
  $F: $f,
  $D: $d,
  $T: $t,
  $N: $n,
  $L: $l,
  $G: $g,
  $K: $k,
  $H: $h,
  $J: $j,
  $Q: $q,
  $X: $x,
  $Z: $z,
  $C: $c,
  $S: $s,
  $R: $r,
  $Y: $i,
  $W: $u,
};

const initialPyMap = {
  $b: 'b',
  $p: 'p',
  $m: 'm',
  $f: 'f',
  $d: 'd',
  $t: 't',
  $n: 'n',
  $l: 'l',
  $g: 'g',
  $k: 'k',
  $h: 'h',
  $j: 'j',
  $q: 'q',
  $x: 'x',
  $zh: 'zh',
  $ch: 'ch',
  $sh: 'sh',
  $r: 'r',
  $z: 'z',
  $c: 'c',
  $s: 's',
  $i: 'y',
  $u: 'w',
  $yu: 'y',
  // 0: '',
};

// const fromBpmfLetterMap = {
//   'ㄅ': $b,
//   'ㄆ': $p,
//   'ㄇ': $m,
//   'ㄈ': $f,
//   'ㄉ': $d,
//   'ㄊ': $t,
//   'ㄋ': $n,
//   'ㄌ': $l,
//   'ㄍ': $g,
//   'ㄎ': $k,
//   'ㄏ': $h,
//   'ㄐ': $j,
//   'ㄑ': $q,
//   'ㄒ': $x,
//   'ㄓ': $zh,
//   'ㄔ': $ch,
//   'ㄕ': $sh,
//   'ㄖ': $r,
//   'ㄗ': $z,
//   'ㄘ': $c,
//   'ㄙ': $s,
//   'ㄚ': $a,
//   'ㄛ': $o,
//   'ㄜ': $e,
//   'ㄝ': $eh,
//   'ㄞ': $ai,
//   'ㄟ': $ei,
//   'ㄠ': $ao,
//   'ㄡ': $ou,
//   'ㄢ': $an,
//   'ㄣ': $en,
//   'ㄤ': $ang,
//   'ㄥ': $eng,
//   'ㄦ': $er,
//   'ㄧ': $i,
//   'ㄨ': $u,
//   'ㄩ': $yu,
// };

// final Map<String, String> toBpmfLetterMap = {
//   for (final MapEntry(:key, :value) in fromBpmfLetterMap.entries) value: key
// };

//#endregion
