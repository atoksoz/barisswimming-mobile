import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

/// Bugün vadesi gelen planlı ödemelerin özeti (ödenen / toplam).
class MemberTodayPaymentPlanStats {
  final int totalToday;
  final int paidToday;

  const MemberTodayPaymentPlanStats({
    required this.totalToday,
    required this.paidToday,
  });
}

/// Panel özeti API'sindeki `today_payment_count` yalnızca bekleyen ödemeleri sayabildiği için
/// rozet burada tüm sayfalar üzerinden hesaplanır ([payment_date] yerel günü = bugün).
class MemberTodayPaymentPlanStatsService {
  MemberTodayPaymentPlanStatsService._();

  static const int _itemsPerPage = 20;

  /// Anasayfa / özet için çok sayfalı tarama üst sınırı (uzun süren spinner önlenir).
  static const int paginationSafetyCap = 50;

  /// API bazen `true`, bazen `1` döndürebilir.
  static bool parseIsPaid(dynamic value) {
    if (value == true) return true;
    if (value == 1 || value == '1') return true;
    return false;
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, v) => MapEntry(key.toString(), v));
    }
    return null;
  }

  /// Laravel paginator kökte veya `output` içinde dönebilir.
  static List<Map<String, dynamic>> extractPageItems(Map<String, dynamic> body) {
    dynamic list = body['data'];
    if (list is! List) {
      final output = _asStringKeyedMap(body['output']);
      if (output != null) {
        list = output['data'];
      }
    }
    if (list is! List) return [];

    return list
        .map((e) => _asStringKeyedMap(e) ?? <String, dynamic>{})
        .toList();
  }

  static int extractLastPage(Map<String, dynamic> body) {
    dynamic lp = body['last_page'];
    if (lp is int) return lp;
    if (lp != null) return int.tryParse(lp.toString()) ?? 1;

    final output = _asStringKeyedMap(body['output']);
    if (output != null) {
      lp = output['last_page'];
      if (lp is int) return lp;
      if (lp != null) return int.tryParse(lp.toString()) ?? 1;
    }
    return 1;
  }

  /// Model: `payment_date` — bazı resource yanıtlarında `planned_date`.
  static String paymentDateFromItem(Map<String, dynamic> item) {
    final raw = item['payment_date'] ?? item['planned_date'];
    return raw?.toString() ?? '';
  }

  static bool isPaymentDateToday(String paymentDateRaw) {
    if (paymentDateRaw.isEmpty) return false;
    try {
      final d = DateTime.parse(paymentDateRaw).toLocal();
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }

  static Future<MemberTodayPaymentPlanStats> fetch(String apiUrl) async {
    if (apiUrl.isEmpty) {
      return const MemberTodayPaymentPlanStats(totalToday: 0, paidToday: 0);
    }

    var totalToday = 0;
    var paidToday = 0;
    var page = 1;
    var lastPage = 1;

    try {
      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: _itemsPerPage,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final body = result.body as Map<String, dynamic>;
        final newItems = extractPageItems(body);
        lastPage = extractLastPage(body);

        for (final item in newItems) {
          final pd = paymentDateFromItem(item);
          if (!isPaymentDateToday(pd)) continue;
          totalToday++;
          if (parseIsPaid(item['is_paid'])) {
            paidToday++;
          }
        }

        page++;
      } while (page <= lastPage && page <= paginationSafetyCap);
    } catch (_) {}

    return MemberTodayPaymentPlanStats(
      totalToday: totalToday,
      paidToday: paidToday,
    );
  }

  /// Bugün vadesi gelen planlı ödeme satırları (özet popup listesi).
  static Future<List<Map<String, dynamic>>> fetchTodayPlanItems(
      String apiUrl) async {
    if (apiUrl.isEmpty) return [];

    final out = <Map<String, dynamic>>[];
    var page = 1;
    var lastPage = 1;

    try {
      do {
        final url = ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: _itemsPerPage,
        );
        final result = await RequestUtil.getJson(url);

        if (!result.isSuccess || result.body is! Map<String, dynamic>) {
          break;
        }

        final body = result.body as Map<String, dynamic>;
        final newItems = extractPageItems(body);
        lastPage = extractLastPage(body);

        for (final item in newItems) {
          final pd = paymentDateFromItem(item);
          if (!isPaymentDateToday(pd)) continue;
          out.add(Map<String, dynamic>.from(item));
        }

        page++;
      } while (page <= lastPage && page <= paginationSafetyCap);
    } catch (_) {}

    return out;
  }
}
