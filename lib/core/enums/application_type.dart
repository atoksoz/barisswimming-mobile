enum ApplicationType {
  openGym('open_gym'),
  yoga('yoga'),
  pilatesStudio('pilates_studio'),
  pt('pt'),
  muzikOkulum('muzik_okulum'),
  gymnastics('gymnastics'),
  fitnessStudio('fitness_studio'),
  swimmingCourse('swimming_course');

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

  bool get isGymLike =>
      this == openGym ||
      this == fitnessStudio ||
      this == yoga ||
      this == pilatesStudio ||
      this == pt ||
      this == gymnastics;

  bool get isMusicSchool => this == muzikOkulum;

  bool get isSwimmingCourse => this == swimmingCourse;

  /// Müzik okulu ve yüzme kursu: üç sekmeli üye paneli (Ana sayfa, QR, Profil).
  bool get usesSchoolStyleMemberPanel =>
      isMusicSchool || isSwimmingCourse;
}
