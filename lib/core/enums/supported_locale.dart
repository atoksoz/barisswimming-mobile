enum SupportedLocale {
  tr('tr'),
  en('en');

  final String code;
  const SupportedLocale(this.code);

  static SupportedLocale fromCode(String code) {
    for (final locale in SupportedLocale.values) {
      if (locale.code == code) return locale;
    }
    return SupportedLocale.tr;
  }
}
