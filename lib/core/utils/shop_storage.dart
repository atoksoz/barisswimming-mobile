import 'package:shared_preferences/shared_preferences.dart';

class ShopStorage {
  static const String _cacheKeyProductId = 'gymexxtra_selected_product_id';
  static const String _cacheKeyCouponCode = 'gymexxtra_coupon_code';
  static const String _cacheKeyTimestamp = 'gymexxtra_cache_timestamp';
  static const int _cacheDuration = 86400000; // 24 saat

  /// Girilen inputlar kaydeder
  static Future<void> saveShopInputs({int? productId, String? couponCode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    if (productId != null) {
      await prefs.setInt(_cacheKeyProductId, productId);
    }
    if (couponCode != null) {
      await prefs.setString(_cacheKeyCouponCode, couponCode);
    }
  }

  /// Kaytl inputlar yAkler
  static Future<Map<String, dynamic>> loadShopInputs() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheKeyTimestamp) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - timestamp < _cacheDuration) {
      return {
        'productId': prefs.getInt(_cacheKeyProductId),
        'couponCode': prefs.getString(_cacheKeyCouponCode),
      };
    } else {
      await clearShopInputs();
      return {};
    }
  }

  /// Cache'i temizler
  static Future<void> clearShopInputs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyProductId);
    await prefs.remove(_cacheKeyCouponCode);
    await prefs.remove(_cacheKeyTimestamp);
  }

  /// Sadece seAili ArAn ID'sini getirir
  static Future<int?> getSelectedProductId() async {
    final inputs = await loadShopInputs();
    return inputs['productId'];
  }
}
