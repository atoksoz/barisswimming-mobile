import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/constants/employee_profession.dart';
import 'package:e_sport_life/core/constants/url/randevu_al_url_constants.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/social_icon_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/core/widgets/vote_trainer_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:profile_photo/profile_photo.dart';

/// Eğitmen detay sayfası — hem member hem de panel kullanıcıları tarafından
/// görüntülenebilir. Değerlendirme butonu yalnızca member rolündeyken görünür.
class TrainerDetailScreen extends StatefulWidget {
  final String trainerId;
  final String name;
  final String duty;
  /// Virgüllü meslek anahtarları; `duty` boşken yetenek satırı için kullanılır.
  final String profession;
  final String explanation;
  final String image;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? twitterUrl;
  final String? youtubeUrl;
  final String? rate;

  const TrainerDetailScreen({
    Key? key,
    required this.trainerId,
    required this.name,
    required this.duty,
    this.profession = '',
    required this.explanation,
    required this.image,
    this.facebookUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.twitterUrl,
    this.youtubeUrl,
    this.rate,
  }) : super(key: key);

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  static const double _photoSize = 120.0;
  static const double _socialIconSize = 44.0;

  ImageProvider? _imageProvider;
  late int _rate;

  @override
  void initState() {
    super.initState();
    _rate = int.tryParse(widget.rate ?? '') ?? 0;
    _loadImage();
  }

  void _loadImage() {
    if (widget.image.isNotEmpty) {
      _imageProvider = NetworkImage(widget.image);
    }
  }

  Future<bool> _vote(int rateData) async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      final url = RandevuAlUrlConstants.getTrainerVoteUrl(
          externalConfig!.onlineReservation);
      final token = await JwtStorageService.getToken() as String;

      final response = await RequestUtil.post(
        url,
        body: {"trainer_id": widget.trainerId, "rate": rateData},
        token: token,
      );
      final json = jsonDecode(response!.body) as Map<String, dynamic>;
      if (json["output"] == true) {
        setState(() => _rate = rateData);
        return true;
      }
    } catch (_) {}
    return false;
  }

  bool get _isMember {
    final userConfig = context.read<UserConfigCubit>().state;
    return userConfig?.userType == MobileUserType.member;
  }

  String get _dutyLabel => EmployeeProfession.getLabels(
        widget.profession.trim().isNotEmpty ? widget.profession : widget.duty,
      );

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: widget.name.toUpperCase()),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: theme.defaultWhiteColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    blurStyle: BlurStyle.outer,
                    color: theme.defaultGray900Color,
                    offset: Offset.zero,
                    spreadRadius: 1,
                  )
                ],
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPhoto(theme),
                  const SizedBox(height: 10),
                  Text(
                    widget.name,
                    maxLines: 1,
                    style: theme.textLabel(color: theme.defaultGray700Color)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _dutyLabel,
                    style: theme.textSmallSemiBold(color: theme.defaultGray900Color),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                      widget.explanation,
                      style: theme.textBody(color: theme.defaultGray700Color),
                    ),
                  ),
                  _buildSocialIcons(theme),
                ],
              ),
            ),
          ),
          if (_isMember) _buildRateButton(theme, labels),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  Widget _buildPhoto(dynamic theme) {
    return Row(
      children: [
        Expanded(
          child: _imageProvider != null
              ? ClipOval(
                  child: SizedBox(
                    width: _photoSize,
                    height: _photoSize,
                    child: ProfilePhoto(
                      totalWidth: _photoSize,
                      cornerRadius: _photoSize,
                      color: Colors.transparent,
                      outlineColor: Colors.transparent,
                      outlineWidth: 0,
                      textPadding: 0,
                      nameDisplayOption: NameDisplayOptions.initials,
                      image: _imageProvider,
                      onTap: () => _showFullImage(),
                    ),
                  ),
                )
              : SvgPicture.asset(
                  BlocTheme.theme.userSvgPath,
                  fit: BoxFit.contain,
                  width: _photoSize,
                  height: _photoSize,
                ),
        ),
      ],
    );
  }

  void _showFullImage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(image: _imageProvider!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcons(dynamic theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SocialIcon(
            url: widget.facebookUrl ?? "",
            assetPath: BlocTheme.theme.facebookSvgPath,
            height: _socialIconSize,
            width: _socialIconSize,
          ),
          const SizedBox(width: 24),
          SocialIcon(
            url: widget.instagramUrl ?? "",
            assetPath: BlocTheme.theme.instagramSvgPath,
            height: _socialIconSize,
            width: _socialIconSize,
          ),
          const SizedBox(width: 24),
          SocialIcon(
            url: widget.tiktokUrl ?? "",
            assetPath: BlocTheme.theme.tiktokSvgPath,
            height: _socialIconSize,
            width: _socialIconSize,
          ),
          const SizedBox(width: 24),
          SocialIcon(
            url: widget.twitterUrl ?? "",
            assetPath: BlocTheme.theme.twitterSvgPath,
            height: _socialIconSize,
            width: _socialIconSize,
          ),
          const SizedBox(width: 24),
          SocialIcon(
            url: widget.youtubeUrl ?? "",
            assetPath: BlocTheme.theme.youtubeSvgPath,
            height: _socialIconSize,
            width: _socialIconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildRateButton(dynamic theme, AppLabels labels) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () async {
                final rating = await voteTrainerDialog(
                  context,
                  message: widget.name,
                  initialStar: _rate,
                );
                if (rating != null) _vote(rating);
              },
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.defaultWhiteColor,
                  border: Border.all(color: theme.default800Color),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: 32, color: theme.default800Color),
                      const SizedBox(width: 12),
                      Text(
                        labels.rateTrainer,
                        style: theme.textBodyBold(
                            color: theme.default800Color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
