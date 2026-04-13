class StringCapitalizationUtil {
  StringCapitalizationUtil._();

  /// Her kelimenin ilk harfini büyük, geri kalanını küçük yapar.
  static String titleCaseWords(String input) {
    final t = input.trim();
    if (t.isEmpty) return input;
    return t.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      final first = word.substring(0, 1).toUpperCase();
      final rest =
          word.length > 1 ? word.substring(1).toLowerCase() : '';
      return '$first$rest';
    }).join(' ');
  }
}
