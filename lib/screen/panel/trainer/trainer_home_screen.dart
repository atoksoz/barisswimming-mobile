import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/screen/panel/trainer/default_trainer_home_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/swimming-course/swimming_course_trainer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Eğitmen ana sayfa — `swimming_course` için [SwimmingCourseTrainerHomeScreen],
/// diğer uygulama tipleri için [DefaultTrainerHomeScreen].
class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appType = context.watch<UserConfigCubit>().state?.applicationType ??
        ApplicationType.openGym;
    if (appType.isSwimmingCourse) {
      return const SwimmingCourseTrainerHomeScreen();
    }
    return const DefaultTrainerHomeScreen();
  }
}
