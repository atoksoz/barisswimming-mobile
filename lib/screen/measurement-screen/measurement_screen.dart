import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../contants/application_color.dart';
import '../../core/constants/url/gym_training_url_constants.dart';
import '../../core/services/jwt_storage_service.dart';
import '../../core/services/measurement_service.dart';
import '../../core/utils/request_util.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/image_gallery_popup_widget.dart';
import '../../core/widgets/loading_indicator_widget.dart';
import '../../core/widgets/measurement_input_form_widget.dart';
import '../../core/widgets/no_data_text_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../core/widgets/warning_dialog_widget.dart';
import '../../data/model/measurement_model.dart';
import 'measurement_add_screen.dart';

class Measurement extends StatefulWidget {
  final List<MeasurementModel> measurements;
  final int selectedIndex;

  const Measurement({
    Key? key,
    required this.measurements,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<Measurement> createState() => _MeasurementState();
}

class _MeasurementState extends State<Measurement> {
  late int selectedIndex;
  late List<MeasurementModel> measurements;

  bool _isLoading = true;
  int _selectedPdfIndex = 0; // Birden fazla PDF varsa hangi PDF gösterilecek

  TextEditingController _sizeController = new TextEditingController();
  TextEditingController _bodyWeightController = new TextEditingController();
  TextEditingController _armController = new TextEditingController();
  TextEditingController _chestController = new TextEditingController();
  TextEditingController _shoulderController = new TextEditingController();
  TextEditingController _stomachController = new TextEditingController();

  MeasurementModel? _currentMeasurement;

  Future<void> _updateControllers(MeasurementModel data) async {
    setState(() {
      _isLoading = true;
      _bodyWeightController.text = data.bodyWeight.toString();
      _sizeController.text = data.size.toString();
      _armController.text = data.arm.toString();
      _chestController.text = data.chest.toString();
      _shoulderController.text = data.shoulder.toString();
      _stomachController.text = data.stomach.toString();
      _currentMeasurement = data;
      
      // PDF index'ini sıfırla ve geçerli PDF sayısına göre ayarla
      final pdfs = data.pdfAttachments;
      final hasOldPdf = data.file.isNotEmpty && 
                       (data.file.toLowerCase().endsWith('.pdf') || 
                        data.file.startsWith('http'));
      final totalPdfs = pdfs.length + (hasOldPdf && pdfs.isEmpty ? 1 : 0);
      _selectedPdfIndex = 0;
      if (_selectedPdfIndex >= totalPdfs) {
        _selectedPdfIndex = 0;
      }
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    setState(() {
      _sizeController.text = "";
      _bodyWeightController.text = "";
      _armController.text = "";
      _chestController.text = "";
      _shoulderController.text = "";
      _stomachController.text = "";
    });
    measurements = widget.measurements;
    selectedIndex = widget.selectedIndex;

    _updateControllers(measurements[selectedIndex]);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _sizeController.dispose();
    _bodyWeightController.dispose();
    _armController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _stomachController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var orderData = fetchOrderProductData();
    return Scaffold(
      appBar: TopAppBarWidget(
        title: "Ölçüm Detayı",
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Container(
                //color: Colors.black.withOpacity(0.3),
                child: const Center(
                    child:
                        LoadingIndicatorWidget()) 
                )
          else
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(children: [
                      // 🔼 Tarih ve ok butonları kutusu
                      Container(
                        decoration: BoxDecoration(
                          color: ApplicationColor.primaryBoxBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 1,
                              color: Color.fromARGB(1, 249, 250, 251),
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: BlocTheme.theme.default900Color,
                          ),
                          onPressed: () {
                            if (selectedIndex > 0) {
                              setState(() {
                                selectedIndex--;
                                _updateControllers(measurements[selectedIndex]);
                              });
                            }
                          },
                        ),
                      ),

                      // 🔲 Ortadaki tarih metni
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: ApplicationColor.primaryBoxBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 1,
                                color: Color.fromARGB(1, 249, 250, 251),
                              )
                            ],
                            border: Border.all(
                                color: Color.fromARGB(1, 249, 250, 251)),
                          ),
                          child: Center(
                            child: Text(
                              measurements[selectedIndex].formattedDate,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: BlocTheme.theme.default900Color,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ▶️ Sağ ok
                      Container(
                        decoration: BoxDecoration(
                          color: ApplicationColor.primaryBoxBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 1,
                              color: Color.fromARGB(1, 249, 250, 251),
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: BlocTheme.theme.default900Color,
                          ),
                          onPressed: () {
                            if (selectedIndex < measurements.length - 1) {
                              setState(() {
                                selectedIndex++;
                                _updateControllers(measurements[selectedIndex]);
                              });
                            }
                          },
                        ),
                      ),
                    ]),
                    // 🔽 10px boşluk
                    const SizedBox(height: 20),

                    Expanded(
                      child: _buildContent(),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
                      builder: (context, settings) {
                        if (settings?.allowMeasurementCreate == true) {
                          return _buildMeasurementActionButtons(context);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }

  Widget _buildContent() {
    if (_currentMeasurement == null) {
      return const SizedBox.shrink();
    }

    final measurement = _currentMeasurement!;
    final hasDetails = measurement.hasMeasurementDetails;
    final pdfs = measurement.pdfAttachments;
    final images = measurement.imageAttachments;
    final hasOldPdf = measurement.file.isNotEmpty && 
                     (measurement.file.toLowerCase().endsWith('.pdf') || 
                      measurement.file.startsWith('http'));

    // Eski format: file string'i varsa ve attachments boşsa, onu PDF olarak ekle
    List<String> allPdfs = pdfs.map((p) => _getFullPdfUrl(p.path)).toList();
    if (hasOldPdf && allPdfs.isEmpty) {
      allPdfs.add(_getFullPdfUrl(measurement.file));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ölçüm detayları varsa göster
          if (hasDetails) ...[
            MeasurementInputFormWidget(
              weightController: _bodyWeightController,
              heightController: _sizeController,
              chestController: _chestController,
              armController: _armController,
              shoulderController: _shoulderController,
              waistController: _stomachController,
              readOnly: true,
            ),
            const SizedBox(height: 20),
          ],

          // PDF'ler varsa göster
          if (allPdfs.isNotEmpty) ...[
            _buildPdfsSection(allPdfs),
            const SizedBox(height: 20),
          ],

          // Resimler varsa göster
          if (images.isNotEmpty) ...[
            _buildImagesSection(images),
            const SizedBox(height: 20),
          ],

          // Hiçbir şey yoksa
          if (!hasDetails && allPdfs.isEmpty && images.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  'Bu ölçüm kaydında görüntülenecek veri bulunmamaktadır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfsSection(List<String> pdfs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PDF Dosyaları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BlocTheme.theme.default900Color,
          ),
        ),
        const SizedBox(height: 12),
        _buildPdfsGrid(pdfs),
      ],
    );
  }

  Widget _buildPdfsGrid(List<String> pdfs) {
    // Grid layout: 4 sütun - görseller gibi
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: pdfs.length,
      itemBuilder: (context, index) {
        final pdfUrl = pdfs[index];
        return GestureDetector(
          onTap: () {
            _showPdfPopup(pdfUrl, index + 1);
          },
          child: Container(
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultGray200Color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BlocTheme.theme.defaultGray400Color,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 48,
                  color: BlocTheme.theme.default900Color,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BlocTheme.theme.default900Color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPdfPopup(String pdfUrl, int pdfNumber) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // PDF viewer
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 80,
                    left: 16,
                    right: 16,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PDF().cachedFromUrl(
                      pdfUrl,
                      placeholder: (progress) => Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: progress > 0 ? progress / 100 : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '$progress% yükleniyor...',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (error) => Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: BlocTheme.theme.defaultRed700Color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'PDF yüklenemedi',
                                style: TextStyle(
                                  color: BlocTheme.theme.defaultRed700Color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$error',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BlocTheme.theme.defaultGray600Color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // PDF indir butonu
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          launchUrlString(pdfUrl);
                        },
                        icon: const Icon(
                          Icons.download_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                        label: Text(
                          "PDF ${pdfNumber} indir",
                          style: const TextStyle(
                            fontFamily: "Inter",
                            letterSpacing: 0,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Kapat butonu
                Positioned(
                  top: 70,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
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

  Widget _buildImagesSection(List<MeasurementAttachment> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Görseller',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BlocTheme.theme.default900Color,
          ),
        ),
        const SizedBox(height: 10),
        _buildImagesGrid(images),
      ],
    );
  }

  String _getFullImageUrl(String path) {
    // Eğer path zaten tam URL ise (http veya https ile başlıyorsa), olduğu gibi döndür
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Eğer path system.gymtraining gibi başlıyorsa, sadece https:// ekle
    if (path.startsWith('system') || path.startsWith('gymtraining')) {
      return 'https://$path';
    }
    
    // Diğer durumlarda, base URL ile birleştir
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalApplicationConfig != null && externalApplicationConfig.gymTraining.isNotEmpty) {
        final baseUrl = externalApplicationConfig.gymTraining;
        // Path'in başında / varsa kaldır
        final cleanPath = path.startsWith('/') ? path.substring(1) : path;
        // Base URL'in sonunda / varsa kaldır
        final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        return '$cleanBaseUrl/$cleanPath';
      }
    } catch (e) {
      print('Error getting base URL for image: $e');
    }
    
    // Hata durumunda orijinal path'i döndür
    return path;
  }

  String _getFullPdfUrl(String path) {
    // Eğer path zaten tam URL ise (http veya https ile başlıyorsa), olduğu gibi döndür
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Eğer path system.gymtraining gibi başlıyorsa, sadece https:// ekle
    if (path.startsWith('system.') || path.startsWith('gymtraining')) {
      return 'https://$path';
    }
    
    // Diğer durumlarda, base URL ile birleştir
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalApplicationConfig != null && externalApplicationConfig.gymTraining.isNotEmpty) {
        final baseUrl = externalApplicationConfig.gymTraining;
        // Path'in başında / varsa kaldır
        final cleanPath = path.startsWith('/') ? path.substring(1) : path;
        // Base URL'in sonunda / varsa kaldır
        final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
        return '$cleanBaseUrl/$cleanPath';
      }
    } catch (e) {
      print('Error getting base URL for PDF: $e');
    }
    
    // Hata durumunda orijinal path'i döndür
    return path;
  }

  Widget _buildImagesGrid(List<MeasurementAttachment> images) {
    // Grid layout: 4 sütun - görseller yarı boyutta (2 sütundan 4 sütuna çıkararak)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        final imageUrl = _getFullImageUrl(image.path);
        return GestureDetector(
          onTap: () {
            final imageUrls = images.map((img) => _getFullImageUrl(img.path)).toList();
            ImageGalleryPopupWidget.show(
              context,
              images: imageUrls,
              initialIndex: index,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image load error for URL: $imageUrl, error: $error');
                return Container(
                  color: BlocTheme.theme.defaultGray200Color,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: BlocTheme.theme.defaultGray600Color,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: BlocTheme.theme.defaultGray200Color,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
      child: Row(
        children: [
          // Ölçüm Ekle butonu
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MeasurementAddScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BlocTheme.theme.default500Color,
                foregroundColor: BlocTheme.theme.defaultBlackColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ölçüm Ekle',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: BlocTheme.theme.defaultBlackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ölçümü Sil butonu
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await _handleDeleteMeasurement(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ölçümü Sil',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteMeasurement(BuildContext context) async {
    final currentMeasurement = measurements[selectedIndex];
    final measurementId = currentMeasurement.id;

    // Onay dialog göster
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                BlocTheme.theme.attentionSvgPath,
                width: 64,
                height: 65,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                'Ölçümü silmek istediğinize emin misiniz?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: BlocTheme.theme.defaultBlackColor,
                ),
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
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: const Text(
                        "Hayır",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlocTheme.theme.default500Color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: const Text(
                        "Evet",
                        style: TextStyle(color: Colors.white),
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

    if (shouldDelete != true) {
      return;
    }

    try {
      final result = await MeasurementService.deleteMeasurement(
        context: context,
        measurementId: measurementId,
      );

      if (result) {
        await warningDialog(
          context,
          message: 'Ölçüm kaydı başarıyla silindi.',
          path: BlocTheme.theme.attentionSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );

        // Ölçümlerim sayfasına geri dön ve yenileme sinyali gönder
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        // Hata durumunda response body'den mesaj al
        final response = await RequestUtil.delete(
          GymTrainingUrlConstants.getDeleteMeasurementUrl(
            context.read<ExternalApplicationsConfigCubit>().state!.gymTraining,
            measurementId,
          ),
          token: await JwtStorageService.getToken() as String,
        );

        String errorMessage = 'Ölçüm kaydı silinemedi, lütfen daha sonra tekrar deneyiniz.';
        if (response != null) {
          final customMessage = MeasurementService.getDeleteErrorMessage(response.body);
          if (customMessage != null) {
            errorMessage = customMessage;
          }
        }

        await warningDialog(
          context,
          message: errorMessage,
          path: BlocTheme.theme.errorSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );
      }
    } catch (e) {
      await warningDialog(
        context,
        message: 'Bir hata oluştu: $e',
        path: BlocTheme.theme.errorSvgPath,
        buttonColor: BlocTheme.theme.default500Color,
        buttonTextColor: BlocTheme.theme.defaultBlackColor,
      );
    }
  }

}
