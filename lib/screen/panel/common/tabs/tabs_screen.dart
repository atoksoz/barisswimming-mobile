import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings.dart';
import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/screen/explore.dart';
import 'package:e_sport_life/screen/gymexxtra-screen/gymexxtra_shop_screen.dart';
import 'package:e_sport_life/screen/order-screen/order_history_screen.dart';
import 'package:e_sport_life/screen/panel/common/dynamic_qr_screen.dart';
import 'package:e_sport_life/screen/panel/member/profile-menu/member_profile_menu_screen.dart';
import 'package:e_sport_life/screen/panel/member/qr-code/member_qr_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/trainer_home_screen.dart';
import 'package:e_sport_life/screen/panel/trainer/trainer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Tabs extends StatefulWidget {
  const Tabs({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex = 0;
  int _backIndex = 0;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
    _selectedIndex = widget.index;
  }

  // ─── MEMBER ───

  List<Widget> _buildMemberWidgetOptions(bool showMagaza) {
    return [
      Explore(),
      OrderHistory(),
      MemberQrScreen(),
      if (showMagaza) GymexxtraShopScreen(),
      MemberProfileMenuScreen(),
    ];
  }

  List<Widget> _buildMemberHeaderOptions(bool showMagaza) {
    final labels = AppLabels.current;
    return [
      Text('', style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.account, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.qrCode, style: BlocTheme.theme.textTitleSemiBold()),
      if (showMagaza)
        Text(labels.shop, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.profile, style: BlocTheme.theme.textTitleSemiBold()),
    ];
  }

  List<GButton> _buildMemberTabs(bool showMagaza) {
    final labels = AppLabels.current;
    return [
      GButton(icon: Icons.home, text: labels.home),
      GButton(icon: Icons.shopping_basket, text: labels.account),
      GButton(icon: Icons.qr_code_2, text: labels.qrCode),
      if (showMagaza)
        GButton(icon: Icons.shopping_cart, text: labels.shop),
      GButton(icon: Icons.person, text: labels.profile),
    ];
  }

  // ─── TRAINER ───

  List<Widget> _buildTrainerWidgetOptions() {
    return [
      const TrainerHomeScreen(),
      const DynamicQrScreen(),
      const TrainerProfileScreen(),
    ];
  }

  List<Widget> _buildTrainerHeaderOptions() {
    final labels = AppLabels.current;
    return [
      Text('', style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.qrCode, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.profile, style: BlocTheme.theme.textTitleSemiBold()),
    ];
  }

  List<GButton> _buildTrainerTabs() {
    final labels = AppLabels.current;
    return [
      GButton(icon: Icons.home, text: labels.trainer),
      GButton(icon: Icons.qr_code_2, text: labels.qrCode),
      GButton(icon: Icons.person, text: labels.profile),
    ];
  }

  // ─── MODERATOR ───

  List<Widget> _buildModeratorWidgetOptions() {
    return [
      const TrainerHomeScreen(),
      const DynamicQrScreen(),
      const TrainerProfileScreen(),
    ];
  }

  List<Widget> _buildModeratorHeaderOptions() {
    final labels = AppLabels.current;
    return [
      Text('', style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.qrCode, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.profile, style: BlocTheme.theme.textTitleSemiBold()),
    ];
  }

  List<GButton> _buildModeratorTabs() {
    final labels = AppLabels.current;
    return [
      GButton(icon: Icons.home, text: labels.moderator),
      GButton(icon: Icons.qr_code_2, text: labels.qrCode),
      GButton(icon: Icons.person, text: labels.profile),
    ];
  }

  // ─── ADMIN ───

  List<Widget> _buildAdminWidgetOptions() {
    final labels = AppLabels.current;
    return [
      const TrainerHomeScreen(),
      Center(child: Text(labels.members)),
      const DynamicQrScreen(),
      const TrainerProfileScreen(),
    ];
  }

  List<Widget> _buildAdminHeaderOptions() {
    final labels = AppLabels.current;
    return [
      Text('', style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.members, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.qrCode, style: BlocTheme.theme.textTitleSemiBold()),
      Text(labels.profile, style: BlocTheme.theme.textTitleSemiBold()),
    ];
  }

  List<GButton> _buildAdminTabs() {
    final labels = AppLabels.current;
    return [
      GButton(icon: Icons.home, text: labels.admin),
      GButton(icon: Icons.people, text: labels.members),
      GButton(icon: Icons.qr_code_2, text: labels.qrCode),
      GButton(icon: Icons.person, text: labels.profile),
    ];
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserConfigCubit, UserConfig?>(
      builder: (context, userConfig) {
        final userType = userConfig?.userType ?? MobileUserType.member;
        return BlocBuilder<MobileAppSettingsCubit, MobileAppSettings?>(
          builder: (context, settings) {
            final bool showMagaza = settings?.showGymExxtraShop ?? false;

            late final List<Widget> widgetOptions;
            late final List<Widget> headerOptions;
            late final List<GButton> tabs;

            switch (userType) {
              case MobileUserType.trainer:
                widgetOptions = _buildTrainerWidgetOptions();
                headerOptions = _buildTrainerHeaderOptions();
                tabs = _buildTrainerTabs();
              case MobileUserType.moderator:
                widgetOptions = _buildModeratorWidgetOptions();
                headerOptions = _buildModeratorHeaderOptions();
                tabs = _buildModeratorTabs();
              case MobileUserType.admin:
                widgetOptions = _buildAdminWidgetOptions();
                headerOptions = _buildAdminHeaderOptions();
                tabs = _buildAdminTabs();
              case MobileUserType.member:
                widgetOptions = _buildMemberWidgetOptions(showMagaza);
                headerOptions = _buildMemberHeaderOptions(showMagaza);
                tabs = _buildMemberTabs(showMagaza);
            }

            if (_selectedIndex >= widgetOptions.length) {
              _selectedIndex = widgetOptions.length - 1;
            }

            return Scaffold(
              backgroundColor: BlocTheme.theme.defaultBackgroundColor,
              appBar: _selectedIndex == 0
                  ? null
                  : AppBar(
                      automaticallyImplyLeading: true,
                      centerTitle: true,
                      elevation: 2.0,
                      backgroundColor: Colors.transparent,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            size: 34,
                            color: BlocTheme.theme.default900Color),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = _backIndex;
                          });
                        },
                      ),
                      iconTheme: IconThemeData(
                        color: BlocTheme.theme.defaultRed700Color,
                      ),
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              BlocTheme.theme.appBarTopSvgPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      title: headerOptions[_selectedIndex],
                    ),
              body: Center(
                child: widgetOptions.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(50)),
                    color: BlocTheme.theme.default500Color,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10),
                    child: GNav(
                      rippleColor: BlocTheme.theme.default500Color,
                      hoverColor: BlocTheme.theme.default900Color,
                      gap: 8,
                      activeColor: BlocTheme.theme.default900Color,
                      iconSize: 32,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 12),
                      duration: const Duration(milliseconds: 500),
                      tabBackgroundColor:
                          BlocTheme.theme.defaultGray100Color,
                      color: BlocTheme.theme.defaultBlackColor,
                      tabs: tabs,
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _backIndex = _selectedIndex;
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
