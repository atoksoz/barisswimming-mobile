import 'package:intl/intl.dart';

import 'member_register_model.dart';

class MemberRegisterChartModel {
  final double totalGymRegisterDate;
  final double remainDays;
  final int rate;
  final bool isGymFrozen;

  MemberRegisterChartModel({
    required this.totalGymRegisterDate,
    required this.remainDays,
    required this.isGymFrozen,
    required this.rate,
  });

  static MemberRegisterChartModel fromRegisterList(
      List<MemberRegisterModel> registers) {
    int totalDate = 0;
    DateTime? lastDate;
    bool isFrozen = false;

    final dateFormat = DateFormat('dd-MM-yyyy');

    for (var register in registers) {
      try {
        if (register.packageType == 'GYM') {
          final startDate = dateFormat.parse(register.startDate);
          final endDate = dateFormat.parse(register.endDate);
          final diff = endDate.difference(startDate).inDays;
          totalDate += diff;
          lastDate = endDate;

          // frozen varsa işleme dahil et
          if (register.frozen != null &&
              register.frozenStartDate != null &&
              register.frozenEndDate != null) {
            final frozenStart = dateFormat.parse(register.frozenStartDate!);
            final frozenEnd = dateFormat.parse(register.frozenEndDate!);
            final frozenDiff = frozenEnd.difference(frozenStart).inDays;

            totalDate += frozenDiff;

            if (frozenEnd.isAfter(lastDate)) {
              lastDate = frozenEnd;
            }

            lastDate = lastDate.add(Duration(days: frozenDiff));
            isFrozen = true;
          }
        }
      } catch (e) {
        print("Hata: $e");
      }
    }

    final remain = (lastDate != null)
        ? lastDate.difference(DateTime.now()).inDays.toDouble()
        : 0.0;

    final chartRate = totalDate > 0 
        ? ((remain / totalDate.toDouble()) * 100).round()
        : 0;

    return MemberRegisterChartModel(
        totalGymRegisterDate: totalDate.toDouble(),
        remainDays: remain,
        isGymFrozen: isFrozen,
        rate: chartRate);
  }
}
