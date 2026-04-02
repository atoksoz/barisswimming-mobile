import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_sport_life/core/services/mobile_ability_service.dart';

class MobileAbilityState {
  final MobileAbilityService service;

  const MobileAbilityState(this.service);

  bool canView(String subject) => service.canView(subject);
  bool canManage(String subject) => service.canManage(subject);
  bool get hasAllAccess => service.hasAllAccess;
}

class MobileAbilityCubit extends Cubit<MobileAbilityState> {
  final MobileAbilityService _service = MobileAbilityService();

  MobileAbilityCubit() : super(MobileAbilityState(MobileAbilityService()));

  Future<void> loadFromApi(List<dynamic> rawAbilities) async {
    _service.load(rawAbilities);
    await _service.saveToCache();
    emit(MobileAbilityState(_service));
  }

  Future<void> loadFromCache() async {
    await _service.loadFromCache();
    emit(MobileAbilityState(_service));
  }

  Future<void> clear() async {
    await _service.clearCache();
    emit(MobileAbilityState(MobileAbilityService()));
  }
}
