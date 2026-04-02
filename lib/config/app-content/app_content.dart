import 'dart:convert';

class ContentItem {
  final String title;
  final String? content;
  final List<String>? rules;

  const ContentItem({
    required this.title,
    this.content,
    this.rules,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    List<String>? rules;
    if (json['rules'] is List) {
      rules = (json['rules'] as List).map((item) {
        if (item is String) return item;
        if (item is Map) return item['text']?.toString() ?? '';
        return '';
      }).toList();
    }

    return ContentItem(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      rules: rules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (content != null) 'content': content,
      if (rules != null) 'rules': rules,
    };
  }
}

class AppContent {
  final ContentItem? kvkk;
  final ContentItem? membershipRules;
  final ContentItem? facilityRules;
  final ContentItem? serviceRules;
  final ContentItem? groupRules;

  const AppContent({
    this.kvkk,
    this.membershipRules,
    this.facilityRules,
    this.serviceRules,
    this.groupRules,
  });

  static const _keyKvkk = 'content_kvkk';
  static const _keyMembershipRules = 'content_membership_rules';
  static const _keyFacilityRules = 'content_facility_rules';
  static const _keyServiceRules = 'content_service_rules';
  static const _keyGroupRules = 'content_group_rules';

  factory AppContent.fromSettingsOutput(List<dynamic> items) {
    ContentItem? _parse(String key) {
      final item = items.firstWhere(
        (e) => e['key'] == key,
        orElse: () => null,
      );
      if (item == null) return null;

      final value = item['value'];
      if (value is Map<String, dynamic>) {
        return ContentItem.fromJson(value);
      }
      if (value is String && value.isNotEmpty) {
        try {
          final decoded = json.decode(value);
          if (decoded is Map<String, dynamic>) {
            return ContentItem.fromJson(decoded);
          }
        } catch (_) {}
      }
      return null;
    }

    return AppContent(
      kvkk: _parse(_keyKvkk),
      membershipRules: _parse(_keyMembershipRules),
      facilityRules: _parse(_keyFacilityRules),
      serviceRules: _parse(_keyServiceRules),
      groupRules: _parse(_keyGroupRules),
    );
  }

  factory AppContent.fromJson(Map<String, dynamic> json) {
    return AppContent(
      kvkk: json['kvkk'] != null
          ? ContentItem.fromJson(json['kvkk'] as Map<String, dynamic>)
          : null,
      membershipRules: json['membershipRules'] != null
          ? ContentItem.fromJson(
              json['membershipRules'] as Map<String, dynamic>)
          : null,
      facilityRules: json['facilityRules'] != null
          ? ContentItem.fromJson(
              json['facilityRules'] as Map<String, dynamic>)
          : null,
      serviceRules: json['serviceRules'] != null
          ? ContentItem.fromJson(
              json['serviceRules'] as Map<String, dynamic>)
          : null,
      groupRules: json['groupRules'] != null
          ? ContentItem.fromJson(json['groupRules'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (kvkk != null) 'kvkk': kvkk!.toJson(),
      if (membershipRules != null)
        'membershipRules': membershipRules!.toJson(),
      if (facilityRules != null) 'facilityRules': facilityRules!.toJson(),
      if (serviceRules != null) 'serviceRules': serviceRules!.toJson(),
      if (groupRules != null) 'groupRules': groupRules!.toJson(),
    };
  }

  bool get hasAnyContent =>
      kvkk != null ||
      membershipRules != null ||
      facilityRules != null ||
      serviceRules != null ||
      groupRules != null;
}
