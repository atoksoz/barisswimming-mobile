import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/device_uuid_storage_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/email_verification_cache_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/themes/bloc_theme.dart';
import 'package:e_sport_life/screen/panel/common/security-code/security_code_screen.dart';

Future<void> logoutAppDialog(BuildContext context,
    {required String message}) async {
  final String svgPath = BlocTheme.theme.attentionSvgPath;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: BlocTheme.theme.default500Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: BlocTheme.theme.defaultBlackColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            SvgPicture.asset(
              svgPath,
              width: 64,
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BlocTheme.theme.textBody(
                  color: BlocTheme.theme.defaultBlackColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlocTheme.theme.defaultRed700Color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLabels.current.no,
                      style: TextStyle(color: BlocTheme.theme.defaultWhiteColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Evet Butonu
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlocTheme.theme.default500Color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      await JwtStorageService.deleteToken();
                      await DeviceUuidStorageService.deleteDeviceUuid();
                      await EmailVerificationCacheUtils.clearVerificationRequested();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecurityCodeScreen()));
                    },
                    child: Text(
                      AppLabels.current.yes,
                      style: TextStyle(color: BlocTheme.theme.defaultBlackColor),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}
