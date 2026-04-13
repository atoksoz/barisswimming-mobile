import 'package:e_sport_life/core/constants/announcement_preview_constants.dart';

class AnnouncementDescriptionPreviewUtil {
  AnnouncementDescriptionPreviewUtil._();

  static String preview(
    String description, {
    int maxLength = AnnouncementPreviewConstants.descriptionMaxLength,
  }) {
    final t = description.trim();
    if (t.length <= maxLength) return t;
    return '${t.substring(0, maxLength)}...';
  }
}
