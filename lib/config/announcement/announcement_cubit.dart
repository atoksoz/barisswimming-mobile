import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_sport_life/core/services/announcement_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/announcement_utils.dart'
    as utils;
import 'package:e_sport_life/data/model/announcement_model.dart';

class AnnouncementState {
  final List<AnnouncementModel> announcements;
  final bool hasNewAnnouncement;
  final bool isLoading;

  AnnouncementState({
    required this.announcements,
    required this.hasNewAnnouncement,
    required this.isLoading,
  });

  factory AnnouncementState.initial() {
    return AnnouncementState(
      announcements: [],
      hasNewAnnouncement: false,
      isLoading: false,
    );
  }

  AnnouncementState copyWith({
    List<AnnouncementModel>? announcements,
    bool? hasNewAnnouncement,
    bool? isLoading,
  }) {
    return AnnouncementState(
      announcements: announcements ?? this.announcements,
      hasNewAnnouncement: hasNewAnnouncement ?? this.hasNewAnnouncement,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AnnouncementCubit extends Cubit<AnnouncementState> {
  AnnouncementCubit() : super(AnnouncementState.initial());

  /// En son duyuruyu kontrol et ve yeni duyuru var mı kontrol et
  Future<void> checkLatestAnnouncement({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final latestAnnouncement = await AnnouncementService.fetchLatestAnnouncement(
        apiHamamSpaUrl: apiHamamSpaUrl,
        token: token,
      );

      if (latestAnnouncement != null) {
        final lastCheckedId = await utils.loadLastCheckedAnnouncementId();
        final isSeen = await utils.isAnnouncementSeen(latestAnnouncement.id);
        final hasNew = lastCheckedId != latestAnnouncement.id && !isSeen;

        await utils.saveLastCheckedAnnouncementId(latestAnnouncement.id);

        emit(state.copyWith(
          hasNewAnnouncement: hasNew,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      print('Error checking latest announcement: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Tüm duyuruları yükle
  Future<void> loadAllAnnouncements({
    required String apiHamamSpaUrl,
    required String token,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final announcements = await AnnouncementService.fetchAllAnnouncements(
        apiHamamSpaUrl: apiHamamSpaUrl,
        token: token,
      );

      emit(state.copyWith(
        announcements: announcements,
        hasNewAnnouncement: false,
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading announcements: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Duyuruyu görüldü olarak işaretle
  Future<void> markAnnouncementAsSeen(int announcementId) async {
    await utils.markAnnouncementAsSeen(announcementId);
    
    // En son kontrol edilen duyuru ile karşılaştır
    final lastCheckedId = await utils.loadLastCheckedAnnouncementId();
    
    // Eğer işaretlenen duyuru en son kontrol edilen duyuruysa, yeni duyuru flag'ini temizle
    if (lastCheckedId == announcementId) {
      emit(state.copyWith(hasNewAnnouncement: false));
    }
  }

  /// Yeni duyuru durumunu temizle
  void clearNewAnnouncementFlag() {
    emit(state.copyWith(hasNewAnnouncement: false));
  }
}

