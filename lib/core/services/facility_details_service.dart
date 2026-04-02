import 'dart:convert';

import '../constants/url/api_hamam_spa_url_constants.dart';
import '../utils/request_util.dart';
import '../utils/response_utils.dart';
import '../../data/model/facility_details_model.dart';
import '../../core/services/jwt_storage_service.dart';

class FacilityDetailsService {
  static Future<FacilityDetailsModel?> getFacilityDetails({
    required String apiHamamspaUrl,
    required String token,
  }) async {
    try {
      final url = ApiHamamSpaUrlConstants.getFacilityDetailsUrl(apiHamamspaUrl);
      
      final response = await RequestUtil.get(url, token: token);
      
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final output = extractOutputIfFound(response.body);
      
      if (output == null) {
        return null;
      }

      return FacilityDetailsModel.fromJson(output);
    } catch (e) {
      print('Facility details service error: $e');
      return null;
    }
  }
}

