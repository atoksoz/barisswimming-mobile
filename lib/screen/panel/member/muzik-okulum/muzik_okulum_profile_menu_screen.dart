import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/profile_menu_widget.dart';
import 'package:e_sport_life/screen/aboutus-screen/about_us_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/content_screen.dart';
import 'package:e_sport_life/screen/panel/common/content/kvkk_screen.dart';
import 'package:e_sport_life/screen/panel/common/facility-details/facility_details_screen.dart';
import 'package:e_sport_life/screen/panel/common/trainer-detail/trainer_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/guardian_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/invoice_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/lesson_schedule_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/muzik_okulum_attendance_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/muzik_okulum_member_profile_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/package_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/payment_plan_list_screen.dart';
import 'package:e_sport_life/screen/panel/member/muzik-okulum/statement_list_screen.dart';
import 'package:e_sport_life/screen/panel/common/suggestion-complaint/suggestion_complaint_screen.dart';
import 'package:flutter/material.dart';

class MuzikOkulumProfileMenuScreen extends StatelessWidget {
  const MuzikOkulumProfileMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    final menuItems = <ProfileMenuItem>[
      ProfileMenuItem(
        title: labels.myProfile,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MuzikOkulumMemberProfileScreen(),
              ),
            ),
      ),
      ProfileMenuItem(
        title: labels.profileMenuMyPackages,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PackageListScreen())),
      ),
      ProfileMenuItem(
        title: labels.profileMenuLessonScheduleTitle,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const LessonScheduleScreen())),
      ),
      ProfileMenuItem(
        title: labels.myAttendance,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MuzikOkulumAttendanceScreen())),
      ),
      ProfileMenuItem(
        title: labels.profileMenuPlannedPaymentTitle,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PaymentPlanListScreen())),
      ),
      ProfileMenuItem(
        title: labels.profileMenuStatementTitle,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const StatementListScreen())),
      ),
      ProfileMenuItem(
        title: labels.profileMenuInvoiceInfoTitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const InvoiceListScreen(),
          ),
        ),
      ),
      ProfileMenuItem(
        title: labels.profileMenuGuardianInfoTitle,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const GuardianListScreen(),
          ),
        ),
      ),
      ProfileMenuItem(
        title: labels.trainerRoster,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TrainerListScreen())),
      ),
      ProfileMenuItem(
        title: labels.facilityDetails,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => FacilityDetailsScreen())),
      ),
      ProfileMenuItem(
        title: labels.suggestionComplaint,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => SuggestionComplaint())),
      ),
      ProfileMenuItem(
        title: labels.institutionRules,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContentScreen(
              contentType: ContentType.facilityRules,
              appBarTitle: labels.institutionRules,
            ),
          ),
        ),
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
              children:
                  menuItems.map((item) => ProfileMenuCard(item: item)).toList(),
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }
}
