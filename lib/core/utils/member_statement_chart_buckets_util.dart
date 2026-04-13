import 'dart:math' as math;

/// Tek ay için satış (borç) ve tahsilat toplamları.
class StatementChartMonthBucket {
  const StatementChartMonthBucket({
    required this.year,
    required this.month,
    required this.salesTotal,
    required this.collectionsTotal,
  });

  final int year;
  final int month;
  final double salesTotal;
  final double collectionsTotal;

  bool get hasActivity => salesTotal > 0 || collectionsTotal > 0;
}

/// Cari ekstre ham satırlarından aylık grafik kovaları üretir.
class MemberStatementChartBucketsUtil {
  MemberStatementChartBucketsUtil._();

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _itemDate(Map<String, dynamic> item) {
    final type = item['type']?.toString();
    final raw = type == 'sale'
        ? item['register_date']?.toString()
        : item['payment_date']?.toString();
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  static double _saleAmount(Map<String, dynamic> item) {
    if (item['type']?.toString() != 'sale') return 0;
    return _toDouble(item['subscription_price']);
  }

  static double _collectionAmount(Map<String, dynamic> item) {
    if (item['type']?.toString() == 'sale') return 0;
    return _toDouble(item['paid_amount']);
  }

  /// [StatementListScreen] ile aynı bakiye kuralı (satış ekler, tahsilat düşer).
  static double computeListBalance(List<Map<String, dynamic>> items) {
    var total = 0.0;
    for (final item in items) {
      if (item['type']?.toString() == 'sale') {
        total += _saleAmount(item);
      } else {
        total -= _collectionAmount(item);
      }
    }
    return total;
  }

  /// Tüm ekstre satırlarında toplam satış (yalnız `type == sale`, `subscription_price`).
  static double computeTotalSales(List<Map<String, dynamic>> items) {
    var t = 0.0;
    for (final item in items) {
      t += _saleAmount(item);
    }
    return t;
  }

  /// Tüm ekstre satırlarında toplam tahsilat (ödeme satırları, `paid_amount`).
  static double computeTotalCollections(List<Map<String, dynamic>> items) {
    var t = 0.0;
    for (final item in items) {
      t += _collectionAmount(item);
    }
    return t;
  }

  /// [anchor] ayı dahil olmak üzere geriye doğru [monthCount] ayın birinci günleri (eskiden yeniye).
  static List<DateTime> monthStarts({
    required DateTime anchor,
    required int monthCount,
  }) {
    final end = DateTime(anchor.year, anchor.month);
    final out = <DateTime>[];
    var y = end.year;
    var m = end.month;
    for (var i = 0; i < monthCount; i++) {
      out.add(DateTime(y, m));
      m--;
      if (m < 1) {
        m = 12;
        y--;
      }
    }
    return out.reversed.toList();
  }

  /// Son [monthCount] takvim ayı için satış / tahsilat toplamları.
  static List<StatementChartMonthBucket> buildMonthlyBuckets({
    required List<Map<String, dynamic>> items,
    required int monthCount,
    DateTime? now,
  }) {
    final anchor = now ?? DateTime.now();
    final starts = monthStarts(anchor: anchor, monthCount: monthCount);
    int monthKey(int y, int m) => y * 100 + m;
    final sales = <int, double>{};
    final collections = <int, double>{};

    for (final start in starts) {
      final k = monthKey(start.year, start.month);
      sales[k] = 0;
      collections[k] = 0;
    }

    for (final item in items) {
      final d = _itemDate(item);
      if (d == null) continue;
      final k = monthKey(d.year, d.month);
      if (!sales.containsKey(k)) continue;
      sales[k] = (sales[k] ?? 0) + _saleAmount(item);
      collections[k] = (collections[k] ?? 0) + _collectionAmount(item);
    }

    return starts.map((start) {
      final k = monthKey(start.year, start.month);
      return StatementChartMonthBucket(
        year: start.year,
        month: start.month,
        salesTotal: sales[k] ?? 0,
        collectionsTotal: collections[k] ?? 0,
      );
    }).toList();
  }

  static double maxRodValue(List<StatementChartMonthBucket> buckets) {
    var maxV = 0.0;
    for (final b in buckets) {
      maxV = math.max(maxV, b.salesTotal);
      maxV = math.max(maxV, b.collectionsTotal);
    }
    return maxV;
  }
}
