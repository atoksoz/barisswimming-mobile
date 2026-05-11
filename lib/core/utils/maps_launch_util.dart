import 'dart:io' show Platform;

import 'package:e_sport_life/data/model/randevu_v2_group_lesson_location_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// Harita bağlantılarını mümkünse **Safari yerine Haritalar / Harita uygulamasında** açar.
///
/// - Koordinat varsa: iOS → `maps.apple.com`, Android → `geo:` şeması.
/// - Yalnızca [RandevuV2GroupLessonLocationModel.address] (koordinat/maps URL yok):
///   iOS → Apple Haritalar `q=`; Android → `geo:0,0?q=` ile seçici.
/// - Yalnızca Google Maps web URL’si: iOS’ta önce `comgooglemaps://` (kuruluysa),
///   sonra `externalNonBrowserApplication`, son çare tarayıcı.
final class MapsLaunchUtil {
  MapsLaunchUtil._();

  static Future<void> openSwimmingPoolLocation(
    RandevuV2GroupLessonLocationModel pool,
  ) async {
    final label = pool.displayLabel;

    final lat = pool.latitude;
    final lng = pool.longitude;
    if (lat != null || lng != null) {
      final native = _nativeUriForCoordinates(
        latitude: lat,
        longitude: lng,
        label: label,
      );
      if (native != null && await canLaunchUrl(native)) {
        await launchUrl(native, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!kIsWeb && Platform.isIOS) {
      final a = pool.address?.trim();
      if (a != null &&
          a.isNotEmpty &&
          lat == null &&
          lng == null) {
        final m = pool.mapsUrl?.trim();
        if (m == null || m.isEmpty) {
          final u = Uri.http('maps.apple.com', '/', <String, String>{'q': a});
          if (await canLaunchUrl(u)) {
            await launchUrl(u, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      final a = pool.address?.trim();
      if (a != null &&
          a.isNotEmpty &&
          lat == null &&
          lng == null) {
        final m = pool.mapsUrl?.trim();
        if (m == null || m.isEmpty) {
          final u =
              Uri.parse('geo:0,0?q=${Uri.encodeComponent(a)}');
          if (await canLaunchUrl(u)) {
            await launchUrl(u, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
    }

    final fallback = pool.mapsLaunchUri;
    if (fallback == null) return;
    final uri = Uri.tryParse(fallback);
    if (uri == null) return;

    await _launchHttpMapsUrlPreferNativeApp(uri);
  }

  /// iOS: Apple Haritalar; Android: `geo:` — Safari/Chrome’a düşmeden.
  static Uri? _nativeUriForCoordinates({
    required double? latitude,
    required double? longitude,
    required String label,
  }) {
    if (kIsWeb) return null;

    if (Platform.isIOS) {
      if (latitude != null && longitude != null) {
        return Uri.http('maps.apple.com', '/', <String, String>{
          'll': '$latitude,$longitude',
          'q': label,
        });
      }
      final q = latitude?.toString() ?? longitude!.toString();
      return Uri.http('maps.apple.com', '/', <String, String>{'q': q});
    }

    if (Platform.isAndroid) {
      if (latitude != null && longitude != null) {
        return Uri.parse(
          'geo:$latitude,$longitude?q=${Uri.encodeComponent(label)}',
        );
      }
      final q = latitude?.toString() ?? longitude!.toString();
      return Uri.parse('geo:0,0?q=${Uri.encodeComponent(q)}');
    }

    return null;
  }

  static Future<void> _launchHttpMapsUrlPreferNativeApp(Uri uri) async {
    if (kIsWeb) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (Platform.isIOS) {
      final googleApp = _tryIosGoogleMapsAppScheme(uri);
      if (googleApp != null && await canLaunchUrl(googleApp)) {
        await launchUrl(googleApp, mode: LaunchMode.externalApplication);
        return;
      }

      var launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    if (Platform.isAndroid) {
      final geo = _tryAndroidGeoFromGoogleStyleUri(uri);
      if (geo != null && await canLaunchUrl(geo)) {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
        return;
      }
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// `https://maps.google...` → `comgooglemaps://?q=...` (parametre çıkarılabiliyorsa).
  static Uri? _tryIosGoogleMapsAppScheme(Uri web) {
    final host = web.host.toLowerCase();
    final looksLikeGoogleMaps = host.contains('google.') ||
        host.contains('goo.gl') ||
        host.contains('maps.app');
    if (!looksLikeGoogleMaps) return null;

    String? q = web.queryParameters['q'];
    q ??= web.queryParameters['query'];
    if (q != null && q.trim().isNotEmpty) {
      return Uri.parse('comgooglemaps://?q=${Uri.encodeComponent(q.trim())}');
    }

    final daddr = web.queryParameters['daddr'];
    if (daddr != null && daddr.trim().isNotEmpty) {
      return Uri.parse(
        'comgooglemaps://?daddr=${Uri.encodeComponent(daddr.trim())}',
      );
    }

    return null;
  }

  /// Android: URL içinden `q` veya `query` ile koordinat/metin çıkarıp `geo:` dene.
  static Uri? _tryAndroidGeoFromGoogleStyleUri(Uri web) {
    final host = web.host.toLowerCase();
    if (!host.contains('google') && !host.contains('goo.gl')) {
      return null;
    }
    final q = web.queryParameters['q'] ?? web.queryParameters['query'];
    if (q == null || q.trim().isEmpty) return null;
    final t = q.trim();
    final comma = RegExp(r'^[-\d.]+,\s*[-\d.]+$');
    if (comma.hasMatch(t)) {
      final parts = t.split(',');
      if (parts.length == 2) {
        final la = double.tryParse(parts[0].trim());
        final lo = double.tryParse(parts[1].trim());
        if (la != null && lo != null) {
          return Uri.parse('geo:$la,$lo');
        }
      }
    }
    return Uri.parse('geo:0,0?q=${Uri.encodeComponent(t)}');
  }
}
