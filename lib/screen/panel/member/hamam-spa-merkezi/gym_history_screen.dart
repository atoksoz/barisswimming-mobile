import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/extensions/conditional_text_decoration_extension.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/core/extensions/format_datetime_extension.dart';
import 'package:e_sport_life/core/constants/member_register_constants.dart';
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/member_register_file_model.dart';
import 'package:e_sport_life/data/model/package_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GymPackageHistory extends StatefulWidget {
  const GymPackageHistory({super.key});

  @override
  State<GymPackageHistory> createState() => _GymPackageHistoryState();
}

class _GymPackageHistoryState extends State<GymPackageHistory> {
  static const _fileTypeContract = 'contract';
  static const _fileTypeRequestForm = 'request_form';

  Future<List<PackageModel>> fetchGymPackageData() async {
    var packageModel = <PackageModel>[];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getGymMemberRegisterUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      final response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      packageModel = body.map((e) => PackageModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GymPackageHistory fetch error: $e');
      }
    }

    return packageModel;
  }

  TextStyle _bodyBoldStrike(int expired) =>
      BlocTheme.theme.textBodyBold(color: BlocTheme.theme.default900Color).copyWith(
            decoration: expired.decorationLineThrough,
          );

  TextStyle _bodyStrike(int expired) =>
      BlocTheme.theme.textBody(color: BlocTheme.theme.default900Color).copyWith(
            decoration: expired.decorationLineThrough,
          );

  TextStyle _smallSubStrike(int expired) =>
      BlocTheme.theme.textSmall(color: BlocTheme.theme.defaultSubColor).copyWith(
            decoration: expired.decorationLineThrough,
          );

  @override
  Widget build(BuildContext context) {
    final future = fetchGymPackageData();

    return Scaffold(
      appBar: TopAppBarWidget(
        title: AppLabels.current.subscriptionInfo,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<PackageModel>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                }
                final data = snapshot.data;
                if (snapshot.hasData && data != null && data.isNotEmpty) {
                  return buildPosts(data);
                }
                return const Center(child: NoDataTextWidget());
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<PackageModel> packageModel) {
    final labels = AppLabels.current;
    final theme = BlocTheme.theme;

    return ListView.builder(
      itemCount: packageModel.length,
      itemBuilder: (context, index) {
        final data = packageModel[index];
        final expired = data.is_expired;
        final cardGapHalf = theme.panelCardSpacing / 2;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: theme.panelListCardShadowSpread,
                blurRadius: theme.panelListCardShadowBlur,
                offset: Offset(0, theme.panelListCardShadowOffsetY),
                color: theme.defaultBlackColor
                    .withValues(alpha: theme.panelListCardShadowOpacity),
              ),
            ],
            color: theme.panelCardBackground,
            border: Border.all(color: theme.panelCardBorder),
            borderRadius: BorderRadius.circular(theme.panelLargeRadius),
          ),
          margin: EdgeInsets.fromLTRB(
            theme.panelPagePadding.left,
            cardGapHalf,
            theme.panelPagePadding.right,
            cardGapHalf,
          ),
          width: MediaQuery.sizeOf(context).width,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: theme.panelCardInnerPadding.add(
                    EdgeInsets.symmetric(vertical: theme.panelHomeBlockGap),
                  ),
                  width: MediaQuery.sizeOf(context).width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: theme.panelPackageTitleRowMinHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      data.member_type,
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _bodyBoldStrike(expired),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      data.register_date,
                                      textAlign: TextAlign.right,
                                      softWrap: false,
                                      style: _smallSubStrike(expired),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: theme.panelDividerThickness,
                        color: theme.panelDividerColor,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${labels.contractNo}: ',
                                      textAlign: TextAlign.left,
                                      softWrap: true,
                                      style: _bodyBoldStrike(expired),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data.contract_id,
                                        textAlign: TextAlign.left,
                                        softWrap: true,
                                        style: _bodyStrike(expired),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${labels.gymPackageHistoryStartShort} ',
                                          style: theme
                                              .textBody(
                                                  color: theme.defaultSubColor)
                                              .copyWith(
                                                decoration: expired
                                                    .decorationLineThrough,
                                              ),
                                        ),
                                        TextSpan(
                                          text: data.start_date,
                                          style: _bodyBoldStrike(expired),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${labels.gymPackageHistoryEndShort} ',
                                            style: theme
                                                .textBody(
                                                    color: theme.defaultSubColor)
                                                .copyWith(
                                                  decoration: expired
                                                      .decorationLineThrough,
                                                ),
                                          ),
                                          TextSpan(
                                            text: data.end_date,
                                            style: _bodyBoldStrike(expired),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.right,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${labels.amount}: ',
                                          style: theme
                                              .textBody(
                                                  color: theme.defaultSubColor)
                                              .copyWith(
                                                decoration: expired
                                                    .decorationLineThrough,
                                              ),
                                        ),
                                        TextSpan(
                                          text: data.price.toPrice(),
                                          style: _bodyBoldStrike(expired),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${labels.discount}: ',
                                            style: theme
                                                .textBody(
                                                    color:
                                                        theme.defaultSubColor)
                                                .copyWith(
                                                  decoration: expired
                                                      .decorationLineThrough,
                                                ),
                                          ),
                                          TextSpan(
                                            text: data.discount.toPrice(),
                                            style: _bodyBoldStrike(expired),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.right,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: theme.panelDividerThickness,
                        color: theme.panelDividerColor,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${labels.totalPrice}: ',
                                            style: theme
                                                .textBody(
                                                    color:
                                                        theme.defaultSubColor)
                                                .copyWith(
                                                  decoration: expired
                                                      .decorationLineThrough,
                                                ),
                                          ),
                                          TextSpan(
                                            text: data.subscription_price
                                                .toPrice(),
                                            style: _bodyBoldStrike(expired),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.right,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (data.files.isNotEmpty) ...[
                        Divider(
                          thickness: theme.panelDividerThickness,
                          color: theme.panelDividerColor,
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: theme.panelHomeBlockGap,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  labels.gymPackageFilesSectionTitle,
                                  style: _bodyBoldStrike(expired),
                                ),
                              ),
                              SizedBox(height: theme.panelHomeBlockGap),
                              ...data.files.map(
                                (file) =>
                                    _buildFileItem(file, expired, theme),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileItem(
    MemberRegisterFileModel file,
    int expired,
    BaseTheme theme,
  ) {
    final labels = AppLabels.current;

    IconData fileIcon;
    if (file.fileType == _fileTypeContract) {
      fileIcon = Icons.description;
    } else if (file.fileType == _fileTypeRequestForm) {
      fileIcon = Icons.assignment;
    } else {
      fileIcon = Icons.insert_drive_file;
    }

    return InkWell(
      onTap: () async {
        await _downloadFile(file.downloadUrl);
      },
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom: theme.panelCompactInset),
        padding: EdgeInsetsDirectional.all(theme.panelCompactInset),
        decoration: BoxDecoration(
          color: theme.defaultGray100Color,
          borderRadius: BorderRadius.circular(theme.panelCardInnerRadius),
          border: Border.all(
            color: theme.default900Color,
            width: theme.panelDividerThickness,
          ),
        ),
        child: Row(
          children: [
            Icon(
              fileIcon,
              color: theme.default500Color,
              size: theme.panelRowIconSize,
            ),
            SizedBox(width: theme.panelInlineLeadingGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    file.displayLabel,
                    style: theme
                        .textSmallSemiBold(color: theme.default900Color)
                        .copyWith(
                          decoration: expired.decorationLineThrough,
                        ),
                  ),
                  SizedBox(height: theme.panelTightVerticalGap),
                  Text(
                    file.fileName,
                    style: theme.textCaption(color: theme.defaultSubColor).copyWith(
                          decoration: expired.decorationLineThrough,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  SizedBox(height: theme.panelTightVerticalGap),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      labels.gymPackageFileCreatedAtLine(
                        file.createdAt.toFormattedDateTime(
                          inputFormatStr: MemberRegisterConstants
                              .apiDateTimePatternYyyyMmDdHhMmSs,
                          outputFormatStr: MemberRegisterConstants
                              .displayDateTimePatternDdMmYyyyHhMm,
                        ),
                      ),
                      style: theme.textMini(color: theme.defaultSubColor).copyWith(
                            decoration: expired.decorationLineThrough,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download,
              color: theme.default500Color,
              size: theme.panelRowIconSizeSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String downloadUrl) async {
    final labels = AppLabels.current;
    try {
      if (downloadUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(labels.fileUrlNotFound),
            backgroundColor: BlocTheme.theme.panelDangerColor,
          ),
        );
        return;
      }

      final Uri uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(labels.fileCouldNotOpen),
            backgroundColor: BlocTheme.theme.panelDangerColor,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('File download error: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(labels.fileDownloadError),
          backgroundColor: BlocTheme.theme.panelDangerColor,
        ),
      );
    }
  }
}
