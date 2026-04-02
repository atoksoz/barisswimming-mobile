import 'dart:convert';

extension jsonToArray on String {
  Map<String, dynamic> toJsonMap() {
    final decoded = json.decode(this);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else {
      throw FormatException("String is not a valid JSON object.");
    }
  }
}
