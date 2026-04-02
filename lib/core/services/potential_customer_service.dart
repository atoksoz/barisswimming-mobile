import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/core/constants/url/potential_customer_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PotentialCustomerService {
  /// Creates a potential customer with reference
  /// Returns true if successful (status CREATED), false otherwise
  /// Throws exception with error message if status is NOT_ACCEPTED or other error
  static Future<bool> createWithReference({
    required BuildContext context,
    required String name,
    required String phone, // Should be in format: +905323929650
    String? email,
    String? birthday, // Should be in format: YYYY-MM-DD
    required int gender, // 0: Erkek, 1: Kadın
  }) async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      if (externalApplicationConfig == null ||
          externalApplicationConfig.potentialCustomer.isEmpty) {
        throw Exception('Potential customer URL is not configured');
      }

      final url = PotentialCustomerUrlConstants.getCreateWithReferenceUrl(
          externalApplicationConfig.potentialCustomer);
      final String token = await JwtStorageService.getToken() as String;

      // Prepare request body
      Map<String, dynamic> body = {
        'name': name,
        'phone': phone, // +905323929650 format
        'gender': gender,
        'source_1': 10,
      };

      // Add optional fields if provided
      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }
      if (birthday != null && birthday.trim().isNotEmpty) {
        body['birthday'] = birthday.trim();
      }

      final response = await RequestUtil.post(
        url,
        token: token,
        body: body,
        timeout: const Duration(seconds: 30),
      );

      if (response == null) {
        throw Exception('İnternet bağlantınızı kontrol edin');
      }
      final data2 = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);

          // Check if status is CREATED (success)
          if (data.containsKey('status') &&
              data.containsKey('payload_status')) {
            final status = data['status'];
            final payloadStatus = data['payload_status'];

            // Status CREATED means success
            if (payloadStatus == 'CREATED' || status == 200) {
              return true;
            }

            // Status NOT_ACCEPTED means error (e.g., user_id not found in token)
            if (payloadStatus == 'NOT_ACCEPTED') {
              String errorMessage = 'Bir hata oluştu';
              if (data.containsKey('extras')) {
                final extras = data['extras'];
                if (extras is Map && extras.containsKey('message')) {
                  errorMessage = extras['message'].toString();
                } else if (extras is String) {
                  errorMessage = extras;
                }
              } else if (data.containsKey('messages')) {
                errorMessage = data['messages'].toString();
              }
              throw Exception(errorMessage);
            }

            // Other error statuses
            String errorMessage = 'Bir hata oluştu';
            if (data.containsKey('extras')) {
              final extras = data['extras'];
              if (extras is Map && extras.containsKey('message')) {
                errorMessage = extras['message'].toString();
              } else if (extras is String) {
                errorMessage = extras;
              }
            } else if (data.containsKey('messages')) {
              errorMessage = data['messages'].toString();
            }
            throw Exception(errorMessage);
          }

          // If no payload_status, check status code
          if (data.containsKey('status') && data['status'] == 200) {
            return true;
          }

          throw Exception('Beklenmeyen bir hata oluştu');
        } catch (e) {
          if (e is Exception) {
            rethrow;
          }
          print('Create potential customer error: JSON decode error - $e');
          throw Exception('Bir hata oluştu');
        }
      }

      // HTTP error status codes
      String errorMessage = 'Bir hata oluştu';
      try {
        final data = jsonDecode(response.body);
        if (data.containsKey('extras')) {
          final extras = data['extras'];
          if (extras is Map && extras.containsKey('message')) {
            errorMessage = extras['message'].toString();
          } else if (extras is String) {
            errorMessage = extras;
          }
        } else if (data.containsKey('messages')) {
          errorMessage = data['messages'].toString();
        }
      } catch (e) {
        // Ignore parse errors, use default message
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      print('Create potential customer error: Exception - $e');
      throw Exception('Bir hata oluştu');
    }
  }
}












