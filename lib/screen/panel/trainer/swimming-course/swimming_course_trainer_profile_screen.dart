import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/profile_menu_widget.dart';
import 'package:e_sport_life/screen/aboutus-screen/about_us_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/kvkk_screen.dart';
import 'package:e_sport_life/screen/panel/member/swimming-course/swimming_course_pools_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/common/profile/trainer_profile_edit_screen.dart';
import 'package:e_sport_life/screen/panel/common/trainer/trainer_list_screen.dart';
import 'package:flutter/material.dart';

class SwimmingCourseTrainerProfileScreen extends StatelessWidget {
  const SwimmingCourseTrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    final menuItems = <ProfileMenuItem>[
      ProfileMenuItem(
        title: labels.myProfile,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TrainerProfileEditScreen())),
      ),
      ProfileMenuItem(
        title: labels.profileMenuSwimmingPoolsTitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const SwimmingCoursePoolsScreen(
              useMemberPoolEndpoint: false,
            ),
          ),
        ),
      ),
      ProfileMenuItem(
        title: labels.trainerRoster,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TrainerListScreen())),
      ),
      ProfileMenuItem(
        title: labels.kvkkTitle,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => Kvkk())),
      ),
      ProfileMenuItem(
        title: labels.about,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AboutUsPage())),
      ),
    ];

    return Scaffold(
      appBar: null,
      body: Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
        child: ListView(
          reverse: false,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              children: menuItems
                  .map((item) => ProfileMenuCard(item: item))
                  .toList(),
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }
}
