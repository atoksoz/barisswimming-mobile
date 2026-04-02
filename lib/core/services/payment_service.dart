import 'dart:convert';

import '../constants/url/hamam_spa_url_constants.dart';
import '../utils/request_util.dart';

class PaymentService {
  /// Checks if member has unpaid/overdue payments
  /// Returns true if there are unpaid payments, false otherwise
  static Future<bool> checkUnpaidPayments({
    required String apiHamamspaUrl,
    required String token,
  }) async {
    try {
      if (apiHamamspaUrl.isEmpty) {
        return false;
      }

      final url = HamamSpaUrlConstants.getUnpaidPaymentPlanUrl(apiHamamspaUrl);
      var response = await RequestUtil.get(url, token: token);
      
      if (response == null) {
        return false;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final output = json["output"];

      if (output is List) {
        return output.length > 0;
      }

      return false;
    } catch (e) {
      print("Unpaid payments check error: $e");
      return false;
    }
  }

  /// Checks if member has debt (balance > 0)
  /// Returns true if balance > 0, false otherwise
  static Future<bool> checkMemberBalance({
    required String apiHamamspaUrl,
    required String token,
  }) async {
    try {
      if (apiHamamspaUrl.isEmpty) {
        return false;
      }

      final url = HamamSpaUrlConstants.getMemberBalanceUrl(apiHamamspaUrl);
      var response = await RequestUtil.get(url, token: token);
      
      if (response == null) {
        return false;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final output = json["output"];

      if (output is Map<String, dynamic>) {
        final balance = output["balance"];
        if (balance is num) {
          return balance > 0;
        }
      }

      return false;
    } catch (e) {
      print("Member balance check error: $e");
      return false;
    }
  }
}

