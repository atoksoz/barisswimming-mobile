import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/extensions/conditional_text_decoration_extension.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/core/extensions/format_datetime_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/hamam_spa_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/package_model.dart';
import '../../data/model/member_register_file_model.dart';

class BranchPackageHistoryDetailScreen extends StatefulWidget {
  const BranchPackageHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<BranchPackageHistoryDetailScreen> createState() => _BranchPackageHistoryDetailScreenState();
}

class _BranchPackageHistoryDetailScreenState extends State<BranchPackageHistoryDetailScreen> {
  Future<List<PackageModel>> fetchBranchPackageData() async {
    List<PackageModel> packageModel = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getBranchMemberRegisterUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      packageModel = body.map((e) => PackageModel.fromJson(e)).toList();
    } catch (e) {
      print(e);
    } finally {
      return packageModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Satın Alınan Branş Paketleri",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<PackageModel>>(
              future: fetchBranchPackageData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return buildPosts(snapshot.data!);
                } else {
                  return const Center(child: NoDataTextWidget());
                }
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
    return ListView.builder(
      itemCount: packageModel.length,
      itemBuilder: (context, index) {
        final data = packageModel[index];
        
        return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    color: Color.fromARGB(1, 249, 250, 251))
              ],
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
          width: MediaQuery.sizeOf(context).width,
          child: Row(
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 20,
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
                                    style: TextStyle(
                                      color: BlocTheme.theme.default900Color,
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: data.is_expired.decorationLineThrough,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    data.register_date,
                                    textAlign: TextAlign.right,
                                    softWrap: false,
                                    style: TextStyle(
                                      color: BlocTheme.theme.defaultSubColor,
                                      fontFamily: "Inter",
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      decoration: data.is_expired.decorationLineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Sözleşme No : ",
                                        style: TextStyle(
                                          color: BlocTheme.theme.default900Color,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: data.is_expired.decorationLineThrough,
                                        ),
                                      ),
                                      Text(
                                        data.contract_id,
                                        style: TextStyle(
                                          color: BlocTheme.theme.default900Color,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.normal,
                                          fontSize: 17,
                                          decoration: data.is_expired.decorationLineThrough,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Kalan : ",
                                          style: TextStyle(
                                            color: BlocTheme.theme.defaultSubColor,
                                            fontFamily: "Inter",
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "${data.remain_quantity} Adet",
                                          style: TextStyle(
                                            color: BlocTheme.theme.default900Color,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Baş. ",
                                          style: TextStyle(
                                            color: BlocTheme.theme.defaultSubColor,
                                            fontFamily: "Inter",
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                        TextSpan(
                                          text: data.start_date,
                                          style: TextStyle(
                                            color: BlocTheme.theme.default900Color,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Bit. ",
                                            style: TextStyle(
                                              color: BlocTheme.theme.defaultSubColor,
                                              fontFamily: "Inter",
                                              fontSize: 16,
                                              decoration: data.is_expired.decorationLineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.end_date,
                                            style: TextStyle(
                                              color: BlocTheme.theme.default900Color,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired.decorationLineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Tutar : ",
                                          style: TextStyle(
                                            color: BlocTheme.theme.defaultSubColor,
                                            fontFamily: "Inter",
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                        TextSpan(
                                          text: data.price.toPrice(),
                                          style: TextStyle(
                                            color: BlocTheme.theme.default900Color,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            decoration: data.is_expired.decorationLineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "İndirim : ",
                                            style: TextStyle(
                                              color: BlocTheme.theme.defaultSubColor,
                                              fontFamily: "Inter",
                                              fontSize: 16,
                                              decoration: data.is_expired.decorationLineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.discount.toPrice(),
                                            style: TextStyle(
                                              color: BlocTheme.theme.default900Color,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired.decorationLineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Toplam Tutar : ",
                                      style: TextStyle(
                                        color: BlocTheme.theme.defaultSubColor,
                                        fontFamily: "Inter",
                                        fontSize: 16,
                                        decoration: data.is_expired.decorationLineThrough,
                                      ),
                                    ),
                                    TextSpan(
                                      text: data.subscription_price.toPrice(),
                                      style: TextStyle(
                                        color: BlocTheme.theme.default900Color,
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        decoration: data.is_expired.decorationLineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (data.files.isNotEmpty) ...[
                      const Divider(thickness: 1),
                      Container(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Dosyalar",
                                style: TextStyle(
                                  color: BlocTheme.theme.default900Color,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: data.is_expired.decorationLineThrough,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ...data.files.map((file) => _buildFileItem(file, data.is_expired)).toList(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileItem(MemberRegisterFileModel file, int isExpired) {
    IconData fileIcon = file.fileType == 'contract' ? Icons.description : (file.fileType == 'request_form' ? Icons.assignment : Icons.insert_drive_file);

    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(file.downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BlocTheme.theme.default900Color, width: 1),
        ),
        child: Row(
          children: [
            Icon(fileIcon, color: BlocTheme.theme.default500Color, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    file.displayLabel,
                    style: TextStyle(
                      color: BlocTheme.theme.default900Color,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: isExpired == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  Text(
                    file.fileName,
                    style: TextStyle(
                      color: BlocTheme.theme.defaultSubColor,
                      fontFamily: "Inter",
                      fontSize: 12,
                      decoration: isExpired == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.download, color: BlocTheme.theme.default500Color, size: 20),
          ],
        ),
      ),
    );
  }
}
