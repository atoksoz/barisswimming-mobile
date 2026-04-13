import 'dart:convert';
import 'dart:developer' as developer;

import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/member_today_payment_plan_stats_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/schedule_day_of_week_util.dart';

/// Bugün gerçekleşen işlemler — yalnızca bugünkü kayıtlar listelenir.
class MemberTodaySummaryService {
  MemberTodaySummaryService._();

  static const int _attendancePageSize = 50;

  /// Popup satır türleri: [kind] anahtarı.
  static const String kindLesson = 'lesson';
  static const String kindPlannedPayment = 'planned_payment';
  static const String kindPackageSale = 'package_sale';
  static const String kindCollection = 'collection';
  static const String kindAttendance = 'attendance';

  static bool _isSameLocalCalendarDay(String? raw, DateTime now) {
    if (raw == null || raw.isEmpty) return false;
    try {
      final d = DateTime.parse(raw).toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }

  static List<Map<String, dynamic>> _parseStatementsList(ApiResponse result) {
    if (!result.isSuccess) return [];
    final o = result.output;
    if (o is! List) return [];
    return o
        .map((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{};
        })
        .where((m) => m.isNotEmpty)
        .toList();
  }

  static String _lessonDedupeKey(Map<String, dynamic> m) {
    final title = (m['title'] ?? '').toString().trim().toLowerCase();
    final sm = m['sort_minutes'];
    final minutes = sm is int ? sm : int.tryParse(sm?.toString() ?? '') ?? 0;
    return '$title|$minutes';
  }

  static String _enrollmentCardDedupeKey(Map<String, dynamic> e) {
    final name =
        (e['service_plan_name'] ?? '').toString().trim().toLowerCase();
    final time = (e['time'] ?? '').toString().trim();
    return '$name|$time';
  }

  /// Haftalık şablona bugünkü telafi kayıtlarını ekler (yalnızca seçilen gün bugünün `weekday` değeri ise).
  static List<Map<String, dynamic>> mergeScheduleEnrollmentsWithTodayMakeup({
    required List<Map<String, dynamic>> scheduleEnrollments,
    required List<Map<String, dynamic>> todayMakeupEnrollments,
    required int selectedDay,
  }) {
    final base = scheduleEnrollments
        .where((e) =>
            ScheduleDayOfWeekUtil.parseToIsoWeekday(e['day_of_week']) ==
            selectedDay)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final todayDow = DateTime.now().weekday;
    if (selectedDay != todayDow || todayMakeupEnrollments.isEmpty) {
      base.sort(
        (a, b) =>
            (a['time'] ?? '').toString().compareTo((b['time'] ?? '').toString()),
      );
      return base;
    }
    final keys = <String>{for (final e in base) _enrollmentCardDedupeKey(e)};
    final out = [...base];
    for (final m in todayMakeupEnrollments) {
      final row = Map<String, dynamic>.from(m);
      final k = _enrollmentCardDedupeKey(row);
      if (keys.contains(k)) continue;
      keys.add(k);
      out.add(row);
    }
    out.sort(
      (a, b) =>
          (a['time'] ?? '').toString().compareTo((b['time'] ?? '').toString()),
    );
    return out;
  }

  static List<Map<String, dynamic>> _mergeScheduleAndMakeupLessonPopupItems(
    List<Map<String, dynamic>> schedule,
    List<Map<String, dynamic>> makeup,
  ) {
    final keys = <String>{for (final s in schedule) _lessonDedupeKey(s)};
    final out = [...schedule];
    for (final m in makeup) {
      final k = _lessonDedupeKey(m);
      if (keys.contains(k)) continue;
      keys.add(k);
      out.add(m);
    }
    out.sort(
      (a, b) => (a['sort_minutes'] as int).compareTo(b['sort_minutes'] as int),
    );
    return out;
  }

  /// Yoklama raporundan bugünkü telafi satırlarını ders programı kartı biçimine çevirir.
  static List<Map<String, dynamic>> parseTodayMakeupEnrollmentsFromAttendance(
    ApiResponse? att,
    DateTime now,
  ) {
    if (att == null || !att.isSuccess || att.body is! Map<String, dynamic>) {
      return [];
    }
    final body = att.body as Map<String, dynamic>;
    final output = body['output'];
    if (output is! Map<String, dynamic>) return [];
    final details = output['details'] as List<dynamic>? ?? [];
    final out = <Map<String, dynamic>>[];
    for (final e in details) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      if (m['is_cancelled'] == true) continue;
      if (m['is_makeup'] != true) continue;
      final d = (m['date'] ?? '').toString();
      if (!_isSameLocalCalendarDay(d, now)) continue;

      final lessonName = (m['lesson_name'] ?? '-').toString();
      final time = (m['time'] ?? '').toString();
      final emp = (m['employee_name'] ?? '').toString();

      out.add({
        'service_plan_name': lessonName,
        'employee_name': emp,
        'time': time,
        'location_name': null,
        'person_limit': 0,
        'employee_image': null,
        'day_of_week': now.weekday,
        '_is_makeup': true,
      });
    }
    out.sort(
      (a, b) =>
          (a['time'] ?? '').toString().compareTo((b['time'] ?? '').toString()),
    );
    return out;
  }

  static ({
    List<Map<String, dynamic>> attendanceItems,
    List<Map<String, dynamic>> makeupLessonPopupItems,
  }) _parseAttendanceDetails(List<dynamic> details, DateTime now) {
    final attendanceItems = <Map<String, dynamic>>[];
    final makeupLessonPopupItems = <Map<String, dynamic>>[];

    for (final e in details) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      if (m['is_cancelled'] == true) continue;
      final d = (m['date'] ?? '').toString();
      if (!_isSameLocalCalendarDay(d, now)) continue;

      final lessonName = (m['lesson_name'] ?? '-').toString();
      final time = (m['time'] ?? '').toString();
      final emp = (m['employee_name'] ?? '').toString();
      final a = m['attendance'];
      final ai = a is int ? a : int.tryParse(a?.toString() ?? '') ?? 0;
      final isMakeup = m['is_makeup'] == true;

      attendanceItems.add({
        'kind': kindAttendance,
        'sort_minutes': _sortMinutesFromTime(time),
        'title': lessonName,
        'line2': time.isNotEmpty
            ? (emp.isNotEmpty ? '$time · $emp' : time)
            : emp,
        '_attendance': ai,
        '_is_makeup': isMakeup,
      });

      if (isMakeup) {
        final name = lessonName.isNotEmpty ? lessonName : '—';
        makeupLessonPopupItems.add({
          'kind': kindLesson,
          'sort_minutes': _sortMinutesFromTime(time),
          'title': name,
          'line2': emp.isNotEmpty
              ? time.isNotEmpty
                  ? '$time · $emp'
                  : emp
              : time,
          'line3': null,
          '_is_makeup': true,
        });
      }
    }

    return (
      attendanceItems: attendanceItems,
      makeupLessonPopupItems: makeupLessonPopupItems,
    );
  }

  static int _sortMinutesOfItem(Map<String, dynamic> m) {
    final v = m['sort_minutes'];
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 12 * 60;
  }

  static int _sortMinutesFromTime(String? time) {
    if (time == null || time.isEmpty) return 12 * 60;
    final parts = time.trim().split(':');
    if (parts.isEmpty) return 12 * 60;
    final h = int.tryParse(parts[0]) ?? 12;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 60 + m;
  }

  static int _sortMinutesFromPaymentDate(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      return d.hour * 60 + d.minute;
    } catch (_) {
      return 12 * 60;
    }
  }

  static String _formatDisplayDate(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return raw;
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchTodayScheduleLessons(
    String randevuUrl,
  ) async {
    if (randevuUrl.isEmpty) return [];
    try {
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) return [];

      final url = RandevuAlUrlConstants.getMyScheduleUrl(randevuUrl);
      final response = await RequestUtil.get(url, token: token);
      if (response == null) return [];

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final List items = decoded['output'] ?? [];
      final todayDow = DateTime.now().weekday;

      final out = <Map<String, dynamic>>[];
      for (final e in items) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        if (ScheduleDayOfWeekUtil.parseToIsoWeekday(m['day_of_week']) !=
            todayDow) {
          continue;
        }

        final name = (m['service_plan_name'] ?? '').toString();
        final time = (m['time'] ?? '').toString();
        final employee = (m['employee_name'] ?? '').toString();
        final location = (m['location_name'] ?? '').toString();

        out.add({
          'kind': kindLesson,
          'sort_minutes': _sortMinutesFromTime(time),
          'title': name.isNotEmpty ? name : '—',
          'line2': employee.isNotEmpty
              ? time.isNotEmpty
                  ? '$time · $employee'
                  : employee
              : time,
          'line3': location.isNotEmpty ? location : null,
        });
      }
      out.sort(
        (a, b) => (a['sort_minutes'] as int).compareTo(b['sort_minutes'] as int),
      );
      return out;
    } catch (_) {
      return [];
    }
  }

  static String _weekdayLabel(AppLabels labels, int isoWeekday) {
    switch (isoWeekday) {
      case 1:
        return labels.monday;
      case 2:
        return labels.tuesday;
      case 3:
        return labels.wednesday;
      case 4:
        return labels.thursday;
      case 5:
        return labels.friday;
      case 6:
        return labels.saturday;
      case 7:
        return labels.sunday;
      default:
        return '';
    }
  }

  /// Bugünden Pazar’a kadar (özet kartındaki [thisWeekLessonCount] ile aynı kural) şablona bağlı dersler.
  static Future<List<Map<String, dynamic>>> loadThisWeekScheduleLessons({
    required String randevuUrl,
    required AppLabels labels,
  }) async {
    if (randevuUrl.isEmpty) return [];
    try {
      final token = await JwtStorageService.getToken();
      if (token == null || token.isEmpty) return [];

      final url = RandevuAlUrlConstants.getMyScheduleUrl(randevuUrl);
      final response = await RequestUtil.get(url, token: token);
      if (response == null) return [];

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final List items = decoded['output'] ?? [];
      final now = DateTime.now();
      final weekDays = <int>{};
      for (var d = now.weekday; d <= 7; d++) {
        weekDays.add(d);
      }

      final out = <Map<String, dynamic>>[];
      for (final e in items) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final dow = ScheduleDayOfWeekUtil.parseToIsoWeekday(m['day_of_week']);
        if (dow == null || !weekDays.contains(dow)) continue;

        final name = (m['service_plan_name'] ?? '').toString();
        final time = (m['time'] ?? '').toString();
        final employee = (m['employee_name'] ?? '').toString();
        final location = (m['location_name'] ?? '').toString();
        final dayLabel = _weekdayLabel(labels, dow);
        final line2Parts = <String>[dayLabel];
        if (time.isNotEmpty) line2Parts.add(time);
        if (employee.isNotEmpty) line2Parts.add(employee);

        out.add({
          'kind': kindLesson,
          'sort_minutes': dow * 24 * 60 + _sortMinutesFromTime(time),
          'title': name.isNotEmpty ? name : '—',
          'line2': line2Parts.join(' · '),
          'line3': location.isNotEmpty ? location : null,
        });
      }
      out.sort(
        (a, b) => (a['sort_minutes'] as int).compareTo(b['sort_minutes'] as int),
      );
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Yalnızca bugünkü işlemler (liste + sıralama).
  static Future<List<Map<String, dynamic>>> loadTodayOperationItems({
    required String apiUrl,
    required String randevuUrl,
  }) async {
    if (apiUrl.isEmpty) return [];

    try {
      final now = DateTime.now();
      final items = <Map<String, dynamic>>[];

      ApiResponse? statementsRes;
      ApiResponse? attendanceRes;

      await Future.wait([
        RequestUtil.getJson(ApiHamamSpaUrlConstants.getMyStatementsUrl(apiUrl))
            .then((r) {
          statementsRes = r;
        }),
        RequestUtil.getJson(
          ApiHamamSpaUrlConstants.getMyAttendanceReportUrl(
            apiUrl,
            page: 1,
            itemsPerPage: _attendancePageSize,
          ),
        ).then((r) {
          attendanceRes = r;
        }),
      ]);

      final lessonItems = await _fetchTodayScheduleLessons(randevuUrl);

      var attendanceKindItems = <Map<String, dynamic>>[];
      var makeupLessonPopupItems = <Map<String, dynamic>>[];
      final att = attendanceRes;
      if (att != null &&
          att.isSuccess &&
          att.body is Map<String, dynamic>) {
        final body = att.body as Map<String, dynamic>;
        final output = body['output'];
        if (output is Map<String, dynamic>) {
          final details = output['details'] as List<dynamic>? ?? [];
          final parsed = _parseAttendanceDetails(details, now);
          attendanceKindItems = parsed.attendanceItems;
          makeupLessonPopupItems = parsed.makeupLessonPopupItems;
        }
      }

      final mergedLessons = _mergeScheduleAndMakeupLessonPopupItems(
        lessonItems,
        makeupLessonPopupItems,
      );
      items.addAll(mergedLessons);

      final planItems =
          await MemberTodayPaymentPlanStatsService.fetchTodayPlanItems(apiUrl);
      for (final raw in planItems) {
        final pd = MemberTodayPaymentPlanStatsService.paymentDateFromItem(raw);
        final price = raw['payment_price'];
        final amt = price is num
            ? price.toDouble()
            : double.tryParse(price?.toString() ?? '') ?? 0;
        final paid =
            MemberTodayPaymentPlanStatsService.parseIsPaid(raw['is_paid']);
        final expl = (raw['explanation'] ?? '').toString().trim();
        final noTitle = expl.isEmpty ||
            expl == '-' ||
            expl == '—' ||
            expl == '–';
        items.add({
          'kind': kindPlannedPayment,
          'sort_minutes': _sortMinutesFromPaymentDate(pd),
          'title': noTitle ? '' : expl,
          'line2': '${amt.toStringAsFixed(2)} ₺',
          '_paid': paid,
        });
      }

      final stmts = statementsRes != null
          ? _parseStatementsList(statementsRes!)
          : <Map<String, dynamic>>[];
      for (final item in stmts) {
        final t = (item['type'] ?? '').toString();
        if (t == 'sale') {
          final rd = (item['register_date'] ?? '').toString();
          if (!_isSameLocalCalendarDay(rd, now)) continue;
          final packageName = (item['package_name'] ?? '-').toString();
          final sub = (item['subscription_price'] ?? 0);
          final net = sub is num
              ? sub.toDouble()
              : double.tryParse(sub.toString()) ?? 0;
          items.add({
            'kind': kindPackageSale,
            'sort_minutes': _sortMinutesFromPaymentDate(rd),
            'title': packageName,
            'line2': _formatDisplayDate(rd),
            'line3': '${net.toStringAsFixed(2)} ₺',
          });
        } else {
          final pd = (item['payment_date'] ?? '').toString();
          if (!_isSameLocalCalendarDay(pd, now)) continue;
          final paidAmount = item['paid_amount'];
          final amt = paidAmount is num
              ? paidAmount.toDouble()
              : double.tryParse(paidAmount?.toString() ?? '') ?? 0;
          final expl = (item['explanation'] ?? '').toString();
          final ptype = (item['payment_type'] ?? '').toString();
          items.add({
            'kind': kindCollection,
            'sort_minutes': _sortMinutesFromPaymentDate(pd),
            'title': expl.isNotEmpty ? expl : '—',
            'line2': '${amt.toStringAsFixed(2)} ₺',
            'line3': ptype.isNotEmpty ? ptype : null,
          });
        }
      }

      items.addAll(attendanceKindItems);

      items.sort(
        (a, b) =>
            _sortMinutesOfItem(a).compareTo(_sortMinutesOfItem(b)),
      );
      return items;
    } catch (e, st) {
      developer.log(
        'loadTodayOperationItems failed',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }
}
