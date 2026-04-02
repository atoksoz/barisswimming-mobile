import 'dart:convert';

import 'package:e_sport_life/core/constants/url/kantincim_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';

class WalletService {
  static Future<double?> getBalance({
    required String kantincimUrl,
    required String token,
  }) async {
    try {
      final url = KantincimUrlConstants.getWalletBalanceUrl(kantincimUrl);
      final response = await RequestUtil.get(url, token: token);

      if (response != null && response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        if (jsonMap['status'] == 200 ||
            jsonMap['status'] == true ||
            jsonMap['status'] == "FOUND") {
          final output = jsonMap['output'];
          if (output != null && output['balance'] != null) {
            return double.tryParse(output['balance'].toString());
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting wallet balance: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getLogs({
    required String kantincimUrl,
    required String token,
    int page = 1,
  }) async {
    try {
      final baseUrl = KantincimUrlConstants.getWalletLogsUrl(kantincimUrl);
      final url = '$baseUrl?page=$page';
      final response = await RequestUtil.get(url, token: token);

      if (response != null && response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        if (jsonMap['status'] == 200 ||
            jsonMap['status'] == true ||
            jsonMap['status'] == "FOUND") {
          return jsonMap['output'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting wallet logs: $e');
      return null;
    }
  }
}
