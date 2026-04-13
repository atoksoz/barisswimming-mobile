import 'package:e_sport_life/config/announcement/announcement_cubit.dart';
import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/announcement_description_preview_util.dart';
import 'package:e_sport_life/core/utils/shared-preferences/announcement_utils.dart'
    as utils;
import 'package:e_sport_life/core/widgets/announcement_detail_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/announcement_model.dart';
import 'package:e_sport_life/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) return;

    final apiUrl = externalConfig.apiHamamspaUrl;
    if (apiUrl.isEmpty) return;

    final token = await JwtStorageService.getToken();
    if (token == null || token.isEmpty) return;

    context.read<AnnouncementCubit>().loadAllAnnouncements(
          apiHamamSpaUrl: apiUrl,
          token: token,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.announcementsAndNotifications),
      body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: LoadingIndicatorWidget());
          }

          if (state.announcements.isEmpty) {
            return Center(
              child: NoDataTextWidget(text: labels.announcementNotFound),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.announcements.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: theme.default200Color,
            ),
            itemBuilder: (context, index) {
              final announcement = state.announcements[index];
              return _AnnouncementTile(
                announcement: announcement,
                theme: theme,
                onFormatDate: DateFormatUtils.formatDateTime,
                onTap: () async {
                  await showAnnouncementDetailDialog(context, announcement);
                  await context
                      .read<AnnouncementCubit>()
                      .markAnnouncementAsSeen(announcement.id);
                  if (mounted) setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final dynamic theme;
  final String Function(String) onFormatDate;
  final VoidCallback onTap;

  const _AnnouncementTile({
    required this.announcement,
    required this.theme,
    required this.onFormatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: utils.isAnnouncementSeen(announcement.id),
      builder: (context, snapshot) {
        final isSeen = snapshot.data ?? false;

        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: theme.textLabelBold(
                            color: theme.defaultBlackColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AnnouncementDescriptionPreviewUtil.preview(
                          announcement.description,
                        ),
                        style: theme.textCaption(
                            color: theme.defaultGray500Color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      onFormatDate(announcement.createdAt),
                      style: theme.textSmallNormal(
                          color: theme.defaultGray600Color),
                    ),
                    if (!isSeen) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.defaultRed700Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
