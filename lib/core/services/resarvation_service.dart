import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../data/model/group_lesson_model.dart';
import '../../data/model/group_lesson_resarvation_model.dart';
import '../../data/model/package_model.dart';
import '../constants/url/hamam_spa_url_constants.dart';
import '../constants/url/randevu_al_url_constants.dart';
import '../services/jwt_storage_service.dart';
import '../utils/request_util.dart';

class ResarvationService {
  static Future<PackageModel?> getActiveBranchPackage(BuildContext context, {String? services_id}) async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final extractUrl = HamamSpaUrlConstants.getActiveBranchMemberRegisterUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final List body = json.decode(response.body)["output"];
      final List<PackageModel> packages = 
          body.map((e) => PackageModel.fromJson(e)).toList();

      // Find the first package with remain_quantity > 0
      for (var p in packages) {
        final remain = int.tryParse(p.remain_quantity) ?? 0;
        bool isValid = remain > 0 && p.is_expired == 0;
        
        if (services_id != null) {
          if (isValid && p.product_id == services_id) {
            return p;
          }
        } else if (isValid) {
          return p;
        }
      }
      return null;
    } catch (e) {
      print("Error getting active branch package: $e");
      return null;
    }
  }

  static Future<bool> hasActiveBranchPackage(BuildContext context, {String? services_id}) async {
    final package = await getActiveBranchPackage(context, services_id: services_id);
    return package != null;
  }

  static Future<Map<String, dynamic>> addGroupLessonResarvation(
    BuildContext context, {
    required int service_plan_id,
    required String dayName,
    int? seated_location_id,
    int? member_register_id,
  }) async {
    Map<String, dynamic> result = {};
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl = RandevuAlUrlConstants.getAddResarvationUrl(
          externalApplicationConfig!.onlineReservation);
      final String token = await JwtStorageService.getToken() as String;

      final body = <String, dynamic>{
        "day_name": dayName,
        "service_plan_id": service_plan_id,
      };

      if (seated_location_id != null) {
        body["seated_location_id"] = seated_location_id;
      }

      if (member_register_id != null) {
        body["member_register_id"] = member_register_id;
      }

      var response =
          await RequestUtil.post(resarvationUrl, token: token, body: body);
      result = json.decode(response!.body);
    } catch (e) {
      print(e);
    } finally {
      return result;
    }
  }

  static Future<Map<String, dynamic>> cancelGroupLessonResarvation(
    BuildContext context, {
    required int service_plan_id,
  }) async {
    Map<String, dynamic> result = {};
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.cancelGroupLessonResarvationUrl(
              externalApplicationConfig!.onlineReservation, service_plan_id);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.delete(resarvationUrl, token: token);
      result = json.decode(response!.body);
    } catch (e) {
      print(e);
    } finally {
      return result;
    }
  }

  static Future<List<GroupLessonModel>> fetchGroupLessons(
    BuildContext context, {
    required int dayNumber,
  }) async {
    List<GroupLessonModel> groupLessons = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      // API expects dayNumber + 1 (Monday=1, but API expects Monday=2)
      final apiDayNumber = dayNumber + 1;
      final resarvationUrl = RandevuAlUrlConstants.getGroupLessonByDayNumberUrl(
          externalApplicationConfig!.onlineReservation, apiDayNumber);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.get(resarvationUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      groupLessons = body.map((e) => GroupLessonModel.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      return groupLessons;
    }
  }

  static Future<List<GroupLessonResarvationModel>>
      fetchGroupLessonResarvations(BuildContext context) async {
    List<GroupLessonResarvationModel> resarvations = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final resarvationUrl =
          RandevuAlUrlConstants.getGroupLessonResarvationsUrl(
              externalApplicationConfig!.onlineReservation);
      final String token = await JwtStorageService.getToken() as String;

      var response = await RequestUtil.get(resarvationUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      resarvations =
          body.map((e) => GroupLessonResarvationModel.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      return resarvations;
    }
  }
}

