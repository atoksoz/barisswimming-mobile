import 'package:e_sport_life/config/themes/supported_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../unshared/theme/application_theme.dart';
import 'base_theme.dart';

class BlocTheme extends Bloc<SupportedTheme, ThemeData> {
  static BaseTheme theme = ApplicationTheme.getApplicationTheme();
  BlocTheme(super.initialState);

  static SystemUiOverlayStyle uiOverlayStyle() =>
      (theme.data.brightness == Brightness.light
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: theme.data.primaryColor);

  @override
  ThemeData get initialState => theme.data;
}
