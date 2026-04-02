import 'dart:convert';
import 'dart:io';

import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/response_utils.dart';
import 'package:http/http.dart' as http;

class ProfilePhotoService {
  static Future<Map<String, String>?> updateProfilePhoto({
    required String apiHamamSpaUrl,
    required String token,
    required File imageFile,
  }) async {
    try {
      final url = HamamSpaUrlConstants.getUpdateProfilePhotoUrl(apiHamamSpaUrl);
      final response = await RequestUtil.postMultipart(
        url,
        file: imageFile,
        token: token,
        fieldName: 'file',
      );

      if (response != null && response.statusCode == 200) {
        final output = extractOutputIfFound(response.body);
        if (output != null) {
          return {
            'image_url': output['image_url'] ?? '',
            'thumb_image_url': output['thumb_image_url'] ?? '',
          };
        }
      } else if (response != null) {
        // Handle error responses
        try {
          final jsonMap = json.decode(response.body);
          print('Profile photo update error: ${jsonMap['messages']}');
        } catch (e) {
          print('Error parsing error response: $e');
        }
      }
      return null;
    } catch (e) {
      print('Error updating profile photo: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> deleteProfilePhoto({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    try {
      final url = HamamSpaUrlConstants.getDeleteProfilePhotoUrl(apiHamamSpaUrl);
      final response = await RequestUtil.post(
        url,
        token: token,
        body: const {},
      );

      if (response != null && response.statusCode == 200) {
        try {
          final jsonMap = json.decode(response.body);
          print('Delete response: ${response.body}');
          
          // Check if messages is 'DELETED' or status is 200
          if (jsonMap['messages'] == 'DELETED' || 
              (jsonMap['status'] == 200 && jsonMap['messages'] == 'DELETED')) {
            // If output exists, use it; otherwise return empty strings
            Map<String, dynamic> result = {
              'image_url': '',
              'thumb_image_url': '',
            };
            
            if (jsonMap['output'] != null) {
              final output = jsonMap['output'];
              if (output is Map<String, dynamic>) {
                result['image_url'] = output['image_url']?.toString() ?? '';
                result['thumb_image_url'] = output['thumb_image_url']?.toString() ?? '';
              }
            }
            
            print('Delete successful, returning: $result');
            return result;
          }
          
          // Fallback: Try extractOutputIfFound
          final output = extractOutputIfFound(response.body);
          if (output != null) {
            final jsonMapCheck = json.decode(response.body);
            if (jsonMapCheck['messages'] == 'DELETED') {
              return <String, dynamic>{
                'image_url': output['image_url']?.toString() ?? '',
                'thumb_image_url': output['thumb_image_url']?.toString() ?? '',
              };
            }
          }
        } catch (e) {
          print('Error parsing delete response: $e');
          print('Response body: ${response.body}');
        }
      } else if (response != null) {
        // Handle error responses
        try {
          final jsonMap = json.decode(response.body);
          print('Profile photo delete error: ${jsonMap['messages']}');
        } catch (e) {
          print('Error parsing error response: $e');
        }
      }
      print('Delete failed, returning null');
      return null;
    } catch (e) {
      print('Error deleting profile photo: $e');
      return null;
    }
  }
}

