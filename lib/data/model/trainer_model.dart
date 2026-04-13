import 'dart:convert';

import 'package:e_sport_life/core/constants/employee_profession.dart';
import 'package:flutter/foundation.dart';

class TrainerModel {
  final String id;
  final String name;
  /// Randevu `TrainerResource` çıktısı — PHP etiketi (fitness listesi); müzik anahtarları eksikse boş olabilir.
  final String duty;
  /// `employee.profession` — virgüllü anahtarlar (`piano_teacher,guitar_teacher`); yetenek satırı için asıl kaynak.
  /// Nullable saklanır: hot reload sonrası eski örneklerde alan null kalabiliyor; [profession] getter her zaman güvenli.
  final String? _profession;
  String get profession => _profession ?? '';
  final String image;
  final String explanation;
  final String rate;
  final String instagram;
  final String facebook;
  final String tiktok;
  final String twitter;
  final String youtube;
  final int rate_;

  TrainerModel(
      {required this.id,
      required this.name,
      required this.duty,
      String? profession,
      required this.image,
      required this.explanation,
      required this.rate,
      required this.instagram,
      required this.facebook,
      required this.tiktok,
      required this.twitter,
      required this.youtube,
      required this.rate_})
      : _profession = profession;

  /// Meslek / yetenek metni — önce virgüllü `profession` anahtarları, yoksa `duty` (sunucu etiketi).
  String get skillsLabel {
    final source = profession.trim().isNotEmpty ? profession : duty;
    final label = EmployeeProfession.getLabels(source);
    assert(() {
      debugPrint('[TrainerModel] name=$name, profession=$profession, duty=$duty, source=$source → label=$label');
      return true;
    }());
    return label;
  }

  /// Randevu / panel API'leri farklı şekillerde dönebiliyor: düz `profession`, `employee.profession`, liste vb.
  static String? _professionFromJson(Map<String, dynamic> json) {
    dynamic raw = json['profession'] ??
        json['employee_profession'] ??
        json['professions'];

    final employee = json['employee'];
    if (raw == null && employee is Map<String, dynamic>) {
      raw = employee['profession'] ??
          employee['professions'] ??
          employee['employee_profession'];
    }

    if (raw == null) return null;
    if (raw is List) {
      final parts = raw
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isEmpty) return null;
      return parts.join(',');
    }
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    var name = json['name'];
    name = jsonDecode('"$name"');
    var rateString = json['rate'] == null ? "0" : json['rate'].toString();
    return TrainerModel(
        rate: rateString,
        instagram: json['instagram'] == null ? "" : json['instagram'],
        facebook: json['facebook'] == null ? "" : json['facebook'],
        tiktok: json['tiktok'] == null ? "" : json['tiktok'],
        twitter: json['twitter'] == null ? "" : json['twitter'],
        youtube: json['youtube'] == null ? "" : json['youtube'],
        id: json["id"].toString(),
        name: jsonDecode('"$name"'), //name,
        duty: json['duty']?.toString() ?? '',
        profession: _professionFromJson(json),
        image: (json['image'] == null ? "" : json['image']),
        explanation: (json['explanation'] == null ? "" : json['explanation']),
        rate_: (double.tryParse(rateString) ?? 0).round() //().round())
        );
  }
}
