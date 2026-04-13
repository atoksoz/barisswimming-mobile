/// Bugünden sonraki ilk takvim günündeki ders şablonu satırları (randevu my-schedule).
class MemberHomeNextLessonSlot {
  final DateTime at;
  final String lessonName;
  final String? teacherName;

  const MemberHomeNextLessonSlot({
    required this.at,
    required this.lessonName,
    this.teacherName,
  });
}

class MemberHomeNextLessonModel {
  final List<MemberHomeNextLessonSlot>? _slots;

  MemberHomeNextLessonModel({required List<MemberHomeNextLessonSlot> slots})
      : _slots = slots;

  /// Eski sürüm / hot reload sonrası bozuk örneklerde null gelebilir; UI çökmez.
  List<MemberHomeNextLessonSlot> get slots =>
      _slots ?? const <MemberHomeNextLessonSlot>[];

  bool get isEmpty => (_slots?.isEmpty ?? true);
}
