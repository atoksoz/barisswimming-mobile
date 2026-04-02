import 'dart:ui';

extension ExpiredTextDecoration on int? {
  TextDecoration get decorationLineThrough {
    if (this == 1) {
      return TextDecoration.lineThrough;
    } else {
      return TextDecoration.none;
    }
  }
}
