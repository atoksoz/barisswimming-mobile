import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _abilityCacheKey = 'mobile_abilities';

class MobileAbility {
  final String action;
  final String subject;

  const MobileAbility({required this.action, required this.subject});

  factory MobileAbility.fromJson(Map<String, dynamic> json) {
    return MobileAbility(
      action: json['action'] ?? 'manage',
      subject: json['subject'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'action': action, 'subject': subject};
}

class MobileAbilityService {
  List<MobileAbility> _abilities = [];
  bool _allAccess = true;

  List<MobileAbility> get abilities => _abilities;
  bool get hasAllAccess => _allAccess;

  void load(List<dynamic> rawAbilities) {
    _abilities = rawAbilities
        .map((e) => MobileAbility.fromJson(e as Map<String, dynamic>))
        .toList();

    _allAccess = _abilities.isEmpty ||
        _abilities.any((a) => a.action == 'manage' && a.subject == 'all');
  }

  bool canView(String subject) {
    if (_allAccess) return true;
    return _abilities.any(
      (a) => a.subject == subject && (a.action == 'read' || a.action == 'manage'),
    );
  }

  bool canManage(String subject) {
    if (_allAccess) return true;
    return _abilities.any(
      (a) => a.subject == subject && a.action == 'manage',
    );
  }

  Future<void> saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_abilities.map((a) => a.toJson()).toList());
    await prefs.setString(_abilityCacheKey, encoded);
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_abilityCacheKey);
    if (raw != null) {
      final List<dynamic> decoded = json.decode(raw);
      load(decoded);
    }
  }

  Future<void> clearCache() async {
    _abilities = [];
    _allAccess = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_abilityCacheKey);
  }
}
