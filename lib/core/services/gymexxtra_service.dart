import 'dart:convert';

import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/data/model/gymexxtra_order_model.dart';
import 'package:e_sport_life/data/model/gymexxtra_product_model.dart';

class GymexxtraService {
  static String _buildUrl(String baseUrl, String path) {
    String formattedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    String formattedPath = path.startsWith('/') ? path : '/$path';

    // Eğer base URL zaten /api içeriyorsa ve path de /api ile başlıyorsa, mükerrerliği önle
    if (formattedBase.contains('/api') && formattedPath.startsWith('/api/')) {
      formattedPath = formattedPath.substring(4);
    }

    return '$formattedBase$formattedPath';
  }

  static Future<List<GymexxtraProductModel>> fetchProducts({
    required String gymexxtraApiUrl,
    required String token,
  }) async {
    try {
      final cleanToken = token.trim();
      final url = _buildUrl(gymexxtraApiUrl, '/api/v1/products');

      print('Gymexxtra Request: GET $url');
      final response = await RequestUtil.get(url,
          token: cleanToken, secondaryToken: cleanToken);

      if (response != null) {
        print('Gymexxtra Response Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final jsonMap = json.decode(response.body);
          if (jsonMap['status'] == 'SUCCESS' && jsonMap['output'] != null) {
            final List<dynamic> output = jsonMap['output'];
            return output
                .map((item) => GymexxtraProductModel.fromJson(item))
                .toList();
          }
        } else {
          print('Gymexxtra Response Body: ${response.body}');
        }
      }
      return [];
    } catch (e) {
      print('Error fetching Gymexxtra products: $e');
      return [];
    }
  }

  static Future<List<GymexxtraOrderModel>> fetchOrders({
    required String gymexxtraApiUrl,
    required String token,
  }) async {
    try {
      final cleanToken = token.trim();
      final url = _buildUrl(gymexxtraApiUrl, '/api/v1/orders');

      print('Gymexxtra Request: GET $url');
      final response = await RequestUtil.get(url,
          token: cleanToken, secondaryToken: cleanToken);

      if (response != null) {
        print('Gymexxtra Response Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final jsonMap = json.decode(response.body);
          if (jsonMap['status'] == 'SUCCESS' && jsonMap['output'] != null) {
            final List<dynamic> output = jsonMap['output'];
            return output
                .map((item) => GymexxtraOrderModel.fromJson(item))
                .toList();
          }
        } else {
          print('Gymexxtra Response Body: ${response.body}');
        }
      }
      return [];
    } catch (e) {
      print('Error fetching Gymexxtra orders: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addToCart({
    required String gymexxtraApiUrl,
    required String token,
    required int productId,
    String? couponCode,
  }) async {
    try {
      final cleanToken = token.trim();
      final url = _buildUrl(gymexxtraApiUrl, '/api/v1/cart/add');

      print('Gymexxtra Request: POST $url');
      final response = await RequestUtil.post(
        url,
        token: cleanToken,
        secondaryToken: cleanToken,
        body: {
          'product_id': productId,
          if (couponCode != null && couponCode.isNotEmpty)
            'coupon_code': couponCode,
        },
      );

      if (response != null) {
        print('Gymexxtra Response Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final jsonMap = json.decode(response.body);
          if (jsonMap['status'] == 'SUCCESS') {
            final Map<String, dynamic> result = {};
            if (jsonMap['output'] != null && jsonMap['output'] is Map) {
              result.addAll(Map<String, dynamic>.from(jsonMap['output']));
            }
            if (jsonMap['extras'] != null && jsonMap['extras'] is Map) {
              result.addAll(Map<String, dynamic>.from(jsonMap['extras']));
            }
            return result;
          }
        } else {
          print('Gymexxtra Response Body: ${response.body}');
        }
      }
      return null;
    } catch (e) {
      print('Error adding to Gymexxtra cart: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> validateCoupon({
    required String gymexxtraApiUrl,
    required String token,
    required String couponCode,
    int? productId,
    String? draftHash,
  }) async {
    try {
      final cleanToken = token.trim();
      final url = _buildUrl(gymexxtraApiUrl, '/api/v1/coupons/validate');

      print('Gymexxtra Request: POST $url');
      final response = await RequestUtil.post(
        url,
        token: cleanToken,
        secondaryToken: cleanToken,
        body: {
          'coupon_code': couponCode,
          if (productId != null) 'product_id': productId,
          if (draftHash != null) 'draft_hash': draftHash,
        },
      );

      if (response != null) {
        print('Gymexxtra Response Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final jsonMap = json.decode(response.body);
          if (jsonMap['status'] == 'SUCCESS') {
            final Map<String, dynamic> result = {};
            if (jsonMap['output'] != null && jsonMap['output'] is Map) {
              result.addAll(Map<String, dynamic>.from(jsonMap['output']));
            }
            if (jsonMap['extras'] != null && jsonMap['extras'] is Map) {
              result.addAll(Map<String, dynamic>.from(jsonMap['extras']));
            }
            return result;
          }
        } else {
          print('Gymexxtra Response Body: ${response.body}');
        }
      }
      return null;
    } catch (e) {
      print('Error validating Gymexxtra coupon: $e');
      return null;
    }
  }
}
