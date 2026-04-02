import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/response_utils.dart';
import 'package:e_sport_life/data/model/announcement_model.dart';

class AnnouncementService {
  /// En son duyuruyu getir
  static Future<AnnouncementModel?> fetchLatestAnnouncement({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    try {
      final url = ApiHamamSpaUrlConstants.getAnnouncementsLatestUrl(apiHamamSpaUrl);
      final response = await RequestUtil.get(url, token: token);
      
      if (response != null && response.statusCode == 200) {
        final output = extractOutputIfFound(response.body);
        if (output != null) {
          return AnnouncementModel.fromJson(output);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching latest announcement: $e');
      return null;
    }
  }

  /// Tüm duyuruları getir
  static Future<List<AnnouncementModel>> fetchAllAnnouncements({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    try {
      final url = ApiHamamSpaUrlConstants.getAnnouncementsIndexUrl(apiHamamSpaUrl);
      final response = await RequestUtil.get(url, token: token);
      
      if (response != null && response.statusCode == 200) {
        final outputList = extractOutputListIfFound(response.body);
        if (outputList != null) {
          return AnnouncementModel.fromJsonList(outputList);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  /// Belirli bir duyuruyu getir
  static Future<AnnouncementModel?> fetchAnnouncementById({
    required String apiHamamSpaUrl,
    required String token,
    required int announcementId,
  }) async {
    try {
      final url = ApiHamamSpaUrlConstants.getAnnouncementsShowUrl(
        apiHamamSpaUrl,
        announcementId,
      );
      final response = await RequestUtil.get(url, token: token);
      
      if (response != null && response.statusCode == 200) {
        final output = extractOutputIfFound(response.body);
        if (output != null) {
          return AnnouncementModel.fromJson(output);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching announcement by id: $e');
      return null;
    }
  }
}

