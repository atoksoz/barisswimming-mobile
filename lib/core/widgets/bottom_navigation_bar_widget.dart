import 'package:e_sport_life/config/mobile-app-settings/mobile_app_settings_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/config/user-config/user_config_cubit.dart';
import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/core/enums/mobile_user_type.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:e_sport_life/screen/panel/common/tabs/tabs_screen.dart';

/// Alt menüde hangi sekmenin seçili olduğunu belirten enum.
/// Roller arasında index kayması olmadan doğru tab'ı seçer.
enum NavTab { home, account, qr, shop, members, profile }

class BottomNavigationBarWidget extends StatelessWidget {
  final NavTab tab;

  BottomNavigationBarWidget({
    Key? key,
    required this.tab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final userConfig = context.read<UserConfigCubit>().state;
    final userType = userConfig?.userType ?? MobileUserType.member;
    final tabOrder = _getTabOrder(userType, context);
    final gButtons = _buildGButtons(tabOrder);
    final selectedIndex = _resolveIndex(tab, tabOrder);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          color: theme.default500Color,
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            rippleColor: theme.default500Color,
            hoverColor: theme.default900Color,
            gap: 8,
            activeColor: theme.default900Color,
            iconSize: 32,
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            duration: const Duration(milliseconds: 500),
            tabBackgroundColor: theme.defaultGray100Color,
            color: theme.defaultBlackColor,
            tabs: gButtons,
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Tabs(index: index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<NavTab> _getTabOrder(MobileUserType userType, BuildContext context) {
    switch (userType) {
      case MobileUserType.trainer:
        return [NavTab.home, NavTab.profile];
      case MobileUserType.moderator:
        return [NavTab.home, NavTab.qr, NavTab.profile];
      case MobileUserType.admin:
        return [NavTab.home, NavTab.members, NavTab.qr, NavTab.profile];
      case MobileUserType.member:
        final appType = context.read<UserConfigCubit>().state?.applicationType ??
            ApplicationType.openGym;
        if (appType.usesSchoolStyleMemberPanel) {
          return [NavTab.home, NavTab.qr, NavTab.profile];
        }
        final settings = context.read<MobileAppSettingsCubit>().state;
        final showShop = settings?.showGymExxtraShop ?? false;
        return [
          NavTab.home,
          NavTab.account,
          NavTab.qr,
          if (showShop) NavTab.shop,
          NavTab.profile,
        ];
    }
  }

  int _resolveIndex(NavTab tab, List<NavTab> tabOrder) {
    final index = tabOrder.indexOf(tab);
    return index >= 0 ? index : 0;
  }

  List<GButton> _buildGButtons(List<NavTab> tabOrder) {
    final labels = AppLabels.current;
    return tabOrder.map((t) {
      switch (t) {
        case NavTab.home:
          return GButton(icon: Icons.home, text: labels.home);
        case NavTab.account:
          return GButton(icon: Icons.shopping_basket, text: labels.account);
        case NavTab.qr:
          return GButton(icon: Icons.qr_code_2, text: labels.qrCode);
        case NavTab.shop:
          return GButton(icon: Icons.shopping_cart, text: labels.shop);
        case NavTab.members:
          return GButton(icon: Icons.people, text: labels.members);
        case NavTab.profile:
          return GButton(icon: Icons.person, text: labels.profile);
      }
    }).toList();
  }
}
