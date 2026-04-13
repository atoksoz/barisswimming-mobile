import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/profile_menu_widget.dart';
import 'package:e_sport_life/screen/aboutus-screen/about_us_screen.dart';
import 'package:e_sport_life/screen/panel/common/facility-details/facility_details_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/facility_rules_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/group_rules_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/kvkk_screen.dart';
import 'package:e_sport_life/screen/panel/common/action-history/action_history_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/profile/trainer_profile_edit_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/membership_rules_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/service_rules_screen.dart';
import 'package:e_sport_life/screen/panel/common/trainer-detail/trainer_list_screen.dart';
import 'package:flutter/material.dart';

class DefaultTrainerProfileScreen extends StatelessWidget {
  const DefaultTrainerProfileScreen({super.key});

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
        title: labels.pastEntryHistory,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ActionHistoryScreen())),
      ),
      ProfileMenuItem(
        title: labels.facilityDetails,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacilityDetailsScreen())),
      ),
      ProfileMenuItem(
        title: labels.trainerRoster,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TrainerListScreen())),
      ),
      ProfileMenuItem(
        title: labels.groupLessonRules,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => GroupRules())),
      ),
      ProfileMenuItem(
        title: labels.quickReservationRules,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ServiceRules())),
      ),
      ProfileMenuItem(
        title: labels.facilityRules,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => FacilityRules())),
      ),
      ProfileMenuItem(
        title: labels.membershipRules,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => MembershipRules())),
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
