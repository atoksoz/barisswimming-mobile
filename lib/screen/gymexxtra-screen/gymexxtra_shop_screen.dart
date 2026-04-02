import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/shop_storage.dart';

import '../../config/themes/bloc_theme.dart';
import '../../contants/application_color.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/warning_dialog_widget.dart';
import '../../data/model/gymexxtra_order_model.dart';
import '../../data/model/gymexxtra_product_model.dart';
import '../../core/services/gymexxtra_service.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../config/user-config/user_config_cubit.dart';
import '../../config/external-applications-config/external_applications_config_cubit.dart';

class GymexxtraShopScreen extends StatefulWidget {
  const GymexxtraShopScreen({Key? key}) : super(key: key);

  @override
  State<GymexxtraShopScreen> createState() => _GymexxtraShopScreenState();
}

class _GymexxtraShopScreenState extends State<GymexxtraShopScreen> {
  int selectedTab = 0; // 0: Sepetim, 1: Sipariş Geçmişi
  GymexxtraProductModel? selectedProduct;
  final TextEditingController couponController = TextEditingController();
  final FocusNode couponFocusNode = FocusNode();
  
  bool isLoading = false;
  bool isCouponLoading = false; // Kupon için ayrı loading
  bool productsLoaded = false;
  bool ordersLoaded = false;
  List<GymexxtraProductModel> products = [];
  List<GymexxtraOrderModel> orders = [];
  Map<String, dynamic>? couponResult;

  @override
  void initState() {
    super.initState();
    _loadCachedInputs();
    _fetchData();
  }

  @override
  void dispose() {
    couponController.dispose();
    couponFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCachedInputs() async {
    final cachedData = await ShopStorage.loadShopInputs();
    final cachedCoupon = cachedData['couponCode'];
    if (cachedCoupon != null && cachedCoupon.isNotEmpty) {
      setState(() {
        couponController.text = cachedCoupon;
      });
    }
  }

  Future<void> _saveCachedInputs() async {
    await ShopStorage.saveShopInputs(
      productId: selectedProduct?.id,
      couponCode: couponController.text,
    );
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final userConfig = context.read<UserConfigCubit>().state;
      final extConfig = context.read<ExternalApplicationsConfigCubit>().state;

      // Token' JwtStorageService'dan da almay deneyelim (daha gAvenilir)
      String? token = userConfig?.token;
      if (token == null || token.isEmpty) {
        token = await JwtStorageService.getToken();
      }

      if (token != null &&
          token.isNotEmpty &&
          extConfig != null &&
          extConfig.gymexxtraApi.isNotEmpty) {
        final fetchedProducts = await GymexxtraService.fetchProducts(
          gymexxtraApiUrl: extConfig.gymexxtraApi,
          token: token,
        );

        if (mounted) {
          final cachedProductId = await ShopStorage.getSelectedProductId();
          
          setState(() {
            products = fetchedProducts;
            // isFirst olanları en üste taşı
            products.sort((a, b) {
              if (a.isFirst && !b.isFirst) return -1;
              if (!a.isFirst && b.isFirst) return 1;
              return 0;
            });
            productsLoaded = true;
            
            if (products.isNotEmpty) {
              // Önce cache'deki ürünü bulmaya çalış
              if (cachedProductId != null) {
                try {
                  selectedProduct = products.firstWhere((p) => p.id == cachedProductId);
                } catch (e) {
                  // Cache'deki ürün yoksa isFirst true olanı seç, yoksa ilkini seç
                  selectedProduct = products.firstWhere(
                    (p) => p.isFirst,
                    orElse: () => products.first,
                  );
                }
              } else {
                // isFirst true olanı seç, yoksa ilkini seç
                selectedProduct = products.firstWhere(
                  (p) => p.isFirst,
                  orElse: () => products.first,
                );
              }
            }
          });

          // Eğer cache'de kupon varsa ve ürün seçiliyse kuponu otomatik doğrula
          if (couponController.text.isNotEmpty && selectedProduct != null) {
            _applyCoupon();
          }
        }
      } else {
        print('Gymexxtra: Token or API URL missing. Token: ${token?.length}, URL: ${extConfig?.gymexxtraApi}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          productsLoaded = true;
        });
      }
    }
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final userConfig = context.read<UserConfigCubit>().state;
      final extConfig = context.read<ExternalApplicationsConfigCubit>().state;

      String? token = userConfig?.token;
      if (token == null || token.isEmpty) {
        token = await JwtStorageService.getToken();
      }

      if (token != null &&
          token.isNotEmpty &&
          extConfig != null &&
          extConfig.gymexxtraApi.isNotEmpty) {
        final fetchedOrders = await GymexxtraService.fetchOrders(
          gymexxtraApiUrl: extConfig.gymexxtraApi,
          token: token,
        );

        if (mounted) {
          setState(() {
            orders = fetchedOrders;
            ordersLoaded = true;
          });
        }
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          ordersLoaded = true;
        });
      }
    }
  }

  void _showProductSelector(BuildContext context) {
    // isFirst true olanı en üste alacak şekilde listeyi kopyalayalım ve sıralayalım
    List<GymexxtraProductModel> sortedProducts = List.from(products);
    sortedProducts.sort((a, b) {
      if (a.isFirst && !b.isFirst) return -1;
      if (!a.isFirst && b.isFirst) return 1;
      return 0;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Paket Seçimi Yapınız",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BlocTheme.theme.default900Color,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sortedProducts.length,
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index];
                    bool isSelected = selectedProduct?.id == product.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedProduct = product;
                            couponResult = null;
                          });
                          _saveCachedInputs(); // Cache'e kaydet
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? ApplicationColor.primary.withOpacity(0.1) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? ApplicationColor.primary : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 16,
                                        color: BlocTheme.theme.default900Color,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₺${product.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: BlocTheme.theme.defaultSubColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: ApplicationColor.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyCoupon() async {
    if (couponController.text.isEmpty) return;

    // Eğer zaten bu kupon uygulandıysa tekrar istek atma
    if (couponResult != null && 
        (couponResult!['code'] == couponController.text || couponResult!['campaign_id']?.toString() == couponController.text)) {
      return;
    }

    setState(() {
      isCouponLoading = true; // Sadece kupon loading'i aktif et
    });

    try {
      final userConfig = context.read<UserConfigCubit>().state;
      final extConfig = context.read<ExternalApplicationsConfigCubit>().state;

      String? token = userConfig?.token;
      if (token == null || token.isEmpty) {
        token = await JwtStorageService.getToken();
      }

      if (token != null &&
          token.isNotEmpty &&
          extConfig != null &&
          extConfig.gymexxtraApi.isNotEmpty) {
        final result = await GymexxtraService.validateCoupon(
          gymexxtraApiUrl: extConfig.gymexxtraApi,
          token: token,
          couponCode: couponController.text,
          productId: selectedProduct?.id,
        );

        setState(() {
          couponResult = result;
        });
        _saveCachedInputs(); // Başarılı veya başarısız denemeyi de kaydedelim

        if (result != null) {
          couponFocusNode.unfocus(); // Klavyeyi kapat ve odağı kaldır
          FocusManager.instance.primaryFocus?.unfocus(); // Global unfocus garanti olsun
          await warningDialog(
            context,
            message: 'Kupon başarıyla uygulandı.',
            path: BlocTheme.theme.attentionSvgPath, // Varsa success path kullanılabilir
            buttonColor: ApplicationColor.primary,
            buttonTextColor: Colors.black,
          );
        } else {
          await warningDialog(
            context,
            message: 'Geçersiz kupon kodu.',
            path: BlocTheme.theme.attentionSvgPath,
            buttonColor: BlocTheme.theme.defaultRed700Color,
            buttonTextColor: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error applying coupon: $e');
    } finally {
      if (mounted) {
        setState(() {
          isCouponLoading = false;
        });
      }
    }
  }

  Future<void> _purchase() async {
    if (selectedProduct == null) return;

    final userConfig = context.read<UserConfigCubit>().state;
    final extConfig = context.read<ExternalApplicationsConfigCubit>().state;

    String? token = userConfig?.token;
    if (token == null || token.isEmpty) {
      token = await JwtStorageService.getToken();
    }

    if (token != null &&
        token.isNotEmpty &&
        extConfig != null &&
        extConfig.gymexxtraApi.isNotEmpty) {
      
      setState(() {
        isLoading = true;
      });

      // A-nce sepete ekle
      final cartResult = await GymexxtraService.addToCart(
        gymexxtraApiUrl: extConfig.gymexxtraApi,
        token: token,
        productId: selectedProduct!.id,
        couponCode: couponController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (cartResult != null) {
        final String? draftHash = cartResult['draft_hash']?.toString() ?? cartResult['hash']?.toString();
        final String? firmSlug = cartResult['firm_slug']?.toString();

        if (draftHash == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sepet bilgisi alınamadı.')),
          );
          return;
        }

        if (firmSlug == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şube bilgisi alınamadı.')),
          );
          return;
        }

        // Ödeme sayfasına yönlendir
        // Format: https://gymexxtra.com.tr/tr/facilities/{firm_slug}/membership?draft_hash={hash}
        const String baseUrl = "https://gymexxtra.com.tr";
        
        final paymentUrl = "$baseUrl/tr/facilities/$firmSlug/membership?draft_hash=$draftHash";
        
        print('Redirecting to Payment: $paymentUrl');
        
        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ödeme sayfası açılamadı.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sepet işlemi başarısız oldu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      bottomNavigationBar: selectedTab == 0 && products.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (selectedProduct != null && !isLoading && !isCouponLoading) ? _purchase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ApplicationColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Satın Al",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              // Tab Selector
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => selectedTab = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedTab == 0
                                ? ApplicationColor.primary
                                : Colors.white,
                            border: Border.all(
                              color: selectedTab == 1
                                  ? BlocTheme.theme.default900Color
                                  : const Color.fromARGB(1, 249, 250, 251),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsetsDirectional.only(end: 20),
                          alignment: Alignment.center,
                          child: Text(
                            "Sepetim",
                            style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => selectedTab = 1);
                          _fetchOrders();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedTab == 1
                                ? ApplicationColor.primary
                                : Colors.white,
                            border: Border.all(
                              color: selectedTab == 0
                                  ? BlocTheme.theme.default900Color
                                  : const Color.fromARGB(1, 249, 250, 251),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsetsDirectional.only(start: 20),
                          alignment: Alignment.center,
                          child: Text(
                            "Sipariş Geçmişi",
                            style: TextStyle(
                              color: BlocTheme.theme.default900Color,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: selectedTab == 0 ? _buildCartTab() : _buildHistoryTab(),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingIndicatorWidget(),
                    const SizedBox(height: 16),
                    Text(
                      "Ödeme Sayfasına Yönlendiriliyorsunuz...",
                      style: TextStyle(
                        color: BlocTheme.theme.default900Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    if (products.isEmpty && productsLoaded) {
      return const Center(
        child: NoDataTextWidget(text: "Veri Bulunamadı"),
      );
    }

    if (products.isEmpty && !productsLoaded && !isLoading) {
      return const SizedBox();
    }

    final bool isCouponAlreadyApplied = couponResult != null &&
        (couponResult!['code']?.toString().toLowerCase() == couponController.text.toLowerCase() ||
            couponResult!['campaign_id']?.toString() == couponController.text);

    final bool isApplyButtonEnabled =
        couponController.text.isNotEmpty && !isCouponLoading && !isCouponAlreadyApplied;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Şık Ürün Seçici (Field)
          InkWell(
            onTap: () => _showProductSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Seçili Paket",
                          style: TextStyle(
                            color: BlocTheme.theme.defaultSubColor,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          selectedProduct?.name ?? "Paket Seçiniz",
                          style: TextStyle(
                            color: BlocTheme.theme.default900Color,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: BlocTheme.theme.default900Color,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Kupon Kodu Girişi
          TextField(
            controller: couponController,
            focusNode: couponFocusNode,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: "Kupon Kodu",
              hintText: "Varsa kupon kodunuzu giriniz",
              counterText: "", // Alt kısımdaki karakter sayacını gizle
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                child: InkWell(
                  onTap: isApplyButtonEnabled ? _applyCoupon : null,
                  child: Container(
                    width: 80, // Sabit genişlik ekleyerek genişlemesini engelledik
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isApplyButtonEnabled
                          ? BlocTheme.theme.defaultRed700Color
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isCouponLoading
                        ? const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Uygula",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ApplicationColor.primary),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
            onChanged: (value) {
              setState(() {}); // "Uygula" butonunu aktif etmek için
            },
          ),
          const SizedBox(height: 20),
          // Sipariş Özeti
          if (selectedProduct != null) _buildOrderSummary(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final double subtotal = selectedProduct!.price;
    double discount = 0.0;
    
    if (couponResult != null) {
      discount = double.tryParse(couponResult!['discount_amount']?.toString() ?? '0') ?? 0.0;
    }
    
    final double total = subtotal - discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sipariş Özeti",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BlocTheme.theme.orderSummaryColor,
          ),
        ),
        const SizedBox(height: 20),
        // Rectangle 2 (Sipariş Detayları)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BlocTheme.theme.defaultOrange50Color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _summaryItem("Ürün Tutarı", "₺${subtotal.toStringAsFixed(2)}"),
              if (discount > 0) const SizedBox(height: 10),
              if (discount > 0)
                _summaryItem("İndirim", "-₺${discount.toStringAsFixed(2)}", isDiscount: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Kesikli Çizgi
        CustomPaint(
          painter: DashedLinePainter(
            color: BlocTheme.theme.orderSummaryTextColor,
          ),
          size: const Size(double.infinity, 1),
        ),
        const SizedBox(height: 20),
        // Rectangle 3 (Toplam Tutar)
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ödenecek Tutar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.defaultMainColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₺${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.orderSummaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.description_rounded,
                    size: 60,
                    color: BlocTheme.theme.orderSummaryTextColor,
                  ),
                ],
              ),
            ),
            // Üst oval kesikler (Görseldeki gibi bite effect)
            Positioned(
              top: -15,
              left: -15,
              child: _ovalCutoutSmall(),
            ),
            Positioned(
              top: -15,
              right: -15,
              child: _ovalCutoutSmall(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ovalCutoutSmall() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _summaryItem(String label, String value,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? BlocTheme.theme.defaultRed700Color : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount ? BlocTheme.theme.defaultRed700Color : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (orders.isEmpty && ordersLoaded) {
      return const Center(
        child: NoDataTextWidget(text: "Veri Bulunamadı"),
      );
    }

    if (orders.isEmpty && !ordersLoaded && !isLoading) {
      return const SizedBox();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(GymexxtraOrderModel order) {
    bool isCancelled = order.statusLabel.toLowerCase().contains("iptal") ||
        order.status.toLowerCase().contains("cancelled");

    // Tarih formatlama
    String formattedDate = order.date;
    try {
      DateTime dt = DateTime.parse(order.date);
      formattedDate = DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      // Eğer parse edilemezse orijinalini kullan
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Firma: ${order.tenantName}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: BlocTheme.theme.defaultMainColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Sipariş No: ${order.orderNo}",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Miktar: ${order.quantity}",
                style: TextStyle(
                  color: BlocTheme.theme.defaultSubColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Tutar (Liste): ₺${order.listPrice.toStringAsFixed(2)}",
              style: TextStyle(color: BlocTheme.theme.defaultSubColor),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "İndirim: ₺${order.discount.toStringAsFixed(2)}",
              style: TextStyle(color: BlocTheme.theme.defaultSubColor),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "İndirimli Tutar: ₺${order.discountedPrice.toStringAsFixed(2)}",
              style: TextStyle(color: BlocTheme.theme.defaultSubColor),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Taksit: ${order.installmentCount} x ₺${order.installmentPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color: BlocTheme.theme.defaultSubColor,
                  fontSize: 13,
                ),
              ),
              Text(
                "Toplam: ₺${order.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: isCancelled ? BlocTheme.theme.defaultRed700Color : BlocTheme.theme.default700Color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sipariş Tarihi: $formattedDate",
                    style: TextStyle(
                      color: BlocTheme.theme.defaultSubColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 10, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
