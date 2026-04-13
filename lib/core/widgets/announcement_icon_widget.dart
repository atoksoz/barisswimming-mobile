import 'package:e_sport_life/config/announcement/announcement_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/screen/panel/common/announcement/announcements_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnnouncementIconWidget extends StatelessWidget {
  const AnnouncementIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    return BlocBuilder<AnnouncementCubit, AnnouncementState>(
      builder: (context, announcementState) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AnnouncementsListScreen(),
            ),
          ),
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: theme.default300Color,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: SvgPicture.asset(
                    theme.annoucementSvgPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                if (announcementState.hasNewAnnouncement)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: theme.defaultRed700Color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.defaultWhiteColor,
                          width: 1.5,
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
}
