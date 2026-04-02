import 'dart:convert';

import 'package:e_sport_life/core/constants/url/kantincim_url_constants.dart';
import 'package:e_sport_life/core/extensions/currency_format_extension.dart';
import 'package:e_sport_life/core/widgets/category_selector_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class Product extends StatefulWidget {
  final String categoryUuid;
  final String categoryName;

  const Product(
      {Key? key,
      required this.categoryUuid,
      required this.categoryName // zorunlu alan
      })
      : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  String selectedCategoryUuid = "";
  String selectedCategoryName = "";
  Future<List<ProductModel>>? selectedProductModel;
  late Future<List<ProductModel>> productModel;

  Future<List<ProductModel>> fetchProducts() async {
    List<ProductModel> products = [];
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final kantincimUrl = KantincimUrlConstants.getMobileSalesProductUrl(
          externalApplicationConfig!.kantincim);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(kantincimUrl, token: token);
      final Map<String, dynamic> json = jsonDecode(response!.body);

      products = (json["output"] as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      return products;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    selectedCategoryUuid = widget.categoryUuid;
    selectedCategoryName = widget.categoryName;

    productModel = fetchProducts().then((products) {
      final filtered = products
          .where((product) => product.categoryUuid == selectedCategoryUuid)
          .toList();
      setState(() {
        selectedProductModel = Future.value(filtered);
      });
      return products;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Ürün Listesi",
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sabit kalan kategori seçici
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: CategorySelector(
                selectedCategoryUuid: selectedCategoryUuid,
                onCategoryChanged: (String selectedCategory) {
                  setState(() {
                    selectedCategoryUuid = selectedCategory;
                  });

                  productModel.then((allProducts) {
                    final filtered = allProducts
                        .where((product) =>
                            product.categoryUuid == selectedCategoryUuid)
                        .toList();
                    setState(() {
                      selectedProductModel = Future.value(filtered);
                    });
                  });
                },
              ),
            ),

            // Geri kalan her şeyi scroll edilebilir alan içine al
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: selectedProductModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingIndicatorWidget());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: NoDataTextWidget(text: "Ürün Bulunamadı"));
                  }

                  final products = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori başlığı
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 10),
                          child: Text(
                            selectedCategoryName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: BlocTheme.theme.default900Color,
                            ),
                          ),
                        ),

                        // Grid şeklinde ürünler
                        buildPosts(products, context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget buildPosts(List<ProductModel> productList, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 112 + 16;
    int crossAxisCount = (screenWidth / itemWidth).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 112 / 150,
        ),
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final data = productList[index];

          return Container(
            width: 112,
            height: 150,
            decoration: BoxDecoration(
              color: ApplicationColor.primaryBoxBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(25, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                children: [
                  // Görsel
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data.thumbImagePath.isNotEmpty
                            ? data.thumbImagePath ?? ''
                            : '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.fastfood,
                          size: 64,
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Ürün Adı
                  Expanded(
                    child: Center(
                      child: Text(
                        data.productName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Fiyat
                  Text(
                    data.totalPrice.toString().toPrice(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: BlocTheme.theme.default800Color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
