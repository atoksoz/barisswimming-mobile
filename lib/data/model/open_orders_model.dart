class OpenOrdersModel {
  final int open;
  final int all;
  final int rate;

  OpenOrdersModel({
    required this.open,
    required this.all,
    required this.rate,
  });

  factory OpenOrdersModel.fromJson(Map<String, dynamic> json) {
    final open =
        json['open'] != null ? int.tryParse(json['open'].toString()) ?? 0 : 0;

    final all = json['all'] != null
        ? int.tryParse(json['all'].toString()) ??
            1 // sıfıra bölme hatası için 1
        : 1;

    // open veya all 0 ise rate 0 olsun
    final rate = (open > 0 && all > 0) ? ((open / all) * 100).round() : 0;

    return OpenOrdersModel(
      open: open,
      all: all,
      rate: rate,
    );
  }
}
