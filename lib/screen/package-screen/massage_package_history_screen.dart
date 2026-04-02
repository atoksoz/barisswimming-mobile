import 'dart:convert';

import 'package:e_sport_life/core/extensions/conditional_text_decoration_extension.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/data/model/package_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../config/user-config/user_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/hamam_spa_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/screen/panel/member/qr-code/member_fixed_qr_screen.dart';

class MassagePackageHistory extends StatefulWidget {
  const MassagePackageHistory({Key? key}) : super(key: key);

  @override
  State<MassagePackageHistory> createState() => _MassagePackageHistoryState();
}

class _MassagePackageHistoryState extends State<MassagePackageHistory> {
  String memberId = "";
  Future<void> getMemberId() async {
    try {
      await context.read<UserConfigCubit>().loadUserConfig();
      final userConfig = await context.read<UserConfigCubit>().state;

      if (userConfig != null) {
        setState(() {
          memberId = userConfig.memberId;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<PackageModel>> fetchOrderProductData() async {
    List<PackageModel> packageModel = [];

    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getMassageMemberRegisterUrl(
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
  void initState() {
    setState(() {});
    getMemberId();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var orderData = fetchOrderProductData();
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Masaj Paketlerim",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<PackageModel>>(
              future: orderData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // until data is fetched, show loader
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.length > 0) {
                  final order = snapshot.data!;
                  return buildPosts(order);
                } else {
                  // if no data, show simple Text
                  return const Center(
                      child: Text(
                    textAlign: TextAlign.left,
                    "Veri Bulunamadı",
                    maxLines: 1,
                    softWrap: true,
                    style: TextStyle(
                        color: Color.fromARGB(255, 55, 80, 0),
                        fontFamily: "Inter",
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ));
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

  Widget buildPosts(List<PackageModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return GestureDetector(
          onTap: () {
            print("geldi");
            print(memberId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MemberFixedQrScreen(value: memberId),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  color: Color.fromARGB(1, 249, 250, 251),
                )
              ],
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
            width: MediaQuery.sizeOf(context).width,
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
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
                                          color:
                                              BlocTheme.theme.default900Color,
                                          fontFamily: "Inter",
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: data
                                              .is_expired.decorationLineThrough,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data.register_date,
                                        textAlign: TextAlign.right,
                                        softWrap: false,
                                        style: TextStyle(
                                          color:
                                              BlocTheme.theme.defaultSubColor,
                                          fontFamily: "Inter",
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          decoration: data
                                              .is_expired.decorationLineThrough,
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
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 0, 0),
                                          child: Text(
                                            textAlign: TextAlign.left,
                                            "Sözleşme No : ",
                                            softWrap: true,
                                            style: TextStyle(
                                              color: BlocTheme
                                                  .theme.default900Color,
                                              fontFamily: "Inter",
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 0, 0, 0),
                                          child: Text(
                                            textAlign: TextAlign.left,
                                            data.contract_id,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: BlocTheme
                                                  .theme.default900Color,
                                              fontFamily: "Inter",
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 17,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
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
                                            text: "Miktar : ",
                                            style: TextStyle(
                                              color: BlocTheme
                                                  .theme.defaultSubColor,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.quantity + " adet",
                                            style: TextStyle(
                                              color: BlocTheme.theme
                                                  .default900Color, // örnek başka renk
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.left,
                                      softWrap: true,
                                    )),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Kalan : ",
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.defaultSubColor,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                            TextSpan(
                                              text: data.remain_quantity +
                                                  " adet",
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.default900Color,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.right,
                                        softWrap: true,
                                      ),
                                    ))
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
                                              color: BlocTheme
                                                  .theme.defaultSubColor,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.start_date,
                                            style: TextStyle(
                                              color: BlocTheme.theme
                                                  .default900Color, // örnek başka renk
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.left,
                                      softWrap: true,
                                    )),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Bit. ",
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.defaultSubColor,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                            TextSpan(
                                              text: data.end_date,
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.default900Color,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.right,
                                        softWrap: true,
                                      ),
                                    ))
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
                                              color: BlocTheme
                                                  .theme.defaultSubColor,
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.price.toPrice(),
                                            style: TextStyle(
                                              color: BlocTheme.theme
                                                  .default900Color, // örnek başka renk
                                              fontFamily: "Inter",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              decoration: data.is_expired
                                                  .decorationLineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.left,
                                      softWrap: true,
                                    )),
                                    Expanded(
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "İndirim : ",
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.defaultSubColor,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                            TextSpan(
                                              text: data.discount.toPrice(),
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.default900Color,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.right,
                                        softWrap: true,
                                      ),
                                    ))
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
                                        child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Toplam Tutar : ",
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.defaultSubColor,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                            TextSpan(
                                              text: data.subscription_price
                                                  .toPrice(),
                                              style: TextStyle(
                                                color: BlocTheme
                                                    .theme.default900Color,
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                decoration: data.is_expired
                                                    .decorationLineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.right,
                                        softWrap: true,
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
