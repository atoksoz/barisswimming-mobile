import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/screen/panel/trainer/common/profile/default_trainer_profile_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/muzik-okulum/muzik_okulum_trainer_profile_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/swimming-course/swimming_course_trainer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Eğitmen profil menüsü — `swimming_course` için [SwimmingCourseTrainerProfileScreen],
/// `muzik_okulum` için [MuzikOkulumTrainerProfileScreen],
/// diğerleri için [DefaultTrainerProfileScreen].
class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appType = context.watch<UserConfigCubit>().state?.applicationType ??
        ApplicationType.openGym;
    if (appType.isSwimmingCourse) {
      return const SwimmingCourseTrainerProfileScreen();
    }
    if (appType.isMusicSchool) {
      return const MuzikOkulumTrainerProfileScreen();
    }
    return const DefaultTrainerProfileScreen();
  }
}
