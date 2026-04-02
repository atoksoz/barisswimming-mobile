enum MobileUserType {
  member('MEMBER'),
  trainer('TRAINER'),
  moderator('MODERATOR'),
  admin('ADMIN');

  final String value;
  const MobileUserType(this.value);

  bool get isPanel => this != member;

  static MobileUserType fromDynamic(dynamic raw) {
    final normalized = (raw ?? '').toString().trim().toUpperCase();
    if (normalized.isEmpty || normalized == 'NULL') {
      return MobileUserType.member;
    }
    for (final type in MobileUserType.values) {
      if (type.value == normalized) {
        return type;
      }
    }
    return MobileUserType.member;
  }
}

