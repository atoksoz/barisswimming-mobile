import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/user-config/user_config_cubit.dart';
import '../constants/url/rta_url_constants.dart';
import '../utils/request_util.dart';
import '../utils/shared-preferences/slider_utils.dart';

class SliderImagesService {
  static Future<void> fetchAndStoreSliderImagesData(
      BuildContext context) async {
    try {
      await context
          .read<ExternalApplicationsConfigCubit>()
          .loadExternalApplicationsConfig();
      await context.read<UserConfigCubit>().loadUserConfig();

      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final userConfig = context.read<UserConfigCubit>().state;

      final rtaBase = externalApplicationConfig?.rta?.trim() ?? '';
      if (rtaBase.isEmpty || userConfig?.firmUuid == null) return;

      final url = RtaUrlService.getMobileSliderUrl(
          rtaBase, userConfig!.firmUuid);

      await clearSliderScreenSliderItems();

      final response = await RequestUtil.get(url);

      if (response?.statusCode == 200) {
        var responseBody = response!.body;
        final Map<String, dynamic> jsonMap = json.decode(responseBody);

        final output = jsonMap['output'];
        if (output == null) return;

        final endTime = output["end_time"] ?? "";
        final waitTime = output["wait_time"] ?? 10;
        final rawItems = output['items'];

        final List<String> urls = [];

        if (rawItems is List) {
          for (var item in rawItems) {
            try {
              final url = item['item_url'];
              if (url is String && url.isNotEmpty) {
                urls.add(url);
              }
            } catch (x) {
              print(x);
            }
          }
        }

        await saveSliderScreenItems(urls, endTime, waitTime);
      }
    } catch (e) {
      print(e);
    }
  }
}
