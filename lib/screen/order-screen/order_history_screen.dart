import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/kantincim_url_constants.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/data/model/order_history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key}) : super(key: key);

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  double total_price = 0.0;
  double total_payment = 0.0;
  double total = 0.0;
  String total_payment_ = "";
  String total_price_ = "";
  String total_ = "";

  var orderData;

  Future<List<OrderHistoryModel>> fetchOrderHistory() async {
    List<OrderHistoryModel> order = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;

      final extractUrl = KantincimUrlConstants.getOpenOrdersExtractUrl(
          externalApplicationConfig!.kantincim);

      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(extractUrl, token: token);
      final List body = json.decode(response!.body)["output"];
      order = body.map((e) => OrderHistoryModel.fromJson(e)).toList();
      double totalPayment = 0;
      double totalPrice = 0;

      order.forEach((element) {
        if (element.payment_type != "") {
          totalPayment += double.parse(element.price.toString());
        } else {
          totalPrice += double.parse(element.price.toString());
        }
      });

      setState(() {
        total_payment_ = totalPayment.toString().toPrice();
        total_price_ = totalPrice.toString().toPrice();
        total_ = (totalPrice - totalPayment).toString().toPrice();
      });
    } catch (e) {
      print(e);
    } finally {
      return order;
    }
  }

  @override
  void initState() {
    setState(() {
      orderData = fetchOrderHistory();
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    var orderData = fetchOrderProductData("asd");
    return Scaffold(
      appBar: null,
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<OrderHistoryModel>>(
              future: orderData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // until data is fetched, show loader
                  return const Center(child: LoadingIndicatorWidget());
                } else if (snapshot.hasData && snapshot.data!.length > 0) {
                  final order = snapshot.data!;
                  return buildPosts(order);
                } else if (snapshot.data!.length == 0) {
                  return const Center(child: NoDataTextWidget());
                } else {
                  // if no data, show simple Text
                  return const Center(child: NoDataTextWidget());
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            width: MediaQuery.sizeOf(context).width,
            height: 230,
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultGray200Color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  color: Colors.black12,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    "Ödeme Özeti",
                    style: TextStyle(
                      color: BlocTheme.theme.orderSummaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kutu
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BlocTheme.theme.defaultOrange50Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Satır 1: Oda/Dolap No
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tutar",
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryTextColor,
                                fontSize: 16,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              total_price_, // ← buraya dinamik veri yazabilirsiniz
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Satır 2: Toplam Ödenen
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Toplam Ödenen",
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryTextColor,
                                fontSize: 16,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              total_payment_, // ← buraya dinamik veri yazabilirsiniz
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Satır 3: Kalan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kalan",
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryTextColor,
                                fontSize: 16,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              total_, // ← buraya dinamik veri yazabilirsiniz
                              style: TextStyle(
                                color: BlocTheme.theme.orderSummaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          )
        ],
      ),
    );
  }

  Widget buildPosts(List<OrderHistoryModel> memberExtract) {
    return ListView.builder(
      itemCount: memberExtract.length,
      itemBuilder: (context, index) {
        final data = memberExtract[index];

        if (data.product_name.trim().isEmpty) {
          return const SizedBox.shrink(); // Boş geç
        }

        final bool isPaid = data?.paid == 1;
        final TextStyle textStyle = TextStyle(
          color: isPaid ? Colors.grey : ApplicationColor.fourthText,
          fontFamily: "Inter",
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          decoration: isPaid ? TextDecoration.lineThrough : TextDecoration.none,
        );

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: const Color.fromARGB(1, 249, 250, 251),
              )
            ],
            color: ApplicationColor.primaryBoxBackground,
            border: Border.all(color: const Color.fromARGB(1, 249, 250, 251)),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
          height: 72,
          child: Row(
            children: [
              // 1. Görsel Alanı
              Expanded(
                flex: 2,
                child: Padding(
                  //padding: const EdgeInsets.all(4.0),
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 5, 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: data.image.isNotEmpty
                        ? Image.network(
                            data.image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.fastfood, size: 36),
                          )
                        : const Icon(Icons.fastfood, size: 36),
                  ),
                ),
              ),

              // 2. Bilgi Alanı
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ürün adı
                      Expanded(
                        child: Text(
                          data.product_name,
                          style: textStyle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Fiyat
                      Expanded(
                        child: Text(
                          '${data.price.toPrice()} ',
                          style: textStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
}
