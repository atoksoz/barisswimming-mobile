import 'dart:io';
import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/measurement_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/utils/image_compression_util.dart';
import 'package:e_sport_life/core/widgets/measurement_input_form_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import '../../config/external-applications-config/external_applications_config_cubit.dart';
import '../../data/model/package_model.dart';

class MeasurementAddScreen extends StatefulWidget {
  const MeasurementAddScreen({super.key});

  @override
  State<MeasurementAddScreen> createState() => _MeasurementAddScreenState();
}


class _MeasurementAddScreenState extends State<MeasurementAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _armController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  final List<SelectedAttachment> _attachments = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  /// Aktif gym üyelik kaydının ID'sini al
  Future<int?> _getActiveGymMemberRegisterId() async {
    try {
      final externalApplicationConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = HamamSpaUrlConstants.getGymMemberRegisterUrl(
          externalApplicationConfig!.hamamspaApiUrl);
      final String token = await JwtStorageService.getToken() as String;
      var response = await RequestUtil.get(url, token: token);
      
      if (response == null) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> output = json["output"] ?? [];
      
      if (output.isEmpty) {
        return null;
      }

      // İlk aktif kaydı al (genelde en son aktif olan)
      for (var item in output) {
        // JSON'dan direkt id alanını oku
        if (item is Map<String, dynamic> && item.containsKey('id')) {
          final idValue = item['id'];
          if (idValue != null) {
            final idInt = int.tryParse(idValue.toString());
            if (idInt != null) {
              return idInt;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('Get active gym member register id error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _shoulderController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    // Maksimum 5 dosya kontrolü
    if (_attachments.length >= 5) {
      await warningDialog(
        context,
        message: 'Maksimum 5 dosya ekleyebilirsiniz.',
        path: BlocTheme.theme.attentionSvgPath,
        buttonColor: BlocTheme.theme.default500Color,
        buttonTextColor: BlocTheme.theme.defaultBlackColor,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      int remainingSlots = 5 - _attachments.length;
      int filesToAdd = result.files.length > remainingSlots 
          ? remainingSlots 
          : result.files.length;

      List<String> oversizedFiles = [];
      List<File> imagesToProcess = [];
      List<SelectedAttachment> pdfAttachments = [];

      // Önce dosyaları kategorize et
      for (int i = 0; i < filesToAdd; i++) {
        final file = result.files[i];
        if (file.path != null) {
          final fileObj = File(file.path!);
          final fileSizeInBytes = fileObj.lengthSync();
          final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

          // 3 MB kontrolü
          if (fileSizeInMB > 3) {
            oversizedFiles.add(file.name);
            continue;
          }

          final isImage = file.extension?.toLowerCase() == 'jpg' ||
              file.extension?.toLowerCase() == 'jpeg' ||
              file.extension?.toLowerCase() == 'png';

          if (isImage) {
            imagesToProcess.add(fileObj);
          } else {
            // PDF dosyası direkt ekle
            pdfAttachments.add(SelectedAttachment(
              name: file.name,
              path: file.path!,
              isImage: false,
            ));
          }
        }
      }

      // Eğer image dosyası varsa, resize için loading göster
      if (imagesToProcess.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Fotoğraflar işleniyor...',
                        style: TextStyle(
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${imagesToProcess.length} adet',
                        style: TextStyle(
                          color: BlocTheme.theme.defaultGray600Color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          
          // Dialog'un tam render olması ve animasyonun başlaması için bekle
          await Future.delayed(const Duration(milliseconds: 500));
        }

        try {
          // Image'leri resize et
          List<SelectedAttachment> processedImages = [];
          for (var imageFile in imagesToProcess) {
            final resizedFile = await ImageCompressionUtil.resizeImageIfNeeded(imageFile);
            if (resizedFile != null) {
              // Resized dosya kullanılıyorsa original dosyayı sil
              if (resizedFile.path != imageFile.path) {
                try {
                  await imageFile.delete();
                } catch (e) {
                  print('⚠️ Original file delete error: $e');
                }
              }

              processedImages.add(SelectedAttachment(
                name: 'Seçilen-${DateTime.now().millisecondsSinceEpoch}.jpg',
                path: resizedFile.path,
                isImage: true,
              ));
            }
          }

          // Loading dialog'u kapat
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Tüm dosyaları ekle
          if (mounted) {
            setState(() {
              _attachments.addAll(pdfAttachments);
              _attachments.addAll(processedImages);
              _formKey.currentState?.validate();
            });
          }
        } catch (e) {
          // Loading dialog'u kapat
          if (mounted) {
            Navigator.of(context).pop();
            await warningDialog(
              context,
              message: 'Fotoğraflar işlenirken bir hata oluştu: $e',
              path: BlocTheme.theme.errorSvgPath,
              buttonColor: BlocTheme.theme.default500Color,
              buttonTextColor: BlocTheme.theme.defaultBlackColor,
            );
          }
          return;
        }
      } else {
        // Sadece PDF varsa direkt ekle
        if (mounted) {
          setState(() {
            _attachments.addAll(pdfAttachments);
            _formKey.currentState?.validate();
          });
        }
      }

      int addedCount = pdfAttachments.length + imagesToProcess.length;

      // Eğer seçilen dosyalar maksimum sayıyı aşıyorsa uyarı göster
      if (result.files.length > remainingSlots && addedCount > 0) {
        await warningDialog(
          context,
          message: 'Maksimum 5 dosya ekleyebilirsiniz. Seçtiğiniz dosyalardan ${addedCount} tanesi eklendi.',
          path: BlocTheme.theme.attentionSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );
      }

      // 3 MB'dan büyük dosyalar varsa uyarı göster
      if (oversizedFiles.isNotEmpty) {
        await warningDialog(
          context,
          message: 'Bazı dosyalar 3 MB\'dan büyük olduğu için eklenemedi: ${oversizedFiles.join(", ")}',
          path: BlocTheme.theme.errorSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    // Maksimum 5 dosya kontrolü
    if (_attachments.length >= 5) {
      await warningDialog(
        context,
        message: 'Maksimum 5 dosya ekleyebilirsiniz.',
        path: BlocTheme.theme.attentionSvgPath,
        buttonColor: BlocTheme.theme.default500Color,
        buttonTextColor: BlocTheme.theme.defaultBlackColor,
      );
      return;
    }

    print('📷 Fotoğraf çekiliyor...');
    final photoStartTime = DateTime.now();
    final photo = await _imagePicker.pickImage(source: ImageSource.camera);
    print('⏱️ Fotoğraf seçimi süresi: ${DateTime.now().difference(photoStartTime).inMilliseconds}ms');
    
    if (photo != null) {
      print('📸 Fotoğraf seçildi: ${photo.path}');
      final originalFile = File(photo.path);
      
      // Loading göster (resize işlemi uzun sürebilir)
      // Önce dialog'u göster, sonra bir frame bekle ki dialog render olsun
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Fotoğraf işleniyor...',
                      style: TextStyle(
                        color: BlocTheme.theme.default900Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '10 sn. kadar sürebilir',
                      style: TextStyle(
                        color: BlocTheme.theme.defaultGray600Color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        
        // Dialog'un tam render olması ve animasyonun başlaması için bekle
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      print('🔄 Resize işlemi başlatılıyor...');
      try {
        // Resize işlemi yap (1 MB'dan büyükse)
        final resizeStartTime = DateTime.now();
        final resizedFile = await ImageCompressionUtil.resizeImageIfNeeded(originalFile);
        print('⏱️ Resize toplam süresi: ${DateTime.now().difference(resizeStartTime).inMilliseconds}ms');
        
        // Loading dialog'u kapat
        if (mounted) {
          Navigator.of(context).pop();
        }
        
        if (resizedFile == null) {
          await warningDialog(
            context,
            message: 'Fotoğraf işlenirken bir hata oluştu.',
            path: BlocTheme.theme.errorSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
          return;
        }

        // Resized dosya kullanılıyorsa original dosyayı sil (opsiyonel)
        if (resizedFile.path != originalFile.path) {
          try {
            print('🗑️ Orijinal dosya siliniyor...');
            await originalFile.delete();
            print('✅ Orijinal dosya silindi');
          } catch (e) {
            print('⚠️ Original file delete error: $e');
          }
        }

        if (mounted) {
          print('📎 Dosya listeye ekleniyor...');
          setState(() {
            _attachments.add(SelectedAttachment(
              name: 'Kamera-${DateTime.now().millisecondsSinceEpoch}.jpg',
              path: resizedFile.path,
              isImage: true,
            ));
            // Form'u yeniden validate et
            _formKey.currentState?.validate();
          });
          print('✅ Dosya başarıyla eklendi');
        }
      } catch (e) {
        // Loading dialog'u kapat
        if (mounted) {
          Navigator.of(context).pop();
          await warningDialog(
            context,
            message: 'Fotoğraf işlenirken bir hata oluştu: $e',
            path: BlocTheme.theme.errorSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
        }
      }
    }
  }

  void _removeAttachment(SelectedAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
      // Form'u yeniden validate et
      _formKey.currentState?.validate();
    });
  }

  Future<void> _submit() async {
    // Eğer hiç dosya/görsel yoksa ve tüm alanlar boşsa hata ver
    final hasAttachments = _attachments.isNotEmpty;
    final hasAnyFieldFilled = _weightController.text.trim().isNotEmpty ||
        _heightController.text.trim().isNotEmpty ||
        _chestController.text.trim().isNotEmpty ||
        _armController.text.trim().isNotEmpty ||
        _shoulderController.text.trim().isNotEmpty ||
        _waistController.text.trim().isNotEmpty;

    if (!hasAttachments && !hasAnyFieldFilled) {
      await warningDialog(
        context,
        message: 'Lütfen en az bir ölçüm değeri girin veya dosya/görsel ekleyin.',
        path: BlocTheme.theme.attentionSvgPath,
        buttonColor: BlocTheme.theme.default500Color,
        buttonTextColor: BlocTheme.theme.defaultBlackColor,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Attachments yoksa member_register_id zorunlu
      int? memberRegisterId;
      if (!hasAttachments) {
        memberRegisterId = await _getActiveGymMemberRegisterId();
        if (memberRegisterId == null) {
          await warningDialog(
            context,
            message: 'Aktif gym üyelik kaydı bulunamadı. Lütfen tekrar deneyiniz.',
            path: BlocTheme.theme.errorSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
          return;
        }
      }

      final result = await MeasurementService.createMeasurement(
        context: context,
        weight: _weightController.text.trim(),
        height: _heightController.text.trim(),
        chest: _chestController.text.trim(),
        arm: _armController.text.trim(),
        shoulder: _shoulderController.text.trim(),
        waist: _waistController.text.trim(),
        attachments: _attachments,
        memberRegisterId: memberRegisterId,
      );

      if (result) {
        await warningDialog(
          context,
          message: 'Ölçüm bilgisi başarıyla kaydedildi.',
          path: BlocTheme.theme.attentionSvgPath,
          buttonColor: BlocTheme.theme.default500Color,
          buttonTextColor: BlocTheme.theme.defaultBlackColor,
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        await warningDialog(
          context,
          message: 'Ölçüm kaydedilemedi. İnternet bağlantınızı kontrol edip tekrar deneyiniz.',
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
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Widget _buildAttachmentCard(SelectedAttachment attachment) {
    final fileName = attachment.name;
    final isImage = attachment.isImage;
    
    // Dosya boyutunu hesapla
    final file = File(attachment.path);
    final fileSize = file.existsSync() ? file.lengthSync() : 0;
    final fileSizeText = _formatFileSize(fileSize);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(attachment.path),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image,
                      color: BlocTheme.theme.default800Color,
                      size: 56,
                    );
                  },
                ),
              )
            : Icon(
                Icons.picture_as_pdf,
                color: BlocTheme.theme.default800Color,
              ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          fileSizeText,
          style: TextStyle(
            fontSize: 12,
            color: BlocTheme.theme.defaultGray600Color,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.close,
            color: BlocTheme.theme.default900Color,
          ),
          onPressed: () => _removeAttachment(attachment),
        ),
        onTap: () {
          if (isImage) {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Image.file(
                  File(attachment.path),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const PDF().cachedFromUrl(
                    attachment.path.startsWith('http')
                        ? attachment.path
                        : Uri.file(attachment.path).toString(),
                    placeholder: (progress) => Center(
                      child: Text('$progress% yükleniyor...'),
                    ),
                    errorWidget: (error) => Center(
                      child: Text('PDF açılamadı: $error'),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: TopAppBarWidget(
        title: "Ölçüm Ekle",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MeasurementInputFormWidget(
                    weightController: _weightController,
                    heightController: _heightController,
                    chestController: _chestController,
                    armController: _armController,
                    shoulderController: _shoulderController,
                    waistController: _waistController,
                    readOnly: false,
                    attachments: _attachments,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Dosyalar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BlocTheme.theme.default900Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _attachments.length >= 5 ? null : _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Dosya Seç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BlocTheme.theme.default500Color,
                            foregroundColor: BlocTheme.theme.defaultBlackColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: BlocTheme.theme.defaultGray400Color,
                            disabledForegroundColor: BlocTheme.theme.defaultGray600Color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _attachments.length >= 5 ? null : _capturePhoto,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Fotoğraf Çek'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BlocTheme.theme.default500Color,
                            foregroundColor: BlocTheme.theme.defaultBlackColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: BlocTheme.theme.defaultGray400Color,
                            disabledForegroundColor: BlocTheme.theme.defaultGray600Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_attachments.isEmpty)
                    Text(
                      'Henüz dosya seçilmedi.',
                      style: TextStyle(
                        color: BlocTheme.theme.default900Color,
                      ),
                    )
                  else
                    Column(
                      children:
                          _attachments.map(_buildAttachmentCard).toList(),
                    ),
                  if (_attachments.isNotEmpty && _attachments.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${_attachments.length}/5 dosya seçildi',
                        style: TextStyle(
                          color: BlocTheme.theme.defaultGray600Color,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (_attachments.length >= 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Maksimum dosya sayısına ulaşıldı (5/5)',
                        style: TextStyle(
                          color: BlocTheme.theme.defaultRed700Color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlocTheme.theme.default500Color,
                        foregroundColor: BlocTheme.theme.defaultBlackColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Kaydet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

