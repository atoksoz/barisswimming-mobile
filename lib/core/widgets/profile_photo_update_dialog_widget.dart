import 'dart:io';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/device_uuid_storage_service.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/services/profile_photo_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/utils/image_compression_util.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/screen/panel/common/security-code/security_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoUpdateDialogWidget extends StatefulWidget {
  final ImageProvider? currentImage;
  final Future<Map<String, String>?> Function(File imageFile)? onUpload;
  final Future<Map<String, String>?> Function()? onDelete;

  const ProfilePhotoUpdateDialogWidget({
    Key? key,
    this.currentImage,
    this.onUpload,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ProfilePhotoUpdateDialogWidget> createState() =>
      _ProfilePhotoUpdateDialogWidgetState();
}

class _ProfilePhotoUpdateDialogWidgetState
    extends State<ProfilePhotoUpdateDialogWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isDeleting = false;

  Future<String?> _validateToken() async {
    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop();
        await JwtStorageService.deleteToken();
        await DeviceUuidStorageService.deleteDeviceUuid();
        await warningDialog(
          context,
          message: AppLabels.current.sessionNotFoundReLogin,
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const SecurityCodeScreen()),
            (route) => false,
          );
        }
      }
      return null;
    }
    return token;
  }

  Future<dynamic> _getExternalConfig() async {
    var externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) {
      final storedExternal =
          await loadExternalApplicationsConfigFromSharedPref();
      if (storedExternal != null) {
        context
            .read<ExternalApplicationsConfigCubit>()
            .updateExternalApplicationsConfig(storedExternal);
        externalConfig = storedExternal;
      }
    }
    return externalConfig;
  }

  Future<String?> _getApiUrl() async {
    final externalConfig = await _getExternalConfig();
    if (externalConfig == null) {
      if (mounted) {
        await warningDialog(
          context,
          message: AppLabels.current.apiConnectionNotFound,
        );
      }
      return null;
    }

    final apiUrl = externalConfig.hamamspaApiUrl;
    if (apiUrl.isEmpty) {
      if (mounted) {
        await warningDialog(
          context,
          message: AppLabels.current.apiConnectionNotFound,
        );
      }
      return null;
    }
    return apiUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        final originalFile = File(pickedFile.path);

        final extension = pickedFile.path.toLowerCase().split('.').last;
        if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
          if (mounted) {
            await warningDialog(
              context,
              message: 'Sadece JPG/JPEG/PNG formatında fotoğraf yüklenebilir.',
            );
          }
          return;
        }

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
                        style: BlocTheme.theme.textBody(
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10 sn. kadar sürebilir',
                        style: BlocTheme.theme.textCaption(
                          color: BlocTheme.theme.defaultGray600Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
        }

        try {
          final resizedFile =
              await ImageCompressionUtil.resizeImageIfNeeded(originalFile);

          if (resizedFile == null) {
            if (mounted) {
              Navigator.of(context).pop();
            }
            await warningDialog(
              context,
              message: AppLabels.current.photoUpdateFailed,
              path: BlocTheme.theme.errorSvgPath,
              buttonColor: BlocTheme.theme.default500Color,
              buttonTextColor: BlocTheme.theme.defaultBlackColor,
            );
            return;
          }

          if (resizedFile.path != originalFile.path) {
            try {
              await originalFile.delete();
            } catch (_) {}
          }

          Map<String, String>? result;

          if (widget.onUpload != null) {
            result = await widget.onUpload!(resizedFile);
          } else {
            final token = await _validateToken();
            if (token == null) {
              if (mounted) Navigator.of(context).pop();
              return;
            }

            final apiUrl = await _getApiUrl();
            if (apiUrl == null) {
              if (mounted) Navigator.of(context).pop();
              return;
            }

            result = await ProfilePhotoService.updateProfilePhoto(
              apiHamamSpaUrl: apiUrl,
              token: token,
              imageFile: resizedFile,
            );
          }

          if (mounted) {
            Navigator.of(context).pop();
          }

          if (result != null && mounted) {
            Navigator.of(context).pop(result);
          } else {
            await warningDialog(
              context,
              message: AppLabels.current.photoUpdateFailed,
              path: BlocTheme.theme.errorSvgPath,
              buttonColor: BlocTheme.theme.default500Color,
              buttonTextColor: BlocTheme.theme.defaultBlackColor,
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            await warningDialog(
              context,
              message: '${AppLabels.current.photoUpdateFailed}: $e',
              path: BlocTheme.theme.errorSvgPath,
              buttonColor: BlocTheme.theme.default500Color,
              buttonTextColor: BlocTheme.theme.defaultBlackColor,
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        await warningDialog(
          context,
          message: AppLabels.current.errorOccurred,
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      Map<String, dynamic>? result;

      if (widget.onDelete != null) {
        result = await widget.onDelete!();
      } else {
        final token = await _validateToken();
        if (token == null) {
          if (mounted) setState(() => _isDeleting = false);
          return;
        }

        final apiUrl = await _getApiUrl();
        if (apiUrl == null) {
          if (mounted) setState(() => _isDeleting = false);
          return;
        }

        result = await ProfilePhotoService.deleteProfilePhoto(
          apiHamamSpaUrl: apiUrl,
          token: token,
        );
      }

      if (result != null) {
        final deleteResult = <String, String>{
          'image_url': (result['image_url'] ?? '').toString(),
          'thumb_image_url': (result['thumb_image_url'] ?? '').toString(),
          'deleted': 'true',
        };

        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(deleteResult);
        }
        return;
      } else {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          await warningDialog(
            context,
            message: AppLabels.current.photoUpdateFailed,
            path: BlocTheme.theme.errorSvgPath,
            buttonColor: BlocTheme.theme.default500Color,
            buttonTextColor: BlocTheme.theme.defaultBlackColor,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        if (mounted && Navigator.canPop(context)) {
          try {
            await warningDialog(
              context,
              message: '${AppLabels.current.photoUpdateFailed}: $e',
              path: BlocTheme.theme.errorSvgPath,
              buttonColor: BlocTheme.theme.default500Color,
              buttonTextColor: BlocTheme.theme.defaultBlackColor,
            );
          } catch (_) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: _isDeleting
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoadingIndicatorWidget(),
                        const SizedBox(height: 20),
                        Text(
                          'Fotoğraf siliniyor...',
                          style: BlocTheme.theme.textBody(),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BlocTheme.theme.defaultGray300Color,
                            ),
                            child: widget.currentImage != null
                                ? ClipOval(
                                    child: Image(
                                      image: widget.currentImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: BlocTheme.theme.defaultGray600Color,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: BlocTheme.theme.default500Color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: BlocTheme.theme.defaultWhiteColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: BlocTheme.theme.defaultWhiteColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.currentImage != null
                                  ? _deletePhoto
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    BlocTheme.theme.panelDangerColor,
                                foregroundColor:
                                    BlocTheme.theme.defaultWhiteColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppLabels.current.delete,
                                style: BlocTheme.theme.textBody(
                                  color: BlocTheme.theme.defaultWhiteColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                                Icons.photo_library),
                                            title: Text(AppLabels
                                                .current.chooseFromGallery),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _pickImage(ImageSource.gallery);
                                            },
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.camera_alt),
                                            title: Text(
                                                AppLabels.current.takePhoto),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _pickImage(ImageSource.camera);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.cancel),
                                            title: Text(
                                                AppLabels.current.cancel),
                                            onTap: () =>
                                                Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    BlocTheme.theme.default500Color,
                                foregroundColor:
                                    BlocTheme.theme.defaultWhiteColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppLabels.current.update,
                                style: BlocTheme.theme.textBody(
                                  color: BlocTheme.theme.defaultBlackColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: BlocTheme.theme.default500Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: BlocTheme.theme.defaultBlackColor,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
