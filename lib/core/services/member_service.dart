import 'dart:convert';

import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/response_utils.dart';

class MemberService {
  static Future<Map<String, dynamic>?> updateMemberInfo({
    required String apiHamamSpaUrl,
    required String token,
    required String name,
    required int gender,
    required String birthday,
  }) async {
    try {
      final url = HamamSpaUrlConstants.getUpdateMemberInfoUrl(apiHamamSpaUrl);
      final response = await RequestUtil.post(
        url,
        token: token,
        body: {
          'name': name,
          'gender': gender,
          'birthday': birthday,
        },
      );

      if (response != null && response.statusCode == 200) {
        try {
          final jsonMap = json.decode(response.body);
          print('Update member info response: ${response.body}');
          
          // Check if messages is 'UPDATED' or status is 200
          if (jsonMap['messages'] == 'UPDATED' || 
              (jsonMap['status'] == 200 && jsonMap['messages'] == 'UPDATED')) {
            // Return the output if available
            Map<String, dynamic> result = {};
            
            if (jsonMap['output'] != null) {
              final output = jsonMap['output'];
              if (output is Map<String, dynamic>) {
                result = Map<String, dynamic>.from(output);
              }
            }
            
            print('Update member info successful, returning: $result');
            return result;
          }
          
          // Fallback: Try extractOutputIfFound
          final output = extractOutputIfFound(response.body);
          if (output != null) {
            final jsonMapCheck = json.decode(response.body);
            if (jsonMapCheck['messages'] == 'UPDATED') {
              return output;
            }
          }
        } catch (e) {
          print('Error parsing update member info response: $e');
          print('Response body: ${response.body}');
        }
      } else if (response != null) {
        // Handle error responses
        try {
          final jsonMap = json.decode(response.body);
          print('Update member info error: ${jsonMap['messages']}');
        } catch (e) {
          print('Error parsing error response: $e');
        }
      }
      print('Update member info failed, returning null');
      return null;
    } catch (e) {
      print('Error updating member info: $e');
      return null;
    }
  }
}

