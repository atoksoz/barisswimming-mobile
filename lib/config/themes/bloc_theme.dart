import 'package:e_sport_life/config/themes/supported_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../unshared/theme/application_theme.dart';
import 'base_theme.dart';

class BlocTheme extends Bloc<SupportedTheme, ThemeData> {
  BlocTheme()
      : super(ApplicationTheme.initialBaseTheme.data) {
    theme = ApplicationTheme.initialBaseTheme;
    on<SupportedTheme>(_onThemeChanged);
  }

  /// Aktif [BaseTheme]; tema değişince [Bloc] güncellenir.
  static BaseTheme theme = ApplicationTheme.initialBaseTheme;

  static SystemUiOverlayStyle uiOverlayStyle() =>
      (theme.data.brightness == Brightness.light
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: theme.data.primaryColor);

  void _onThemeChanged(SupportedTheme next, Emitter<ThemeData> emit) {
    final BaseTheme resolved = ApplicationTheme.themeFor(next);
    theme = resolved;
    emit(resolved.data);
  }
}
