import 'package:intl/intl.dart';

import 'package:e_sport_life/core/constants/member_register_constants.dart';

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

  Map<String, dynamic> toJson() => {
        'total_gym_register_date': totalGymRegisterDate,
        'remain_days': remainDays,
        'rate': rate,
        'is_gym_frozen': isGymFrozen,
      };

  /// Hamam / api-system birden fazla `member_register` döndürebilir (bitmiş + aktif).
  /// Donut ve «kalan gün» yalnızca **takvim olarak aktif** GYM paketinden hesaplanır;
  /// birden fazla aktif varsa **bitiş tarihi en geç** olan seçilir.
  static MemberRegisterChartModel fromRegisterList(
      List<MemberRegisterModel> registers) {
    final dateFormat =
        DateFormat(MemberRegisterConstants.apiDatePatternDdMmYyyy);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    MemberRegisterModel? bestReg;
    DateTime? bestStartDay;
    DateTime? bestEndDay;

    for (final register in registers) {
      if (register.packageType != MemberRegisterConstants.packageTypeGym) {
        continue;
      }
      try {
        final start = dateFormat.parse(register.startDate);
        final end = dateFormat.parse(register.endDate);
        final startDay = DateTime(start.year, start.month, start.day);
        final endDay = DateTime(end.year, end.month, end.day);

        final isActive =
            !startDay.isAfter(today) && !endDay.isBefore(today);
        if (!isActive) continue;

        if (bestEndDay == null || endDay.isAfter(bestEndDay)) {
          bestEndDay = endDay;
          bestStartDay = startDay;
          bestReg = register;
        }
      } catch (_) {
        continue;
      }
    }

    if (bestReg == null || bestStartDay == null || bestEndDay == null) {
      return MemberRegisterChartModel(
        totalGymRegisterDate: 0,
        remainDays: 0,
        isGymFrozen: false,
        rate: 0,
      );
    }

    var totalDays = bestEndDay.difference(bestStartDay).inDays;
    var isCurrentlyFrozen = false;

    final reg = bestReg;
    // Toplam / donut süresi yalnız paket başlangıç–bitiş; dondurulan günler eklenmez.
    // «Şu an donduruldu» için frozen tarihleri kullanılır (bugün aralıkta mı).
    if (reg.frozenStartDate != null && reg.frozenEndDate != null) {
      try {
        final frozenStart = dateFormat.parse(reg.frozenStartDate!);
        final frozenEnd = dateFormat.parse(reg.frozenEndDate!);
        final frozenStartDay =
            DateTime(frozenStart.year, frozenStart.month, frozenStart.day);
        final frozenEndDay =
            DateTime(frozenEnd.year, frozenEnd.month, frozenEnd.day);

        final inFreezeWindow = !today.isBefore(frozenStartDay) &&
            !today.isAfter(frozenEndDay);
        final explicitNotFrozen = reg.frozen == '0' ||
            reg.frozen == false ||
            reg.frozen == 0;
        isCurrentlyFrozen = inFreezeWindow && !explicitNotFrozen;
      } catch (_) {
        // Dondurma tarihleri parse edilemezse uyarı bayrağı güncellenmez.
      }
    }

    final remainRaw = bestEndDay.difference(today).inDays.toDouble();
    final remain =
        remainRaw < 0 ? 0.0 : remainRaw;

    final chartRate = totalDays > 0
        ? ((remain / totalDays) *
                MemberRegisterConstants.chartRatePercentMax)
            .round()
            .clamp(0, MemberRegisterConstants.chartRatePercentMax)
        : 0;

    return MemberRegisterChartModel(
      totalGymRegisterDate: totalDays.toDouble(),
      remainDays: remain,
      isGymFrozen: isCurrentlyFrozen,
      rate: chartRate,
    );
  }
}
