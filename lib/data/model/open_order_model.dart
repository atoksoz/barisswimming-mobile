class OpenOrderModel {
  final int open;
  final int all;
  final String roomName;

  OpenOrderModel({
    required this.open,
    required this.all,
    required this.roomName,
  });

  /// Türetilmiş alan: Doluluk oranı yüzdesi
  int get rate {
    if (all == 0) return 0;
    return ((open / all) * 100).round();
  }

  factory OpenOrderModel.fromJson(Map<String, dynamic> json) {
    return OpenOrderModel(
      open: json['open'] ?? 0,
      all: json['all'] ?? 0,
      roomName: json['room_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'all': all,
      'room_name': roomName,
      'rate': rate,
    };
  }
}
