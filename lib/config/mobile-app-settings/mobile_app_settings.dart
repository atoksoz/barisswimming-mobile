import 'dart:convert';

class MobileAppSettings {
  final String mobileAppVersion; // Deprecated, use mobileAppVersions instead
  final bool allowProfilePhotoUpdate;
  final bool showRoomsAndLockers;
  final bool allowMemberInfoUpdate;
  final bool allowMeasurementCreate;
  final bool hideQrForOverduePayments;
  final String iosAppUrl; // Deprecated, use mobileAppUrls instead
  final String androidAppUrl; // Deprecated, use mobileAppUrls instead
  final bool showKantinProducts;
  final bool showMassagePackageInfo;
  final bool allowSingleDeviceOnly;
  final bool hideQrCodeIfDebtExists;
  final bool isBranchActive;
  final bool isPtActive;
  final bool isBranchLessonActive;
  final bool showGymExxtraShop;
  final Map<String, String> mobileAppVersions; // Platform-based versions: android, ios, harmonyos
  final Map<String, String> mobileAppUrls; // Platform-based URLs: android, ios, harmonyos

  const MobileAppSettings({
    required this.mobileAppVersion,
    required this.allowProfilePhotoUpdate,
    required this.showRoomsAndLockers,
    required this.allowMemberInfoUpdate,
    required this.allowMeasurementCreate,
    required this.hideQrForOverduePayments,
    required this.iosAppUrl,
    required this.androidAppUrl,
    required this.showKantinProducts,
    required this.showMassagePackageInfo,
    required this.allowSingleDeviceOnly,
    required this.hideQrCodeIfDebtExists,
    required this.isBranchActive,
    required this.isPtActive,
    required this.isBranchLessonActive,
    required this.showGymExxtraShop,
    required this.mobileAppVersions,
    required this.mobileAppUrls,
  });

  factory MobileAppSettings.fromOutput(List<dynamic> items) {
    String _stringValue(String key) {
      final item = items.firstWhere(
        (element) => element['key'] == key,
        orElse: () => null,
      );
      if (item == null) return '';
      final value = item['value'];
      return value == null ? '' : value.toString();
    }

    bool _boolValue(String key) {
      final item = items.firstWhere(
        (element) => element['key'] == key,
        orElse: () => null,
      );
      if (item == null) return false;
      final value = item['value'];
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      if (value is num) {
        return value != 0;
      }
      return false;
    }

    Map<String, String> _jsonObjectValue(String key) {
      final item = items.firstWhere(
        (element) => element['key'] == key,
        orElse: () => null,
      );
      if (item == null) {
        print('_jsonObjectValue: Item not found for key: $key');
        return {};
      }
      final value = item['value'];
      print('_jsonObjectValue: Key=$key, Value type=${value.runtimeType}, Value=$value');
      
      if (value is Map) {
        print('_jsonObjectValue: Value is already a Map');
        final result = Map<String, String>.from(
          value.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
        );
        print('_jsonObjectValue: Parsed result=$result');
        return result;
      }
      // If value is String, try to parse as JSON
      if (value is String && value.isNotEmpty) {
        print('_jsonObjectValue: Value is String, attempting JSON decode');
        try {
          final decoded = json.decode(value);
          if (decoded is Map) {
            final result = Map<String, String>.from(
              decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
            );
            print('_jsonObjectValue: JSON decoded result=$result');
            return result;
          }
        } catch (e) {
          print('_jsonObjectValue: JSON decode error: $e');
        }
      }
      print('_jsonObjectValue: Returning empty map');
      return {};
    }

    // Get platform-based versions
    final versionsMap = _jsonObjectValue('mobile_app_versions');
    // Get platform-based URLs
    final urlsMap = _jsonObjectValue('mobile_app_urls');
    
    // For backward compatibility, get single values
    final legacyVersion = _stringValue('mobile_app_version');
    final legacyIosUrl = _stringValue('ios_app_url');
    final legacyAndroidUrl = _stringValue('android_app_url');

    return MobileAppSettings(
      mobileAppVersion: legacyVersion,
      allowProfilePhotoUpdate: _boolValue('allow_profile_photo_update'),
      showRoomsAndLockers: _boolValue('show_rooms_and_lockers'),
      allowMemberInfoUpdate: _boolValue('allow_member_info_update'),
      allowMeasurementCreate: _boolValue('allow_measurement_create'),
      hideQrForOverduePayments: _boolValue('hide_qr_for_overdue_payments'),
      iosAppUrl: legacyIosUrl,
      androidAppUrl: legacyAndroidUrl,
      showKantinProducts: _boolValue('show_kantin_products'),
      showMassagePackageInfo: _boolValue('show_massage_package_info'),
      allowSingleDeviceOnly: _boolValue('allow_single_device_only'),
      hideQrCodeIfDebtExists: _boolValue('hide_qr_code_if_debt_exists'),
      isBranchActive: _boolValue('is_branch_active'),
      isPtActive: _boolValue('is_pt_active'),
      isBranchLessonActive: _boolValue('is_branch_lesson_active'),
      showGymExxtraShop: _boolValue('show_gym_exxtra_shop'),
      mobileAppVersions: versionsMap.isNotEmpty
          ? versionsMap
          : {
              // Fallback to legacy single version if new format is not available
              'android': legacyVersion.isNotEmpty ? legacyVersion : '',
              'ios': legacyVersion.isNotEmpty ? legacyVersion : '',
              'harmonyos': legacyVersion.isNotEmpty ? legacyVersion : '',
            },
      mobileAppUrls: urlsMap.isNotEmpty
          ? urlsMap
          : {
              // Fallback to legacy URLs if new format is not available
              'android': legacyAndroidUrl,
              'ios': legacyIosUrl,
              'harmonyos': '',
            },
    );
  }

  factory MobileAppSettings.fromJson(Map<String, dynamic> json) {
    // Parse mobileAppVersions
    Map<String, String> versionsMap = {};
    if (json['mobileAppVersions'] != null) {
      if (json['mobileAppVersions'] is Map) {
        versionsMap = Map<String, String>.from(
          (json['mobileAppVersions'] as Map).map(
            (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
          ),
        );
      } else if (json['mobileAppVersions'] is String) {
        try {
          final decoded = jsonDecode(json['mobileAppVersions']);
          if (decoded is Map) {
            versionsMap = Map<String, String>.from(
              decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
            );
          }
        } catch (_) {
          // Ignore parse errors
        }
      }
    }
    
    // Parse mobileAppUrls
    Map<String, String> urlsMap = {};
    if (json['mobileAppUrls'] != null) {
      if (json['mobileAppUrls'] is Map) {
        urlsMap = Map<String, String>.from(
          (json['mobileAppUrls'] as Map).map(
            (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
          ),
        );
      } else if (json['mobileAppUrls'] is String) {
        try {
          final decoded = jsonDecode(json['mobileAppUrls']);
          if (decoded is Map) {
            urlsMap = Map<String, String>.from(
              decoded.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
            );
          }
        } catch (_) {
          // Ignore parse errors
        }
      }
    }

    return MobileAppSettings(
      mobileAppVersion: json['mobileAppVersion'] ?? '',
      allowProfilePhotoUpdate: json['allowProfilePhotoUpdate'] ?? false,
      showRoomsAndLockers: json['showRoomsAndLockers'] ?? false,
      allowMemberInfoUpdate: json['allowMemberInfoUpdate'] ?? false,
      allowMeasurementCreate: json['allowMeasurementCreate'] ?? false,
      hideQrForOverduePayments: json['hideQrForOverduePayments'] ?? false,
      iosAppUrl: json['iosAppUrl'] ?? '',
      androidAppUrl: json['androidAppUrl'] ?? '',
      showKantinProducts: json['showKantinProducts'] ?? false,
      showMassagePackageInfo: json['showMassagePackageInfo'] ?? false,
      allowSingleDeviceOnly: json['allowSingleDeviceOnly'] ?? false,
      hideQrCodeIfDebtExists: json['hideQrCodeIfDebtExists'] ?? false,
      isBranchActive: json['isBranchActive'] ?? false,
      isPtActive: json['isPtActive'] ?? false,
      isBranchLessonActive: json['isBranchLessonActive'] ?? false,
      showGymExxtraShop: json['showGymExxtraShop'] ?? false,
      mobileAppVersions: versionsMap.isNotEmpty
          ? versionsMap
          : {
              'android': json['mobileAppVersion']?.toString() ?? '',
              'ios': json['mobileAppVersion']?.toString() ?? '',
              'harmonyos': json['mobileAppVersion']?.toString() ?? '',
            },
      mobileAppUrls: urlsMap.isNotEmpty
          ? urlsMap
          : {
              'android': json['androidAppUrl']?.toString() ?? '',
              'ios': json['iosAppUrl']?.toString() ?? '',
              'harmonyos': '',
            },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobileAppVersion': mobileAppVersion,
      'allowProfilePhotoUpdate': allowProfilePhotoUpdate,
      'showRoomsAndLockers': showRoomsAndLockers,
      'allowMemberInfoUpdate': allowMemberInfoUpdate,
      'allowMeasurementCreate': allowMeasurementCreate,
      'hideQrForOverduePayments': hideQrForOverduePayments,
      'iosAppUrl': iosAppUrl,
      'androidAppUrl': androidAppUrl,
      'showKantinProducts': showKantinProducts,
      'showMassagePackageInfo': showMassagePackageInfo,
      'allowSingleDeviceOnly': allowSingleDeviceOnly,
      'hideQrCodeIfDebtExists': hideQrCodeIfDebtExists,
      'isBranchActive': isBranchActive,
      'isPtActive': isPtActive,
      'isBranchLessonActive': isBranchLessonActive,
      'showGymExxtraShop': showGymExxtraShop,
      'mobileAppVersions': mobileAppVersions,
      'mobileAppUrls': mobileAppUrls,
    };
  }

  MobileAppSettings copyWith({
    String? mobileAppVersion,
    bool? allowProfilePhotoUpdate,
    bool? showRoomsAndLockers,
    bool? allowMemberInfoUpdate,
    bool? allowMeasurementCreate,
    bool? hideQrForOverduePayments,
    String? iosAppUrl,
    String? androidAppUrl,
    bool? showKantinProducts,
    bool? showMassagePackageInfo,
    bool? allowSingleDeviceOnly,
    bool? hideQrCodeIfDebtExists,
    bool? isBranchActive,
    bool? isPtActive,
    bool? isBranchLessonActive,
    bool? showGymExxtraShop,
    Map<String, String>? mobileAppVersions,
    Map<String, String>? mobileAppUrls,
  }) {
    return MobileAppSettings(
      mobileAppVersion: mobileAppVersion ?? this.mobileAppVersion,
      allowProfilePhotoUpdate:
          allowProfilePhotoUpdate ?? this.allowProfilePhotoUpdate,
      showRoomsAndLockers: showRoomsAndLockers ?? this.showRoomsAndLockers,
      allowMemberInfoUpdate:
          allowMemberInfoUpdate ?? this.allowMemberInfoUpdate,
      allowMeasurementCreate:
          allowMeasurementCreate ?? this.allowMeasurementCreate,
      hideQrForOverduePayments:
          hideQrForOverduePayments ?? this.hideQrForOverduePayments,
      iosAppUrl: iosAppUrl ?? this.iosAppUrl,
      androidAppUrl: androidAppUrl ?? this.androidAppUrl,
      showKantinProducts: showKantinProducts ?? this.showKantinProducts,
      showMassagePackageInfo: showMassagePackageInfo ?? this.showMassagePackageInfo,
      allowSingleDeviceOnly: allowSingleDeviceOnly ?? this.allowSingleDeviceOnly,
      hideQrCodeIfDebtExists: hideQrCodeIfDebtExists ?? this.hideQrCodeIfDebtExists,
      isBranchActive: isBranchActive ?? this.isBranchActive,
      isPtActive: isPtActive ?? this.isPtActive,
      isBranchLessonActive: isBranchLessonActive ?? this.isBranchLessonActive,
      showGymExxtraShop: showGymExxtraShop ?? this.showGymExxtraShop,
      mobileAppVersions: mobileAppVersions ?? this.mobileAppVersions,
      mobileAppUrls: mobileAppUrls ?? this.mobileAppUrls,
    );
  }
}

