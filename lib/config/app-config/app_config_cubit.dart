import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppConfigState {
  final String appDisplayName;
  final String welcomeMessage;
  final String developer;

  AppConfigState({
    required this.appDisplayName,
    required this.welcomeMessage,
    required this.developer,
  });

  factory AppConfigState.initial() {
    return AppConfigState(
      appDisplayName: '',
      welcomeMessage: '',
      developer: '',
    );
  }
}

class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(AppConfigState.initial());

  Future<void> loadConfig() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/config/app_config.json');
      final jsonMap = json.decode(jsonString);

      final appDisplayName = jsonMap['app_display_name'] ?? '';
      final welcomeMessage = jsonMap['welcome_message'] ?? '';
      final developer = jsonMap['developer'] ?? '';

      emit(AppConfigState(
          appDisplayName: appDisplayName,
          welcomeMessage: welcomeMessage,
          developer: developer));
    } catch (e) {
      print('Config yüklenirken hata oluştu: $e');
      // Hata durumunda varsayılan değerleri tut
      emit(AppConfigState.initial());
    }
  }
}
