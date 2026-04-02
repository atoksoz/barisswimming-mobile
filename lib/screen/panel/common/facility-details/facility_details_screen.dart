import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/facility_details_service.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/external_applications_config_utils.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/facility_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/image_gallery_popup_widget.dart';

class FacilityDetailsScreen extends StatefulWidget {
  const FacilityDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FacilityDetailsScreen> createState() => _FacilityDetailsScreenState();
}

class _FacilityDetailsScreenState extends State<FacilityDetailsScreen> {
  static const double _galleryHeight = 270.0;
  static const double _borderRadius = 20.0;
  static const double _sectionIconSize = 24.0;

  late Future<FacilityDetailsModel?> _facilityDetailsFuture;

  @override
  void initState() {
    super.initState();
    _facilityDetailsFuture = _fetchFacilityDetails();
  }

  Future<FacilityDetailsModel?> _fetchFacilityDetails() async {
    try {
      final token = await JwtStorageService.getToken();
      if (token == null) return null;

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

      if (externalConfig == null || externalConfig.apiHamamspaUrl.isEmpty) {
        return null;
      }

      return await FacilityDetailsService.getFacilityDetails(
        apiHamamspaUrl: externalConfig.apiHamamspaUrl,
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.facilityDetails),
      body: FutureBuilder<FacilityDetailsModel?>(
        future: _facilityDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicatorWidget());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const Center(child: NoDataTextWidget());
          }

          final facility = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (facility.name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20, 20, 20, 10),
                    child: Text(
                      facility.name,
                      style: theme
                          .textBodyLarge(color: theme.defaultBlackColor)
                          .copyWith(fontSize: 20),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                _buildImageGallery(facility.images, theme, labels),
                if (facility.features.isNotEmpty) ...[
                  _buildDivider(theme),
                  _buildSectionHeader(
                    theme: theme,
                    icon: Icons.business,
                    title: labels.facilityInfo,
                  ),
                  const SizedBox(height: 10),
                  _buildFeaturesTable(facility.features, theme),
                  const SizedBox(height: 10),
                ],
                if (facility.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildSectionHeader(
                    theme: theme,
                    icon: Icons.description,
                    title: labels.description,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20, 10, 20, 0),
                    child: Text(
                      facility.description,
                      style:
                          theme.textSmall(color: theme.defaultBlackColor),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  // ─── Bölüm Başlığı ───

  Widget _buildSectionHeader({
    required dynamic theme,
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      child: Row(
        children: [
          Icon(icon, color: theme.default900Color, size: _sectionIconSize),
          const SizedBox(width: 8),
          Text(title, style: theme.textBodyBold(color: theme.defaultBlackColor)),
        ],
      ),
    );
  }

  Widget _buildDivider(dynamic theme) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 10),
      height: 1,
      color: theme.defaultGray400Color,
    );
  }

  // ─── Resim Galerisi ───

  Widget _buildImageGallery(
      List<String> images, dynamic theme, AppLabels labels) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return Column(
        children: [
          GestureDetector(
            onTap: () => ImageGalleryPopupWidget.show(
              context,
              images: images,
              initialIndex: 0,
            ),
            child: _buildImageCard(
              theme: theme,
              imageUrl: images[0],
              height: _galleryHeight,
              margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
          height: _galleryHeight,
          constraints: const BoxConstraints(maxHeight: _galleryHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => ImageGalleryPopupWidget.show(
                    context,
                    images: images,
                    initialIndex: 0,
                  ),
                  child: _buildImageCard(
                    theme: theme,
                    imageUrl: images[0],
                    margin: const EdgeInsetsDirectional.only(end: 5),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: images.length > 1
                            ? () => ImageGalleryPopupWidget.show(
                                  context,
                                  images: images,
                                  initialIndex: 1,
                                )
                            : null,
                        child: _buildImageCard(
                          theme: theme,
                          imageUrl: images.length > 1 ? images[1] : null,
                          margin: const EdgeInsetsDirectional.only(
                              start: 5, bottom: 2.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: images.length > 2
                            ? () => ImageGalleryPopupWidget.show(
                                  context,
                                  images: images,
                                  initialIndex: 2,
                                )
                            : null,
                        child: _buildImageCardWithOverlay(
                          theme: theme,
                          labels: labels,
                          imageUrl: images.length > 2 ? images[2] : null,
                          extraCount: images.length > 3
                              ? images.length - 3
                              : 0,
                          margin: const EdgeInsetsDirectional.only(
                              start: 5, top: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildImageCard({
    required dynamic theme,
    required String? imageUrl,
    double? height,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            blurStyle: BlurStyle.outer,
            color: theme.defaultBlackColor,
            offset: Offset.zero,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                width: double.infinity,
                height: height ?? double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: height ?? double.infinity,
                  color: theme.defaultGray300Color,
                  child: const Icon(Icons.image_not_supported, size: 30),
                ),
              )
            : Container(color: theme.defaultGray200Color),
      ),
    );
  }

  Widget _buildImageCardWithOverlay({
    required dynamic theme,
    required AppLabels labels,
    required String? imageUrl,
    required int extraCount,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            blurStyle: BlurStyle.outer,
            color: theme.defaultBlackColor,
            offset: Offset.zero,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: imageUrl != null
            ? Stack(
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.defaultGray300Color,
                      child:
                          const Icon(Icons.image_not_supported, size: 20),
                    ),
                  ),
                  if (extraCount > 0)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.defaultBlackColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+$extraCount ${labels.photo}',
                          style: theme
                              .textCaption(color: theme.defaultWhiteColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              )
            : Container(color: theme.defaultGray200Color),
      ),
    );
  }

  // ─── Özellikler Tablosu ───

  Widget _buildFeaturesTable(Map<String, String> features, dynamic theme) {
    final entries = features.entries.toList();

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.defaultGray600Color, width: 1),
      ),
      child: Column(
        children: entries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: index < entries.length - 1
                    ? BorderSide(
                        color: theme.defaultGray600Color, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: theme.defaultGray100Color,
                      border: BorderDirectional(
                        end: BorderSide(
                          color: theme.defaultGray600Color,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme
                          .textSmall(color: theme.defaultBlackColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        12, 10, 12, 10),
                    child: Text(
                      entry.value.isEmpty ? '----' : entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textCaption(
                          color: theme.defaultBlackColor),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Bilgi Tablosu ───

  Widget _buildInformationTable(
      Map<String, String> information, dynamic theme) {
    if (information.isEmpty) return const SizedBox.shrink();

    final entries = information.entries.toList();

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: theme.defaultWhiteColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            blurStyle: BlurStyle.outer,
            color: theme.defaultBlackColor,
            offset: Offset.zero,
            spreadRadius: 1,
          ),
        ],
        borderRadius:
            BorderRadius.all(Radius.circular(_borderRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: index < entries.length - 1
                    ? BorderSide(
                        color: theme.defaultGray300Color, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  20, 12, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: theme
                          .textBody(color: theme.defaultBlackColor)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value.isEmpty ? '----' : entry.value,
                      textAlign: TextAlign.end,
                      style: theme
                          .textBody(color: theme.defaultBlackColor)
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
