import 'package:e_sport_life/core/l10n/app_labels.dart';

class RelationshipType {
  RelationshipType._();

  static String getLabel(String? key) {
    if (key == null || key.trim().isEmpty) return '';
    final trimmed = key.trim();
    final lower = trimmed.toLowerCase();
    final labels = AppLabels.current.relationshipLabels;

    return labels[lower] ?? labels[trimmed] ?? _capitalize(trimmed);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
