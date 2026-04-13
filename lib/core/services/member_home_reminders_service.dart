import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/services/member_today_payment_plan_stats_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/member_home_reminder_payment_model.dart';

/// Anasayfa hatırlatıcıları — ödeme: yalnızca bugünden itibaren [upcomingWindowDays] gün içinde
/// vadesi gelen ödenmemiş planlar (gecikenler özette; burada gösterilmez).
class MemberHomeRemindersService {
  MemberHomeRemindersService._();

  static const int upcomingWindowDays = 10;

  static int? _parseId(Map<String, dynamic> item) {
    final raw = item['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  static double _parseAmount(Map<String, dynamic> item) {
    final raw = item['payment_price'] ?? item['amount'];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String _explanation(Map<String, dynamic> item) {
    return (item['explanation'] ?? item['description'] ?? '').toString();
  }

  /// Vade tarihi [startToday, startToday + upcomingWindowDays] (takvim günü, her iki uç dahil).
  static Future<List<MemberHomeReminderPaymentModel>> fetchPaymentReminders(
    String apiUrl,
  ) async {
    if (apiUrl.isEmpty) return [];

    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final endInclusive = startToday.add(Duration(days: upcomingWindowDays));

    final upcoming = <MemberHomeReminderPaymentModel>[];

    var page = 1;
    var lastPage = 1;

    try {
      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: 20,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final body = result.body as Map<String, dynamic>;
        final newItems = MemberTodayPaymentPlanStatsService.extractPageItems(body);
        lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(body);

        for (final item in newItems) {
          if (MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid'])) {
            continue;
          }
          final pdRaw =
              MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
          if (pdRaw.isEmpty) continue;

          DateTime? d;
          try {
            d = DateTime.parse(pdRaw).toLocal();
          } catch (_) {
            continue;
          }

          final day = DateTime(d.year, d.month, d.day);
          if (day.isBefore(startToday)) continue;
          if (day.isAfter(endInclusive)) continue;

          upcoming.add(
            MemberHomeReminderPaymentModel(
              id: _parseId(item),
              amount: _parseAmount(item),
              paymentDateLocal: d,
              explanation: _explanation(item),
            ),
          );
        }

        page++;
      } while (page <= lastPage &&
          page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);
    } catch (_) {}

    upcoming.sort(
      (a, b) => a.paymentDateLocal.compareTo(b.paymentDateLocal),
    );

    return upcoming;
  }
}
