enum ApplicationType {
  openGym('open_gym'),
  yoga('yoga'),
  pilatesStudio('pilates_studio'),
  pt('pt'),
  muzikOkulum('muzik_okulum'),
  gymnastics('gymnastics'),
  fitnessStudio('fitness_studio'),
  swimmingCourse('swimming_course'),
  hamamSpaMerkezi('hamam_spa_merkezi');

  final String value;
  const ApplicationType(this.value);

  static ApplicationType fromDynamic(dynamic raw) {
    final normalized = (raw ?? '').toString().trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return ApplicationType.openGym;
    }
    for (final type in ApplicationType.values) {
      if (type.value == normalized) {
        return type;
      }
    }
    return ApplicationType.openGym;
  }

  /// Güvenlik kodu / IAM çıktısı veya SharedPreferences'tan gelen kullanıcı haritası için.
  /// `application_type` alanı yoksa veya boşsa kiracı URL'lerinden çıkarım (eski önbellek uyumu).
  static ApplicationType fromUserPayloadMap(Map<String, dynamic> map) {
    final raw = map['application_type'];
    final hasExplicit = raw != null &&
        raw.toString().trim().isNotEmpty &&
        raw.toString().trim().toLowerCase() != 'null';
    if (hasExplicit) {
      return fromDynamic(raw);
    }
    return _inferFromTenantUrls(map) ?? ApplicationType.openGym;
  }

  static ApplicationType? _inferFromTenantUrls(Map<String, dynamic> map) {
    final blob =
        '${map['host'] ?? ''} ${map['api_host'] ?? ''} ${map['hamamspa_api_url'] ?? ''}'
            .toLowerCase();
    if (blob.contains('muzikokulum')) {
      return ApplicationType.muzikOkulum;
    }
    return null;
  }

  bool get isGymLike =>
      this == openGym ||
      this == fitnessStudio ||
      this == yoga ||
      this == pilatesStudio ||
      this == pt ||
      this == gymnastics;

  bool get isMusicSchool => this == muzikOkulum;

  bool get isSwimmingCourse => this == swimmingCourse;

  bool get isHamamSpaMerkezi => this == hamamSpaMerkezi;

  /// Müzik okulu ve yüzme kursu: üç sekmeli üye paneli (Ana sayfa, QR, Profil).
  bool get usesSchoolStyleMemberPanel =>
      isMusicSchool || isSwimmingCourse;
}
