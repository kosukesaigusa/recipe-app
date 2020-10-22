/// 数値やアルファベットの全角文字を半角にする
String halfWiden(String text) {
  return text
      .replaceAll(RegExp(r'[“”]/g'), '"')
      .replaceAll('’', "'")
      .replaceAll('‘', "`")
      .replaceAll('￥', '')
      .replaceAll('\\', '')
      .replaceAll('　', ' ')
      .replaceAll(RegExp(r'[〜～]'), '~')
      .replaceAll(RegExp(r'[―─－]'), '-');
}

/// ひらがなをカタカナに変換する
String hira2kata(String text) {
  return text.replaceAllMapped(
      RegExp(r'[\u3041-\u3096]'),
      (Match match) =>
          String.fromCharCode(match.group(0).codeUnitAt(0) + 0x60));
}

/// 半角カナを全角カナに変換する
String kanaFullWiden(String text) {
  RegExp pattern = RegExp(kanaMap.keys.join('|'));
  return text.replaceAllMapped(
      pattern, (Match match) => '${kanaMap[match.group(0)]}');
}

/// 句読点や記号の区切りを切ったりくっつけたりする
String chopChink(String text) {
  return text
      .replaceAll(RegExp(r'["]'), ' ')
      .replaceAll(RegExp(r"[']"), ' ')
      .replaceAll(RegExp(r'[-/&!\?@_,.:;~]'), ' ')
      .replaceAll(RegExp(r'[−‐―／＆！？＿，．：；“”‘’〜～]'), ' ')
      .replaceAll(RegExp(r'[♪、。]'), ' ')
      .replaceAll(RegExp(r'[・×☆★\*＊]'), ' ')
      .replaceAll(RegExp(r'[\(\)\[\]（）「」『』【】〔〕]'), ' ')
      .replaceAll('\s{2,}', ' ')
      .replaceAll('', '')
      .trim();
}

/// N-Gram
List nGram(int n, String text) {
  if (n < 1 || n == double.infinity) {
    throw ('$n is not a valid argument for n-gram');
  }

  List nGrams = [];

  // 対象が空白('')または一文字の場合は空のリストを返す
  if (text.length < 1) {
    return nGrams;
  }

  // N-gram（N文字ずつに分解したリストを返す）
  for (int i = 0; i < text.length - n + 1; i++) {
    nGrams.add('');
    nGrams[i] = text.substring(i, i + n);
  }

  return nGrams;
}

/// 各前処理を行って、Bi-gram の結果をリストで返す
List tokenize(List textList) {
  List resultList = [];
  String preVal = '';

  final texts =
      halfWiden(hira2kata(kanaFullWiden(chopChink(textList.join(' ')))))
          .toLowerCase()
          .split(' ');

  texts.forEach((String text) {
    if (RegExp(r'^[0-9a-z+]+$').hasMatch(text)) {
      /// 英数字だけで構成されている語：Ngramを作用させない
      resultList.add(text);
      preVal = '';
    } else if (text.length == 1 && RegExp(r'^[亜-黑]+$').hasMatch(text)) {
      /// 一文字の漢字：次の文字と合わせて処理
      preVal = text;
    } else {
      /// その他：Ngram (N = 2) を実行
      nGram(2, '$preVal$text').forEach((element) {
        resultList.add(element);
      });
      preVal = '';
    }
  });

  return resultList;
}

/// 半角カナと全角カナの対応マップ
final kanaMap = {
  'ｶﾞ': 'ガ',
  'ｷﾞ': 'ギ',
  'ｸﾞ': 'グ',
  'ｹﾞ': 'ゲ',
  'ｺﾞ': 'ゴ',
  'ｻﾞ': 'ザ',
  'ｼﾞ': 'ジ',
  'ｽﾞ': 'ズ',
  'ｾﾞ': 'ゼ',
  'ｿﾞ': 'ゾ',
  'ﾀﾞ': 'ダ',
  'ﾁﾞ': 'ヂ',
  'ﾂﾞ': 'ヅ',
  'ﾃﾞ': 'デ',
  'ﾄﾞ': 'ド',
  'ﾊﾞ': 'バ',
  'ﾋﾞ': 'ビ',
  'ﾌﾞ': 'ブ',
  'ﾍﾞ': 'ベ',
  'ﾎﾞ': 'ボ',
  'ﾊﾟ': 'パ',
  'ﾋﾟ': 'ピ',
  'ﾌﾟ': 'プ',
  'ﾍﾟ': 'ペ',
  'ﾎﾟ': 'ポ',
  'ｳﾞ': 'ヴ',
  'ﾜﾞ': 'ヷ',
  'ｦﾞ': 'ヺ',
  'ｱ': 'ア',
  'ｲ': 'イ',
  'ｳ': 'ウ',
  'ｴ': 'エ',
  'ｵ': 'オ',
  'ｶ': 'カ',
  'ｷ': 'キ',
  'ｸ': 'ク',
  'ｹ': 'ケ',
  'ｺ': 'コ',
  'ｻ': 'サ',
  'ｼ': 'シ',
  'ｽ': 'ス',
  'ｾ': 'セ',
  'ｿ': 'ソ',
  'ﾀ': 'タ',
  'ﾁ': 'チ',
  'ﾂ': 'ツ',
  'ﾃ': 'テ',
  'ﾄ': 'ト',
  'ﾅ': 'ナ',
  'ﾆ': 'ニ',
  'ﾇ': 'ヌ',
  'ﾈ': 'ネ',
  'ﾉ': 'ノ',
  'ﾊ': 'ハ',
  'ﾋ': 'ヒ',
  'ﾌ': 'フ',
  'ﾍ': 'ヘ',
  'ﾎ': 'ホ',
  'ﾏ': 'マ',
  'ﾐ': 'ミ',
  'ﾑ': 'ム',
  'ﾒ': 'メ',
  'ﾓ': 'モ',
  'ﾔ': 'ヤ',
  'ﾕ': 'ユ',
  'ﾖ': 'ヨ',
  'ﾗ': 'ラ',
  'ﾘ': 'リ',
  'ﾙ': 'ル',
  'ﾚ': 'レ',
  'ﾛ': 'ロ',
  'ﾜ': 'ワ',
  'ｦ': 'ヲ',
  'ﾝ': 'ン',
  'ｧ': 'ァ',
  'ｨ': 'ィ',
  'ｩ': 'ゥ',
  'ｪ': 'ェ',
  'ｫ': 'ォ',
  'ｯ': 'ッ',
  'ｬ': 'ャ',
  'ｭ': 'ュ',
  'ｮ': 'ョ',
  '｡': '。',
  '､': '、',
  'ｰ': 'ー',
  '｢': '「',
  '｣': '」',
  '･': '・',
};
