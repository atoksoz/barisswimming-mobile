import 'package:e_sport_life/screen/panel/common/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'config/ability/mobile_ability_cubit.dart';
import 'config/app-config/app_config_cubit.dart';
import 'config/app-content/app_content_cubit.dart';
import 'config/external-applications-config/external_applications_config_cubit.dart';
import 'config/themes/bloc_theme.dart';
import 'config/user-config/user_config_cubit.dart';
import 'config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'config/announcement/announcement_cubit.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: BlocTheme.theme.defaultAppBarColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const String id = 'signin'; // BUNU EKLEMELİSİN

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BlocTheme>(
          create: (_) => BlocTheme(BlocTheme.theme.data),
        ),
        BlocProvider<AppConfigCubit>(
          create: (_) => AppConfigCubit()..loadConfig(),
        ),
        BlocProvider<UserConfigCubit>(
          create: (_) => UserConfigCubit()..loadUserConfig(),
        ),
        BlocProvider<ExternalApplicationsConfigCubit>(
          create: (_) => ExternalApplicationsConfigCubit()
            ..loadExternalApplicationsConfig(),
        ),
        BlocProvider<MobileAppSettingsCubit>(
          create: (_) => MobileAppSettingsCubit()..loadFromCache(),
        ),
        BlocProvider<AnnouncementCubit>(
          create: (_) => AnnouncementCubit(),
        ),
        BlocProvider<MobileAbilityCubit>(
          create: (_) => MobileAbilityCubit()..loadFromCache(),
        ),
        BlocProvider<AppContentCubit>(
          create: (_) => AppContentCubit()..loadFromCache(),
        ),
      ],
      child: BlocBuilder<BlocTheme, ThemeData>(
        builder: (context, themeData) {
          /*
          Future.microtask(() {
            context
                .read<ExternalApplicationsConfigCubit>()
                .loadExternalApplicationsConfig();
          });
*/
          return MaterialApp(
            title: 'Barış Swimming',
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr', 'TR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            theme: themeData,
            home: const SplashScreen(),
            routes: {
              MyHomePage.id: (context) => const SplashScreen(),
            },
          );
        },
      ),
    );
  }
}
