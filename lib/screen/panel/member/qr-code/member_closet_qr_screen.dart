import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/screen/panel/common/dynamic_qr_screen.dart';
import 'package:flutter/material.dart';

/// Dolap açma QR ekranı.
/// [DynamicQrScreen] üzerine AppBar ve BottomNavigationBar ekler.
class MemberClosetQrScreen extends StatelessWidget {
  const MemberClosetQrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBarWidget(
        title: AppLabels.current.qrCode,
      ),
      body: const DynamicQrScreen(),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.home,
      ),
    );
  }
}
