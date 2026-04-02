import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/data/model/payment_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/member_extract_model.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  int selectedTab = 0;

  Future<List<MemberExtract>> fetchPaymentHistoryData() async {
    List<MemberExtract> memberExtract = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getMemberExtractsUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      memberExtract = body.map((e) => MemberExtract.fromJson(e)).toList();
      return memberExtract;
    } catch (e) {
      print(e);
      return memberExtract;
    }
  }

  Future<List<PaymentPlanModel>> fetchFuturePaymentData() async {
    List<PaymentPlanModel> paymentPlan = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = HamamSpaUrlConstants.getPaymentPlanUrl(
          externalApplicationConfig!.hamamspaApiUrl);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      paymentPlan = body.map((e) => PaymentPlanModel.fromJson(e)).toList();
      return paymentPlan;
    } catch (e) {
      print(e);
    } finally {
      return paymentPlan;
    }
  }

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var orderData = fetchPaymentHistoryData();
    var paymentPlan = fetchFuturePaymentData();
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Ödeme Geçmişi",
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                        fetchPaymentHistoryData();
                      });
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? BlocTheme.theme.default500Color
                            : BlocTheme.theme.defaultWhiteColor,
                        border: selectedTab == 0
                            ? null
                            : Border.all(
                                color: BlocTheme.theme.default900Color),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Ödediklerim',
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                        fetchFuturePaymentData();
                      });
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? BlocTheme.theme.default500Color
                            : BlocTheme.theme.defaultWhiteColor,
                        border: selectedTab == 1
                            ? null
                            : Border.all(
                                color: BlocTheme.theme.default900Color),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Gelecek Dönem',
                          style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selectedTab == 0) ...[
            Expanded(
              child: FutureBuilder<List<MemberExtract>>(
                future: orderData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final order = snapshot.data!;
                    return buildPosts(order);
                  } else {
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: FutureBuilder<List<PaymentPlanModel>>(
                future: paymentPlan,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final order = snapshot.data!;
                    return paymentPlans(order);
                  } else {
                    return const Center(child: NoDataTextWidget());
                  }
                },
              ),
            ),
          ]
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.profile,
      ),
    );
  }

  Widget buildPosts(List<MemberExtract> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    color: Color.fromARGB(
                      1,
                      249,
                      250,
                      251,
                    ))
              ],
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
          width: MediaQuery.sizeOf(context).width,
          height: 66,
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
                    width: MediaQuery.sizeOf(context).width,
                    //color: Colors.blue,
                    child: Column(
                      children: [
                        Center(
                            child: SvgPicture.asset(
                          data.package_type == ""
                              ? BlocTheme.theme.paymentHistoryBagSvgPath
                              : data.package_type == "GYM"
                                  ? BlocTheme.theme.paymentHistoryGymSvgPath
                                  : BlocTheme
                                      .theme.paymentHistoryMassageSvgPath,
                          fit: BoxFit.cover,
                          width: 65,
                          height: 52,
                        )),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(5, 0, 10, 0),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                (data.member_type == ""
                                    ? data.payment_type
                                    : data.member_type),
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                    color: BlocTheme.theme.default900Color,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.fade,
                                (data.register_date == ""
                                    ? data.payment_date
                                    : data.register_date),
                                softWrap: false,
                                style: TextStyle(
                                    color: ApplicationColor.primaryText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                (data.subscription_price == ""
                                    ? data.payment_price.toPrice()
                                    : data.subscription_price.toPrice()),
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: BlocTheme.theme.default900Color,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget paymentPlans(List<PaymentPlanModel> memberExtract) {
    // ListView Builder to show data in a list
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];
        return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    color: Color.fromARGB(
                      1,
                      249,
                      250,
                      251,
                    ))
              ],
              color: ApplicationColor.primaryBoxBackground,
              border: Border.all(color: Color.fromARGB(1, 249, 250, 251)),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          margin: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
          width: MediaQuery.sizeOf(context).width,
          height: 66,
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
                    width: MediaQuery.sizeOf(context).width,
                    //color: Colors.blue,
                    child: Column(
                      children: [
                        Center(
                            child: SvgPicture.asset(
                          BlocTheme.theme.paymentHistoryBagSvgPath,
                          fit: BoxFit.cover,
                          width: 65,
                          height: 52,
                        )),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(5, 0, 10, 0),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                data.memberType,
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                    color: BlocTheme.theme.default900Color,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                    width: MediaQuery.sizeOf(context).width,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.fade,
                                data.paymentDate,
                                softWrap: false,
                                style: TextStyle(
                                    color: ApplicationColor.primaryText,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                textAlign: TextAlign.left,
                                data.paymentPrice.toString().toPrice(),
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: BlocTheme.theme.default900Color,
                                    fontFamily: "Inter",
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16),
                              ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
