import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/shared-preferences/external_applications_config_utils.dart';
import 'external_applications_config.dart';

class ExternalApplicationsConfigCubit
    extends Cubit<ExternalApplicationsConfig?> {
  ExternalApplicationsConfigCubit() : super(null);

  Future<void> loadExternalApplicationsConfig() async {
    final config = await loadExternalApplicationsConfigFromSharedPref();
    emit(config);
  }

  Future<void> setExternalApplicationsConfig(
      ExternalApplicationsConfig config) async {
    await saveExternalApplicationsConfigToSharedPref(
        config); //ExternalApplicationsConfigStorage.save(config);
    emit(config);
  }

  void updateExternalApplicationsConfig(
      ExternalApplicationsConfig newConfig) async {
    await saveExternalApplicationsConfigToSharedPref(newConfig);
    emit(newConfig);
  }

  Future<void> clearExternalApplicationsConfig() async {
    await externalApplicationsConfigClearFromSharedPref();
    emit(null);
  }
}
