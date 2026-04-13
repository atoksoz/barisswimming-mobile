import 'dart:convert';

import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/member_today_payment_plan_stats_service.dart';
import 'package:e_sport_life/core/utils/member_package_near_expiry_util.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/schedule_day_of_week_util.dart';
import 'package:e_sport_life/data/model/attendance_report_detail_item_model.dart';
import 'package:e_sport_life/data/model/member_home_next_lesson_model.dart';
import 'package:e_sport_life/data/model/member_home_reminder_payment_model.dart';
import 'package:e_sport_life/data/model/member_panel_summary_model.dart';

/// Anasayfa özet kartları için ek metrikler (paralel isteklerle).
class MemberHomeDashboardInsights {
  final MemberPanelSummaryModel panelSummary;
  final int totalRemainQuantity;
  /// Hot reload sonrası eski örneklerde null kalabilir; getter güvenli.
  final int? _rightsTrackedRemain;
  final int? _rightsTrackedTotalQuantity;
  final int overduePaymentCount;
  final int thisWeekLessonCount;
  final MemberHomeNextLessonModel? nextLesson;
  /// Hot reload sonrası eski örneklerde null; her zaman [recentAttendance] getter’ını kullan.
  final List<AttendanceReportDetailItemModel>? _recentAttendance;

  /// Anasayfa özet — son iki yoklama (iptal hariç); `MemberHomeDashboardService.loadInsights`.
  List<AttendanceReportDetailItemModel> get recentAttendance =>
      _recentAttendance ?? const [];

  /// Bitişe yakın veya haklı pakette kalan miktar düşük olan aktif paketler (`MemberPackageNearExpiryUtil` / `NearExpiryPackageConstants`).
  /// Hot reload sonrası eski örneklerde alan null kalabildiği için [nearExpiryPackages] getter kullanılmalı.
  final List<Map<String, dynamic>>? _nearExpiryPackages;

  /// Her zaman null güvenli; hot reload ile oluşmuş eski [MemberHomeDashboardInsights] için boş liste.
  List<Map<String, dynamic>> get nearExpiryPackages =>
      _nearExpiryPackages ?? const [];

  /// Hak sayılı paketler (`quantity > 0`) için Σ `remain_quantity` — donut payı.
  int get rightsTrackedRemain => _rightsTrackedRemain ?? 0;

  /// Hak sayılı paketler için Σ `quantity` — donut paydası.
  int get rightsTrackedTotalQuantity => _rightsTrackedTotalQuantity ?? 0;

  const MemberHomeDashboardInsights({
    required this.panelSummary,
    required this.totalRemainQuantity,
    int? rightsTrackedRemain,
    int? rightsTrackedTotalQuantity,
    required this.overduePaymentCount,
    required this.thisWeekLessonCount,
    this.nextLesson,
    List<AttendanceReportDetailItemModel>? recentAttendance,
    List<Map<String, dynamic>>? nearExpiryPackages,
  })  : _rightsTrackedRemain = rightsTrackedRemain,
        _rightsTrackedTotalQuantity = rightsTrackedTotalQuantity,
        _nearExpiryPackages = nearExpiryPackages,
        _recentAttendance = recentAttendance;

  static MemberHomeDashboardInsights empty() => const MemberHomeDashboardInsights(
        panelSummary: MemberPanelSummaryModel.zero,
        totalRemainQuantity: 0,
        rightsTrackedRemain: 0,
        rightsTrackedTotalQuantity: 0,
        overduePaymentCount: 0,
        thisWeekLessonCount: 0,
        nextLesson: null,
        nearExpiryPackages: [],
      );
}

/// Consolidated dashboard — api-system + randevu tek çağrı.
class MemberHomeFullDashboard {
  final MemberHomeDashboardInsights insights;
  final List<MemberHomeReminderPaymentModel> reminderPayments;

  /// Birleşik endpoint'ten gelen cari ekstre verileri.
  /// Fallback durumunda `null` — chart card kendi isteğini yapar.
  final double? statementTotalDebit;
  final double? statementTotalCredit;
  final double? statementBalance;
  final List<Map<String, dynamic>>? statementRecentItems;

  final int todayLessonCount;
  final int todayUnpaidPaymentCount;

  const MemberHomeFullDashboard({
    required this.insights,
    required this.reminderPayments,
    this.statementTotalDebit,
    this.statementTotalCredit,
    this.statementBalance,
    this.statementRecentItems,
    required this.todayLessonCount,
    required this.todayUnpaidPaymentCount,
  });

  static MemberHomeFullDashboard empty() => const MemberHomeFullDashboard(
        insights: MemberHomeDashboardInsights(
          panelSummary: MemberPanelSummaryModel.zero,
          totalRemainQuantity: 0,
          rightsTrackedRemain: 0,
          rightsTrackedTotalQuantity: 0,
          overduePaymentCount: 0,
          thisWeekLessonCount: 0,
          nearExpiryPackages: [],
        ),
        reminderPayments: [],
        todayLessonCount: 0,
        todayUnpaidPaymentCount: 0,
      );
}

class MemberHomeDashboardService {
  MemberHomeDashboardService._();

  static const int _pageSize = 20;
  static const int _homeSummaryAttendanceCount = 2;
  static const int _homeSummaryAttendanceFetchSize = 20;

  static Future<T> _guard<T>(Future<T> Function() fn, T fallback) async {
    try {
      return await fn();
    } catch (_) {
      return fallback;
    }
  }

  static Future<MemberPanelSummaryModel> _fetchPanelSummary(String apiUrl) async {
    final r = await RequestUtil.getJson(
      ApiHamamSpaUrlConstants.getMyPanelSummaryUrl(apiUrl),
    );
    if (!r.isSuccess || r.body is! Map<String, dynamic>) {
      return MemberPanelSummaryModel.zero;
    }
    final out = r.output;
    if (out is! Map<String, dynamic>) return MemberPanelSummaryModel.zero;
    return MemberPanelSummaryModel.fromJson(out);
  }

  static int _coerceInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString().trim()) ?? 0;
  }

  /// API alanı farklı isimlerle gelebilir; null değer atlanır, sıradaki anahtar denenir.
  static int _pickInt(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (!m.containsKey(k)) continue;
      final v = m[k];
      if (v == null) continue;
      return _coerceInt(v);
    }
    return 0;
  }

  /// Aktif paketler: özet için tüm kalan hak toplamı; donut için
  /// `quantity > 0` ise Σ kalan / Σ quantity; aksi halde kalan > 0 ise
  /// (toplam bilinmiyor) payda olarak kalan eklenir — grafik dolu kalır.
  static Future<
      ({
        int totalRemainAllActive,
        int rightsRemain,
        int rightsTotalQuantity,
        List<Map<String, dynamic>> nearExpiryPackages,
      })> _aggregateActivePackageRights(String apiUrl) async {
    var page = 1;
    var lastPage = 1;
    var sumRemainAll = 0;
    var rightsRemain = 0;
    var rightsTotalQuantity = 0;
    final nearExpiry = <Map<String, dynamic>>[];
    do {
      final r = await RequestUtil.getJson(
        ApiHamamSpaUrlConstants.getMyPackagesUrl(
          apiUrl,
          page: page,
          itemsPerPage: _pageSize,
        ),
      );
      if (!r.isSuccess || r.body is! Map<String, dynamic>) break;
      final body = r.body as Map<String, dynamic>;
      lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(body);
      final pageItems =
          MemberTodayPaymentPlanStatsService.extractPageItems(body);
      for (final m in pageItems) {
        if (!MemberPackageNearExpiryUtil.isActiveByEndDate(m)) continue;
        if (MemberPackageNearExpiryUtil.isNearExpiry(m)) {
          nearExpiry.add(Map<String, dynamic>.from(m));
        }
        final rem = _pickInt(m, [
          'remain_quantity',
          'remainQuantity',
          'remaining_qty',
          'remainingQty',
        ]);
        sumRemainAll += rem;
        final q = _pickInt(m, [
          'quantity',
          'qty',
          'total_quantity',
          'totalQuantity',
        ]);
        if (q > 0) {
          rightsRemain += rem;
          rightsTotalQuantity += q;
        } else if (rem > 0) {
          rightsRemain += rem;
          rightsTotalQuantity += rem;
        }
      }
      page++;
    } while (page <= lastPage &&
        page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);
    nearExpiry.sort((a, b) {
      final da = MemberPackageNearExpiryUtil.calendarDaysUntilEnd(a);
      final db = MemberPackageNearExpiryUtil.calendarDaysUntilEnd(b);
      if (da != null && db != null && da != db) return da.compareTo(db);
      if (da != null && db == null) return -1;
      if (da == null && db != null) return 1;
      return MemberPackageNearExpiryUtil.pickRemain(a) -
          MemberPackageNearExpiryUtil.pickRemain(b);
    });

    return (
      totalRemainAllActive: sumRemainAll,
      rightsRemain: rightsRemain,
      rightsTotalQuantity: rightsTotalQuantity,
      nearExpiryPackages: nearExpiry,
    );
  }

  static Future<int> _countOverduePayments(String apiUrl) async {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    var count = 0;
    var page = 1;
    var lastPage = 1;
    do {
      final r = await RequestUtil.getJson(
        ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(
          apiUrl,
          page: page,
          itemsPerPage: _pageSize,
        ),
      );
      if (!r.isSuccess || r.body is! Map<String, dynamic>) break;
      final body = r.body as Map<String, dynamic>;
      final newItems = MemberTodayPaymentPlanStatsService.extractPageItems(body);
      lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(body);
      for (final item in newItems) {
        if (MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid'])) {
          continue;
        }
        final pd = MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
        if (pd.isEmpty) continue;
        try {
          final d = DateTime.parse(pd).toLocal();
          if (d.isBefore(startToday)) count++;
        } catch (_) {}
      }
      page++;
    } while (page <= lastPage &&
        page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);
    return count;
  }

  static DateTime _nextOccurrenceDateTime(
    int dayOfWeek,
    String timeStr,
    DateTime from,
  ) {
    final parts = timeStr.trim().split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final min = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final fromMidnight = DateTime(from.year, from.month, from.day);
    final deltaDays = (dayOfWeek - from.weekday + 7) % 7;
    final targetDay = fromMidnight.add(Duration(days: deltaDays));
    var candidate =
        DateTime(targetDay.year, targetDay.month, targetDay.day, h, min);
    if (deltaDays == 0 && !candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }

  /// Bugün hariç: yarın ve sonrası için ilk takvim günündeki tüm şablona uygun oturumlar.
  static MemberHomeNextLessonModel? _nextCalendarDayLessons(
    List<Map<String, dynamic>> enrollments,
    DateTime now,
  ) {
    if (enrollments.isEmpty) return null;
    final startAfterToday =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    final occurrences = <({Map<String, dynamic> e, DateTime at})>[];
    for (final e in enrollments) {
      final dow = ScheduleDayOfWeekUtil.parseToIsoWeekday(e['day_of_week']);
      if (dow == null) continue;
      final timeStr = (e['time'] ?? '').toString();
      final at = _nextOccurrenceDateTime(dow, timeStr, startAfterToday);
      occurrences.add((e: e, at: at));
    }
    if (occurrences.isEmpty) return null;

    occurrences.sort((a, b) => a.at.compareTo(b.at));
    final first = occurrences.first.at;
    final y = first.year;
    final m = first.month;
    final d = first.day;

    final slots = <MemberHomeNextLessonSlot>[];
    for (final o in occurrences) {
      final t = o.at;
      if (t.year != y || t.month != m || t.day != d) continue;
      final name = (o.e['service_plan_name'] ?? '').toString().trim();
      final emp = (o.e['employee_name'] ?? '').toString().trim();
      slots.add(
        MemberHomeNextLessonSlot(
          at: o.at,
          lessonName: name.isNotEmpty ? name : '—',
          teacherName: emp.isNotEmpty ? emp : null,
        ),
      );
    }
    slots.sort((a, b) => a.at.compareTo(b.at));
    if (slots.isEmpty) return null;
    return MemberHomeNextLessonModel(slots: slots);
  }

  static Future<({int weekCount, MemberHomeNextLessonModel? next})>
      _scheduleInsights(String randevuUrl) async {
    if (randevuUrl.isEmpty) {
      return (weekCount: 0, next: null);
    }
    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty) {
      return (weekCount: 0, next: null);
    }
    final url = RandevuAlUrlConstants.getMyScheduleUrl(randevuUrl);
    final response = await RequestUtil.get(url, token: token);
    if (response == null) return (weekCount: 0, next: null);
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final List raw = decoded['output'] ?? [];
    final enrollments = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map) enrollments.add(Map<String, dynamic>.from(e));
    }

    final now = DateTime.now();
    final weekDays = <int>{};
    for (var d = now.weekday; d <= 7; d++) {
      weekDays.add(d);
    }

    var weekCount = 0;
    for (final e in enrollments) {
      final dow = ScheduleDayOfWeekUtil.parseToIsoWeekday(e['day_of_week']);
      if (dow != null && weekDays.contains(dow)) {
        weekCount++;
      }
    }

    final next = _nextCalendarDayLessons(enrollments, now);

    return (weekCount: weekCount, next: next);
  }

  static Future<List<AttendanceReportDetailItemModel>> _fetchRecentAttendance(
    String apiUrl,
  ) async {
    if (apiUrl.isEmpty) return [];
    final r = await RequestUtil.getJson(
      ApiHamamSpaUrlConstants.getMyAttendanceReportUrl(
        apiUrl,
        page: 1,
        itemsPerPage: _homeSummaryAttendanceFetchSize,
      ),
    );
    if (!r.isSuccess || r.body is! Map<String, dynamic>) return [];
    final body = r.body as Map<String, dynamic>;
    final output = body['output'];
    if (output is! Map<String, dynamic>) return [];
    final rawDetails = output['details'] as List<dynamic>? ?? [];
    final items = <AttendanceReportDetailItemModel>[];
    for (final e in rawDetails) {
      if (e is! Map) continue;
      final m = AttendanceReportDetailItemModel.fromJson(
        Map<String, dynamic>.from(e),
      );
      if (!m.isCancelled) items.add(m);
    }
    items.sort(AttendanceReportDetailItemModel.compareByPlanDateTimeDesc);
    if (items.length <= _homeSummaryAttendanceCount) return items;
    return items.sublist(0, _homeSummaryAttendanceCount);
  }

  static Future<MemberHomeDashboardInsights> loadInsights({
    required String apiUrl,
    required String randevuUrl,
  }) async {
    if (apiUrl.isEmpty) return MemberHomeDashboardInsights.empty();

    final r = await Future.wait<Object?>([
      _guard(() => _fetchPanelSummary(apiUrl), MemberPanelSummaryModel.zero),
      _guard(
        () => _aggregateActivePackageRights(apiUrl),
        (
          totalRemainAllActive: 0,
          rightsRemain: 0,
          rightsTotalQuantity: 0,
          nearExpiryPackages: <Map<String, dynamic>>[],
        ),
      ),
      _guard(() => _countOverduePayments(apiUrl), 0),
      _guard(
        () => _scheduleInsights(randevuUrl),
        (weekCount: 0, next: null),
      ),
      _guard(
        () => _fetchRecentAttendance(apiUrl),
        <AttendanceReportDetailItemModel>[],
      ),
    ]);

    final panel = r[0]! as MemberPanelSummaryModel;
    final rights = r[1]! as ({
      int totalRemainAllActive,
      int rightsRemain,
      int rightsTotalQuantity,
      List<Map<String, dynamic>> nearExpiryPackages,
    });
    final overdue = r[2]! as int;
    final sched =
        r[3]! as ({int weekCount, MemberHomeNextLessonModel? next});
    final recent = r[4]! as List<AttendanceReportDetailItemModel>;

    return MemberHomeDashboardInsights(
      panelSummary: panel,
      totalRemainQuantity: rights.totalRemainAllActive,
      rightsTrackedRemain: rights.rightsRemain,
      rightsTrackedTotalQuantity: rights.rightsTotalQuantity,
      overduePaymentCount: overdue,
      thisWeekLessonCount: sched.weekCount,
      nextLesson: sched.next,
      recentAttendance: recent,
      nearExpiryPackages: rights.nearExpiryPackages,
    );
  }

  // ─── Consolidated dashboard (yeni birleşik endpoint'ler) ───

  static const Duration _consolidatedTimeout = Duration(seconds: 30);

  /// İki birleşik endpoint (api-system + randevu) ile TÜM anasayfa verisini tek seferde yükler.
  /// Başarısız olursa eski çoklu endpoint yaklaşımına düşer (fallback).
  static Future<MemberHomeFullDashboard> loadFullDashboard({
    required String apiUrl,
    required String randevuUrl,
  }) async {
    if (apiUrl.isEmpty) return MemberHomeFullDashboard.empty();

    try {
      final results = await Future.wait<ApiResponse>([
        RequestUtil.getJson(
          ApiHamamSpaUrlConstants.getMyMuzikOkulumHomeDashboardUrl(apiUrl),
        ),
        _fetchRandevuDashboardResponse(randevuUrl),
      ]).timeout(_consolidatedTimeout);

      final apiDash = results[0];
      final randevuDash = results[1];

      if (apiDash.isSuccess && apiDash.output is Map<String, dynamic>) {
        final apiOutput = apiDash.output as Map<String, dynamic>;
        final randevuOutput =
            randevuDash.isSuccess && randevuDash.output is Map<String, dynamic>
                ? randevuDash.output as Map<String, dynamic>
                : null;
        return _parseConsolidatedDashboard(apiOutput, randevuOutput);
      }
    } catch (_) {}

    return _loadFullDashboardLegacy(apiUrl: apiUrl, randevuUrl: randevuUrl);
  }

  static Future<ApiResponse> _fetchRandevuDashboardResponse(
    String randevuUrl,
  ) async {
    if (randevuUrl.isEmpty) {
      return const ApiResponse(statusCode: 0, body: null, isSuccess: false);
    }
    return RequestUtil.getJson(
      RandevuAlUrlConstants.getMyMuzikOkulumHomeDashboardUrl(randevuUrl),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static MemberHomeFullDashboard _parseConsolidatedDashboard(
    Map<String, dynamic> api,
    Map<String, dynamic>? randevu,
  ) {
    // ── panel_summary ──
    final panelRaw = api['panel_summary'];
    final panelSummary = panelRaw is Map<String, dynamic>
        ? MemberPanelSummaryModel.fromJson(panelRaw)
        : MemberPanelSummaryModel.zero;

    // ── packages ──
    final pkgRaw = api['packages'];
    final pkg = pkgRaw is Map<String, dynamic> ? pkgRaw : <String, dynamic>{};
    final totalQuantity = _coerceInt(pkg['total_quantity']);
    final totalRemaining = _coerceInt(pkg['total_remaining']);
    final nearExpiryCount = _coerceInt(pkg['near_expiry_count']);
    final nearExpiryPlaceholders = nearExpiryCount > 0
        ? List<Map<String, dynamic>>.generate(
            nearExpiryCount, (_) => <String, dynamic>{})
        : const <Map<String, dynamic>>[];

    // ── payment_plans ──
    final ppRaw = api['payment_plans'];
    final pp = ppRaw is Map<String, dynamic> ? ppRaw : <String, dynamic>{};
    final overdueCount = _coerceInt(pp['overdue_count']);
    final todayItems = _safeListOfMaps(pp['today_items']);
    final reminderRawItems = _safeListOfMaps(pp['reminder_items']);
    final reminderPayments = _parseReminderPayments(reminderRawItems);

    // ── statements ──
    final stRaw = api['statements'];
    final st = stRaw is Map<String, dynamic> ? stRaw : <String, dynamic>{};
    final totalDebit = _toDouble(st['total_debit']);
    final totalCredit = _toDouble(st['total_credit']);
    final balance = _toDouble(st['balance']);
    final recentStatementItems = _safeListOfMaps(st['recent_items']);

    // ── attendance ──
    final attRaw = api['attendance'];
    final att = attRaw is Map<String, dynamic> ? attRaw : <String, dynamic>{};
    final attRecentRaw = att['recent_items'];
    final recentAttendance = _parseRecentAttendance(attRecentRaw);

    // ── randevu: schedule + today_lesson_count ──
    final scheduleRaw = randevu?['schedule'];
    final enrollments = _safeListOfMaps(scheduleRaw);
    final schedInsights = _computeScheduleInsights(enrollments);
    final todayLessonCount = _coerceInt(randevu?['today_lesson_count']);

    final insights = MemberHomeDashboardInsights(
      panelSummary: panelSummary,
      totalRemainQuantity: totalRemaining,
      rightsTrackedRemain: totalRemaining,
      rightsTrackedTotalQuantity: totalQuantity,
      overduePaymentCount: overdueCount,
      thisWeekLessonCount: schedInsights.weekCount,
      nextLesson: schedInsights.next,
      recentAttendance: recentAttendance,
      nearExpiryPackages: nearExpiryPlaceholders,
    );

    return MemberHomeFullDashboard(
      insights: insights,
      reminderPayments: reminderPayments,
      statementTotalDebit: totalDebit,
      statementTotalCredit: totalCredit,
      statementBalance: balance,
      statementRecentItems: recentStatementItems,
      todayLessonCount: todayLessonCount,
      todayUnpaidPaymentCount: todayItems.length,
    );
  }

  static List<Map<String, dynamic>> _safeListOfMaps(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<MemberHomeReminderPaymentModel> _parseReminderPayments(
    List<Map<String, dynamic>> items,
  ) {
    final out = <MemberHomeReminderPaymentModel>[];
    for (final item in items) {
      final idRaw = item['id'];
      final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
      final amount = _toDouble(item['amount']);
      final dateRaw = (item['payment_date'] ?? '').toString();
      DateTime? date;
      try {
        date = DateTime.parse(dateRaw).toLocal();
      } catch (_) {
        continue;
      }
      out.add(MemberHomeReminderPaymentModel(
        id: id,
        amount: amount,
        paymentDateLocal: date,
        explanation: (item['explanation'] ?? '').toString(),
      ));
    }
    out.sort((a, b) => a.paymentDateLocal.compareTo(b.paymentDateLocal));
    return out;
  }

  static List<AttendanceReportDetailItemModel> _parseRecentAttendance(
    dynamic raw,
  ) {
    if (raw is! List) return const [];
    final items = <AttendanceReportDetailItemModel>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = AttendanceReportDetailItemModel.fromJson(
        Map<String, dynamic>.from(e),
      );
      if (!m.isCancelled) items.add(m);
    }
    items.sort(AttendanceReportDetailItemModel.compareByPlanDateTimeDesc);
    return items.length <= _homeSummaryAttendanceCount
        ? items
        : items.sublist(0, _homeSummaryAttendanceCount);
  }

  static ({int weekCount, MemberHomeNextLessonModel? next})
      _computeScheduleInsights(List<Map<String, dynamic>> enrollments) {
    final now = DateTime.now();
    final weekDays = <int>{};
    for (var d = now.weekday; d <= 7; d++) {
      weekDays.add(d);
    }
    var weekCount = 0;
    for (final e in enrollments) {
      final dow = ScheduleDayOfWeekUtil.parseToIsoWeekday(e['day_of_week']);
      if (dow != null && weekDays.contains(dow)) weekCount++;
    }
    final next = _nextCalendarDayLessons(enrollments, now);
    return (weekCount: weekCount, next: next);
  }

  /// Fallback: eski çoklu endpoint yaklaşımı.
  static Future<MemberHomeFullDashboard> _loadFullDashboardLegacy({
    required String apiUrl,
    required String randevuUrl,
  }) async {
    final insights = await loadInsights(apiUrl: apiUrl, randevuUrl: randevuUrl);
    List<MemberHomeReminderPaymentModel> reminders = const [];
    try {
      reminders = await _fetchLegacyReminders(apiUrl);
    } catch (_) {}
    return MemberHomeFullDashboard(
      insights: insights,
      reminderPayments: reminders,
      todayLessonCount: 0,
      todayUnpaidPaymentCount: 0,
    );
  }

  static Future<List<MemberHomeReminderPaymentModel>> _fetchLegacyReminders(
    String apiUrl,
  ) async {
    if (apiUrl.isEmpty) return const [];
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final endInclusive = startToday.add(const Duration(days: 10));
    final out = <MemberHomeReminderPaymentModel>[];
    var page = 1;
    var lastPage = 1;
    do {
      final r = await RequestUtil.getJson(
        ApiHamamSpaUrlConstants.getMyPaymentPlansUrl(apiUrl,
            page: page, itemsPerPage: 20),
      );
      if (!r.isSuccess || r.body is! Map<String, dynamic>) break;
      final body = r.body as Map<String, dynamic>;
      lastPage = MemberTodayPaymentPlanStatsService.extractLastPage(body);
      for (final item
          in MemberTodayPaymentPlanStatsService.extractPageItems(body)) {
        if (MemberTodayPaymentPlanStatsService.parseIsPaid(item['is_paid'])) {
          continue;
        }
        final pd =
            MemberTodayPaymentPlanStatsService.paymentDateFromItem(item);
        if (pd.isEmpty) continue;
        DateTime? d;
        try {
          d = DateTime.parse(pd).toLocal();
        } catch (_) {
          continue;
        }
        final day = DateTime(d.year, d.month, d.day);
        if (day.isBefore(startToday) || day.isAfter(endInclusive)) continue;
        final idRaw = item['id'];
        out.add(MemberHomeReminderPaymentModel(
          id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? ''),
          amount: _toDouble(item['payment_price'] ?? item['amount']),
          paymentDateLocal: d,
          explanation: (item['explanation'] ?? '').toString(),
        ));
      }
      page++;
    } while (page <= lastPage &&
        page <= MemberTodayPaymentPlanStatsService.paginationSafetyCap);
    out.sort((a, b) => a.paymentDateLocal.compareTo(b.paymentDateLocal));
    return out;
  }
}
