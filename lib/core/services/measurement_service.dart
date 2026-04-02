import 'dart:convert';
import 'dart:io';

import 'package:e_sport_life/core/constants/url/gym_training_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/measurement_input_form_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../config/external-applications-config/external_applications_config_cubit.dart';

class MeasurementService {
  static Future<bool> createMeasurement({
    required BuildContext context,
    String? weight,
    String? height,
    String? chest,
    String? arm,
    String? shoulder,
    String? waist,
    List<SelectedAttachment>? attachments,
    int? memberRegisterId,
  }) async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = GymTrainingUrlConstants.getAddMeasurementUrl(
          externalApplicationConfig!.gymTraining);
      final String token = await JwtStorageService.getToken() as String;

      // Prepare fields - only add non-empty values
      Map<String, String> fields = {};

      if (weight != null && weight.trim().isNotEmpty) {
        fields['body_weight'] = weight.trim();
      }
      if (height != null && height.trim().isNotEmpty) {
        fields['size'] = height.trim();
      }
      if (chest != null && chest.trim().isNotEmpty) {
        fields['chest'] = chest.trim();
      }
      if (arm != null && arm.trim().isNotEmpty) {
        fields['arm'] = arm.trim();
      }
      if (shoulder != null && shoulder.trim().isNotEmpty) {
        fields['shoulder'] = shoulder.trim();
      }
      if (waist != null && waist.trim().isNotEmpty) {
        fields['stomach'] = waist.trim();
      }
      if (memberRegisterId != null) {
        fields['member_register_id'] = memberRegisterId.toString();
      }

      // Prepare files
      List<File> files = [];
      if (attachments != null && attachments.isNotEmpty) {
        files = attachments
            .map((attachment) => File(attachment.path))
            .where((file) => file.existsSync())
            .toList();
      }

      http.Response? response;

      if (files.isNotEmpty) {
        // Use multipart if we have files
        response = await RequestUtil.postMultipartWithFields(
          url,
          token: token,
          fields: fields,
          files: files,
          fileFieldName: 'attachment',
          useIndexedFieldNames: true, // attachment_1, attachment_2, etc.
          timeout: const Duration(
              seconds: 300), // 5 dakika timeout (dosya yükleme için)
        );
      } else {
        // Use regular POST if no files
        response = await RequestUtil.post(
          url,
          token: token,
          body: fields,
          timeout: const Duration(seconds: 120),
        );
      }

      if (response == null) {
        print(
            'Create measurement error: Response is null - timeout or connection error');
        return false;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          // API response format'ına göre kontrol edelim
          if (data.containsKey('status') && data['status'] == 200) {
            return true;
          }
          // Alternatif kontrol: output field'ı varsa
          if (data.containsKey('output')) {
            return true;
          }
          print(
              'Create measurement error: Unexpected response format - ${response.body}');
          return false;
        } catch (e) {
          print('Create measurement error: JSON decode error - $e');
          return false;
        }
      }

      print(
          'Create measurement error: Status code ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Create measurement error: Exception - $e');
      return false;
    }
  }

  static Future<bool> deleteMeasurement({
    required BuildContext context,
    required int measurementId,
  }) async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = GymTrainingUrlConstants.getDeleteMeasurementUrl(
          externalApplicationConfig!.gymTraining, measurementId);
      final String token = await JwtStorageService.getToken() as String;

      final response = await RequestUtil.delete(
        url,
        token: token,
        timeout: const Duration(seconds: 30),
      );

      if (response == null) {
        return false;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // API response format'ına göre kontrol edelim
        if (data.containsKey('status') && data['status'] == 200) {
          return true;
        }
        return false;
      }

      return false;
    } catch (e) {
      print('Delete measurement error: $e');
      return false;
    }
  }

  static String? getDeleteErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      if (data.containsKey('messages')) {
        return data['messages']?.toString();
      }
      return null;
    } catch (e) {
      print('Parse error message error: $e');
      return null;
    }
  }
}
