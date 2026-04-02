import 'package:intl/intl.dart';

extension DateTimeFormatExtension on String {
  /// [inputFormatStr]: gelen string'in formatı
  /// [outputFormatStr]: dönüştürülecek format, default: 'dd/MM/yyyy HH:mm'
  String toFormattedDateTime({
    String inputFormatStr = "HH:mm:ss dd-MM-yyyy",
    String outputFormatStr = "dd/MM/yyyy HH:mm",
  }) {
    try {
      final inputFormat = DateFormat(inputFormatStr);
      final outputFormat = DateFormat(outputFormatStr);
      final dateTime = inputFormat.parse(this);
      return outputFormat.format(dateTime);
    } catch (e) {
      print("Tarih dönüşüm hatası: $e");
      return this; // Hatalıysa orijinal metni döndür
    }
  }
}
