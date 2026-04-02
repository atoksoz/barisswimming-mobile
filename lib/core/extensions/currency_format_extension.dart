extension StringCurrencyFormat on String {
  String toPrice({int fractionDigits = 1, String symbol = "₺"}) {
    try {
      final value = double.parse(this);
      return value.toStringAsFixed(fractionDigits) + " $symbol";
    } catch (e) {
      return this; // parse edilemezse orijinal string döner
    }
  }
}
