class EpisodeNumber {
  EpisodeNumber._();

  static final RegExp _taggedPattern = RegExp(
    r'第\s*(\d+|[零〇一二两三四五六七八九十百千万亿]+)\s*[集章回话節节期卷部季册話]',
  );

  static final RegExp _unitPattern = RegExp(r'(\d{1,6})\s*[集章回话節节期卷部季册話]');

  static final RegExp _parenPattern = RegExp(r'（[^）]*）|\([^)]*\)');

  static const String _delimiters = r'\s_\-\u00B7，、,:：.\[\]【】';

  static final RegExp _leadingNumberPattern = RegExp(
    '^[$_delimiters]*(\\d{1,6})(?=\$|[$_delimiters])',
  );

  static final RegExp _standaloneNumberPattern = RegExp(
    '(?:^|[$_delimiters])(\\d{1,6})(?=\$|[$_delimiters])',
  );

  static final RegExp _arabicPattern = RegExp(r'^\d+$');

  static const Map<String, int> _digits = {
    '零': 0,
    '〇': 0,
    '一': 1,
    '二': 2,
    '两': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
  };

  static const Map<String, int> _units = {
    '十': 10,
    '百': 100,
    '千': 1000,
    '万': 10000,
    '亿': 100000000,
  };

  static int? parseChinese(String s) {
    if (s.isEmpty) return null;
    int total = 0;
    int section = 0;
    int digit = 0;
    for (final rune in s.runes) {
      final c = String.fromCharCode(rune);
      if (_digits.containsKey(c)) {
        digit = _digits[c]!;
      } else if (_units.containsKey(c)) {
        final unit = _units[c]!;
        if (unit == 10000 || unit == 100000000) {
          section = (section + digit) * unit;
          total += section;
          section = 0;
        } else {
          section += (digit == 0 ? 1 : digit) * unit;
        }
        digit = 0;
      } else {
        return null;
      }
    }
    return total + section + digit;
  }

  static List<int> keyOf(String source, {String? bookName}) {
    var s = source;
    if (bookName != null &&
        bookName.isNotEmpty &&
        s.length > bookName.length &&
        s.startsWith(bookName)) {
      s = s.substring(bookName.length);
    }
    s = s.replaceAll(_parenPattern, '');

    final tagged = <int>[];
    for (final match in _taggedPattern.allMatches(s)) {
      final raw = match.group(1)!;
      final n = _arabicPattern.hasMatch(raw)
          ? int.parse(raw)
          : parseChinese(raw);
      if (n != null && n > 0) tagged.add(n);
    }
    if (tagged.isNotEmpty) return tagged;

    final unitMatch = _unitPattern.firstMatch(s);
    if (unitMatch != null) return [int.parse(unitMatch.group(1)!)];

    final leading = _leadingNumberPattern.firstMatch(s);
    if (leading != null) return [int.parse(leading.group(1)!)];

    final standalone = _standaloneNumberPattern.firstMatch(s);
    if (standalone != null) return [int.parse(standalone.group(1)!)];

    return [];
  }

  static List<int> trackKeyOf(
    int trackNumber,
    String title,
    String fileName, {
    String? bookName,
  }) {
    if (trackNumber > 0) return [trackNumber];
    final fromTitle = keyOf(title, bookName: bookName);
    if (fromTitle.isNotEmpty) return fromTitle;
    return keyOf(fileName, bookName: bookName);
  }

  static int compareKeys(List<int> a, List<int> b) {
    final length = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final cmp = a[i].compareTo(b[i]);
      if (cmp != 0) return cmp;
    }
    return a.length.compareTo(b.length);
  }
}
