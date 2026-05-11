import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/payment_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/shared-preferences/member_status_utils.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/member_detail_response_model.dart';
import 'package:e_sport_life/data/model/member_register_chart_model.dart';
import 'package:e_sport_life/screen/panel/common/dynamic_qr_screen.dart';
import 'package:e_sport_life/screen/panel/common/tabs/tabs_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Üye paneli QR ekranı.
/// [DynamicQrScreen] kullanır ve üyeye özel ödeme/üyelik kontrollerini
/// preChecks callback olarak enjekte eder.
class MemberQrScreen extends StatelessWidget {
  const MemberQrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicQrScreen(preChecks: _memberPreChecks);
  }

  static const Duration _timeLimitTimeout = Duration(seconds: 3);

  static Future<bool> _memberPreChecks(BuildContext context) async {
    final appType = context.read<UserConfigCubit>().state?.applicationType;
    if (appType?.usesSchoolStyleMemberPanel == true) {
      // Müzik okulu / yüzme kursu: internet + security code [DynamicQrScreen] içinde.
      // Aktif paket, borç, giriş saati vb. gym iş kuralları uygulanmaz.
      return true;
    }

    final labels = AppLabels.current;
    final mobileAppSettings = context.read<MobileAppSettingsCubit>().state;
    final externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    final String token = await JwtStorageService.getToken() as String;

    // ── Borç / Bakiye (En Yüksek Öncelik) ──

    if (externalConfig != null &&
        externalConfig.apiHamamspaUrl.isNotEmpty) {
      if (mobileAppSettings?.hideQrForOverduePayments == true) {
        if (await PaymentService.checkUnpaidPayments(
            apiHamamspaUrl: externalConfig.apiHamamspaUrl, token: token)) {
          await _showBlockDialog(context, labels.overduePaymentWarning);
          return false;
        }
      }

      if (mobileAppSettings?.hideQrCodeIfDebtExists == true) {
        if (await PaymentService.checkMemberBalance(
            apiHamamspaUrl: externalConfig.apiHamamspaUrl, token: token)) {
          await _showBlockDialog(context, labels.debtExistsWarning);
          return false;
        }
      }
    }

    // ── PT Paketi (Aktifse gym kontrolünü atla) ──

    bool hasActivePt = false;
    if (mobileAppSettings?.isPtActive == true && externalConfig != null) {
      try {
        final response = await RequestUtil.get(
            HamamSpaUrlConstants.getActivePtMemberRegisterUrl(
                externalConfig.hamamspaApiUrl),
            token: token);
        if (response != null && response.statusCode == 200) {
          final List body = jsonDecode(response.body)["output"];
          hasActivePt = body.any((e) =>
              (int.tryParse(e['remain_quantity']?.toString() ?? '0') ?? 0) >
              0);
        }
      } catch (_) {}
    }
    if (hasActivePt) return true;

    // ── Branş Dersi (Aktifse gym kontrolünü atla) ──

    bool hasActiveBranchLesson = false;
    if (mobileAppSettings?.isBranchLessonActive == true &&
        externalConfig != null) {
      try {
        final response = await RequestUtil.get(
            HamamSpaUrlConstants.getActiveBranchMemberRegisterUrl(
                externalConfig.hamamspaApiUrl),
            token: token);
        if (response != null && response.statusCode == 200) {
          final List body = jsonDecode(response.body)["output"];
          hasActiveBranchLesson = body.any((e) =>
              (int.tryParse(e['remain_quantity']?.toString() ?? '0') ?? 0) >
              0);
        }
      } catch (_) {}
    }
    if (hasActiveBranchLesson) return true;

    // ── Gym Üyelik (Dondurulmuş / Süresi Dolmuş) ──

    bool hasActiveGym = false;
    bool isGymFrozen = false;
    if (externalConfig != null) {
      try {
        final dashboardUrl = HamamSpaUrlConstants.getMemberDashboardDataUrl(
            externalConfig.hamamspaApiUrl);
        final response = await RequestUtil.get(dashboardUrl, token: token);
        if (response != null && response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          final memberDetail = MemberDetailResponse.fromJson(json);
          final chartModel = MemberRegisterChartModel.fromRegisterList(
              memberDetail.memberRegisters);
          hasActiveGym = chartModel.remainDays > 0;
          isGymFrozen = chartModel.isGymFrozen;
          await saveGymFrozenStatusToCache(isGymFrozen);
          await saveGymRemainDaysToCache(chartModel.remainDays);
        }
      } catch (e) {
        try {
          isGymFrozen = await loadGymFrozenStatusFromCache();
          hasActiveGym = (await loadGymRemainDaysFromCache()) > 0;
        } catch (_) {}
      }
    }

    if (isGymFrozen) {
      await _showBlockDialog(context, labels.membershipFrozenWarning);
      return false;
    }

    if (!hasActiveGym) {
      await _showBlockDialog(context, labels.noActivePackageWarning);
      return false;
    }

    // ── Zaman Limiti ──

    bool timeLimitOk = false;
    String? timeLimitApiBody;
    try {
      final hamamSpaUrl = HamamSpaUrlConstants.getTimeLimitRightNowUrl(
          externalConfig!.hamamspaApiUrl);
      final response = await RequestUtil.get(hamamSpaUrl,
          token: token, timeout: _timeLimitTimeout);
      timeLimitApiBody = response?.body;
      final Map<String, dynamic> json = jsonDecode(response!.body);
      // API: `output == true` → giriş saati dışı (QR oluşturulamaz);
      // `output == false` → geçiş izni var.
      timeLimitOk = json["output"] != true;
    } catch (e, st) {
      debugPrint(
        'MemberQrScreen time-limit API error: $e\n$st',
      );
    }

    if (!timeLimitOk) {
      debugPrint(
        'MemberQrScreen: giriş saati dışı / time-limit FAIL. '
        'API ham cevap: $timeLimitApiBody',
      );
      await _showBlockDialog(
        context,
        labels.outsideEntryHoursWarning,
        neutralTopGraphic: true,
        replaceStackWithHome: true,
      );
      return false;
    }

    return true;
  }

  static Future<void> _showBlockDialog(
    BuildContext context,
    String message, {
    /// Üstteki hata SVG’si: `false` = dosyadaki renk (kırmızı); `true` = aynı grafik [default500Color] ile boyanır.
    bool neutralTopGraphic = false,
    /// Tamam/Kapat ile tüm navigasyon yığınını sıfırlayıp doğrudan [Tabs] anasayfa (indeks 0).
    bool replaceStackWithHome = false,
  }) async {
    final theme = BlocTheme.theme;
    await warningDialog(
      context,
      message: message,
      buttonColor: theme.defaultRed700Color,
      buttonTextColor: theme.defaultWhiteColor,
      path: theme.errorSvgPath,
      leadingSvgColor:
          neutralTopGraphic ? theme.default500Color : null,
      onPrimaryPressed: () {
        void goHome() {
          if (!context.mounted) return;
          final route = MaterialPageRoute<void>(
            builder: (_) => const Tabs(index: 0),
          );
          if (replaceStackWithHome) {
            Navigator.of(context).pushAndRemoveUntil(route, (_) => false);
          } else {
            Navigator.of(context).push(route);
          }
        }

        if (replaceStackWithHome) {
          WidgetsBinding.instance.addPostFrameCallback((_) => goHome());
        } else {
          goHome();
        }
      },
    );
  }
}
