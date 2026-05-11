import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/screen/panel/trainer/common/home/default_trainer_home_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/muzik-okulum/muzik_okulum_trainer_home_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/swimming-course/swimming_course_trainer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Eğitmen ana sayfa — `swimming_course` için [SwimmingCourseTrainerHomeScreen],
/// `muzik_okulum` için [MuzikOkulumTrainerHomeScreen],
/// diğerleri için [DefaultTrainerHomeScreen].
class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appType = context.watch<UserConfigCubit>().state?.applicationType ??
        ApplicationType.openGym;
    if (appType.isSwimmingCourse) {
      return const SwimmingCourseTrainerHomeScreen();
    }
    if (appType.isMusicSchool) {
      return const MuzikOkulumTrainerHomeScreen();
    }
    return const DefaultTrainerHomeScreen();
  }
}
