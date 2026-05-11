/// Randevu `GroupLessonLocationListResource` — üye `GET …/v2/me/pool-locations`,
/// eğitmen `GET …/v2/me/group-lesson-locations`.
class RandevuV2GroupLessonLocationModel {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? mapsUrl;
  final String? address;

  const RandevuV2GroupLessonLocationModel({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    this.address,
  });

  /// API `name` boşsa bile seçicide metin gösterilsin.
  String get displayLabel => name.isNotEmpty ? name : '#$id';

  /// Harici harita uygulaması için URL.
  ///
  /// Öncelik: dolu [mapsUrl] → açılır. Değilse koordinat veya [address] ile arama.
  String? get mapsLaunchUri {
    final raw = mapsUrl?.trim();
    if (raw != null && raw.isNotEmpty) {
      final lower = raw.toLowerCase();
      if (lower.startsWith('http://') ||
          lower.startsWith('https://') ||
          lower.startsWith('geo:')) {
        return raw;
      }
      return 'https://$raw';
    }
    final q = _coordsSearchQuery;
    if (q != null) {
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}';
    }
    final addr = address?.trim();
    if (addr != null && addr.isNotEmpty) {
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}';
    }
    return null;
  }

  /// Koordinat satırı: ikisi de varsa `lat,lng`; yalnız biri varsa tek değer.
  String? get _coordsSearchQuery {
    final lat = latitude;
    final lng = longitude;
    if (lat == null && lng == null) return null;
    if (lat != null && lng != null) return '$lat,$lng';
    if (lat != null) return lat.toString();
    return lng!.toString();
  }

  factory RandevuV2GroupLessonLocationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final name = (json['name'] ?? json['title'] ?? json['label'] ?? '')
        .toString()
        .trim();
    return RandevuV2GroupLessonLocationModel(
      id: id,
      name: name,
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      mapsUrl: _parseNullableString(
        json['maps_url'] ?? json['mapsUrl'] ?? json['map_url'],
      ),
      address: _parseNullableString(json['address']),
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String? _parseNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
