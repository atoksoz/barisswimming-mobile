import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/swimming_course/swimming_course_pool_locations_service.dart';
import 'package:e_sport_life/core/utils/maps_launch_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/randevu_v2_group_lesson_location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Yüzme kursu — Randevu’daki havuz (grup ders lokasyonu) listesi; haritada aç.
///
/// [useMemberPoolEndpoint]: üye `pool-locations`, eğitmen `group-lesson-locations`.
///
/// [bottomNavTab]: alt menüde vurgulanacak sekme (ör. ana sayfadan açılırsa [NavTab.home]).
class SwimmingCoursePoolsScreen extends StatefulWidget {
  const SwimmingCoursePoolsScreen({
    super.key,
    required this.useMemberPoolEndpoint,
    this.bottomNavTab = NavTab.profile,
  });

  final bool useMemberPoolEndpoint;
  final NavTab bottomNavTab;

  @override
  State<SwimmingCoursePoolsScreen> createState() =>
      _SwimmingCoursePoolsScreenState();
}

class _SwimmingCoursePoolsScreenState extends State<SwimmingCoursePoolsScreen> {
  List<RandevuV2GroupLessonLocationModel> _items = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final config = context.read<ExternalApplicationsConfigCubit>().state;
      final randevuUrl = config?.onlineReservation.trim() ?? '';
      if (randevuUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _items = const [];
            _loading = false;
            _errorMessage = AppLabels.current.error;
          });
        }
        return;
      }

      final list = widget.useMemberPoolEndpoint
          ? await SwimmingCoursePoolLocationsService.fetchForMember(
              randevuBaseUrl: randevuUrl,
            )
          : await SwimmingCoursePoolLocationsService.fetchForTrainer(
              randevuBaseUrl: randevuUrl,
            );

      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _errorMessage = AppLabels.current.error;
      });
    }
  }

  Future<void> _openMaps(RandevuV2GroupLessonLocationModel pool) async {
    await MapsLaunchUtil.openSwimmingPoolLocation(pool);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.profileMenuSwimmingPoolsTitle),
      body: RefreshIndicator(
        color: theme.default500Color,
        onRefresh: _load,
        child: _buildBody(theme, labels),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: widget.bottomNavTab),
    );
  }

  Widget _buildBody(BaseTheme theme, AppLabels labels) {
    if (_loading) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(child: LoadingIndicatorWidget()),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: _EmptyOrErrorState(
              theme: theme,
              icon: Icons.cloud_off_outlined,
              iconColor: theme.defaultGray400Color,
              title: labels.error,
              subtitle: _errorMessage!,
              isError: true,
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Padding(
              padding: theme.panelPagePadding,
              child: Center(
                child: _EmptyOrErrorState(
                  theme: theme,
                  icon: Icons.pool_outlined,
                  iconColor: theme.default900Color,
                  title: labels.noData,
                  subtitle: null,
                  isError: false,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final pool = _items[index];
        final canOpen = pool.mapsLaunchUri != null;
        return _PoolCard(
          pool: pool,
          theme: theme,
          labels: labels,
          canOpenInMaps: canOpen,
          onOpenMaps: canOpen ? () => _openMaps(pool) : null,
        );
      },
    );
  }
}

/// Ortalanmış boş / hata durumu — panel ikon çemberi + tipografi.
class _EmptyOrErrorState extends StatelessWidget {
  const _EmptyOrErrorState({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.isError,
  });

  final BaseTheme theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: theme.defaultWhiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.defaultBlackColor.withValues(alpha: 0.06),
                blurRadius: theme.panelListCardShadowBlur,
                offset: Offset(0, theme.panelListCardShadowOffsetY),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: iconColor),
        ),
        SizedBox(height: theme.panelSectionSpacing),
        Text(
          title,
          textAlign: TextAlign.center,
          style: isError
              ? theme.textBodyBold(color: theme.defaultRed700Color)
              : theme.panelTitleStyle,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          SizedBox(height: theme.panelTightVerticalGap + 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.panelBodyStyle.copyWith(
                color: theme.panelSubTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PoolCard extends StatelessWidget {
  const _PoolCard({
    required this.pool,
    required this.theme,
    required this.labels,
    required this.canOpenInMaps,
    required this.onOpenMaps,
  });

  final RandevuV2GroupLessonLocationModel pool;
  final BaseTheme theme;
  final AppLabels labels;
  final bool canOpenInMaps;
  final VoidCallback? onOpenMaps;

  String? get _coordSubtitle {
    final lat = pool.latitude;
    final lng = pool.longitude;
    if (lat == null && lng == null) return null;
    if (lat != null && lng != null) {
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
    if (lat != null) return lat.toStringAsFixed(5);
    return lng!.toStringAsFixed(5);
  }

  /// Koordinat satırı veya konum yok uyarısı ([address] ayrı gösterilir).
  String? get _detailLineAfterAddress {
    final coord = _coordSubtitle;
    if (coord != null && coord.isNotEmpty) return coord;
    if (!canOpenInMaps) return labels.swimmingPoolNoLocationHint;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final addressLine = pool.address?.trim();
    final detailLine = _detailLineAfterAddress;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canOpenInMaps ? onOpenMaps : null,
        borderRadius: BorderRadius.circular(theme.panelCardRadius),
        child: Container(
          margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
          decoration: BoxDecoration(
            color: theme.defaultGray100Color,
            border: Border.all(color: theme.defaultGray200Color),
            borderRadius:
                BorderRadius.all(Radius.circular(theme.panelCardRadius)),
            boxShadow: [
              BoxShadow(
                color: theme.defaultBlackColor
                    .withValues(alpha: theme.panelListCardShadowOpacity),
                blurRadius: theme.panelListCardShadowBlur,
                offset: Offset(0, theme.panelListCardShadowOffsetY),
                spreadRadius: theme.panelListCardShadowSpread,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 46,
                  height: 46,
                  child: Center(
                    child: Icon(
                      Icons.pool_outlined,
                      size: 28,
                      color: theme.default900Color,
                    ),
                  ),
                ),
                SizedBox(width: theme.panelInlineLeadingGap),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pool.displayLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textBodyBold(
                          color: theme.default900Color,
                        ),
                      ),
                      if (addressLine != null && addressLine.isNotEmpty) ...[
                        SizedBox(height: theme.panelTightVerticalGap + 2),
                        Text(
                          addressLine,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textCaption(
                            color: theme.defaultGray900Color,
                          ),
                        ),
                      ],
                      if (detailLine != null && detailLine.isNotEmpty) ...[
                        SizedBox(height: theme.panelTightVerticalGap + 2),
                        Text(
                          detailLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textCaption(
                            color: theme.defaultGray900Color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 26,
                      color: canOpenInMaps
                          ? theme.default500Color
                          : theme.defaultGray400Color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels.openInMaps,
                      style: theme.textMini(
                        color: canOpenInMaps
                            ? theme.default700Color
                            : theme.defaultGray400Color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
