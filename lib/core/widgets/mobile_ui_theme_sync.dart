import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/unshared/theme/application_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cache veya API’den gelen `mobile_ui_accent` ile [BlocTheme] ve status bar’ı günceller.
class MobileUiThemeSync extends StatefulWidget {
  const MobileUiThemeSync({super.key, required this.child});

  final Widget child;

  @override
  State<MobileUiThemeSync> createState() => _MobileUiThemeSyncState();
}

class _MobileUiThemeSyncState extends State<MobileUiThemeSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapAccent());
  }

  Future<void> _bootstrapAccent() async {
    final cubit = context.read<MobileAppSettingsCubit>();
    await cubit.loadFromCache();
    if (!mounted) return;
    if (kDebugMode) {
      final s = cubit.state;
      debugPrint(
        '[MobileUiThemeSync] bootstrap cache mobileUiAccent="${s?.mobileUiAccent ?? "(null)"}"',
      );
    }
    _applyAccent(context, cubit.state);
  }

  void _applyAccent(BuildContext context, MobileAppSettings? settings) {
    final raw = settings?.mobileUiAccent;
    final next = ApplicationTheme.supportedThemeFromMobileAccent(raw);
    if (kDebugMode) {
      debugPrint('[MobileUiThemeSync] apply raw="$raw" -> $next');
    }
    context.read<BlocTheme>().add(next);
    final bar = ApplicationTheme.themeFor(next).defaultAppBarColor;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: bar,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MobileAppSettingsCubit, MobileAppSettings?>(
      listenWhen: (previous, current) =>
          (previous?.mobileUiAccent ?? '') != (current?.mobileUiAccent ?? ''),
      listener: (context, settings) {
        _applyAccent(context, settings);
      },
      child: widget.child,
    );
  }
}
