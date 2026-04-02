import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/user-config/user_config.dart';
import '../../core/utils/shared-preferences/user_config_utils.dart';

class UserConfigCubit extends Cubit<UserConfig?> {
  UserConfigCubit() : super(null);

  Future<void> loadUserConfig() async {
    final config = await loadUserConfigFromSharedPref();
    if (config != null) {
      emit(config);
    }
  }

  void updateUserConfig(UserConfig newConfig) async {
    await saveUserConfigToSharedPref(newConfig);
    emit(newConfig);
  }

  void clearUserConfig() async {
    await saveUserConfigToSharedPref(UserConfig.empty());
    emit(UserConfig.empty());
  }
}
