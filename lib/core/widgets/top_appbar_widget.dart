import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const TopAppBarWidget({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      elevation: 2.0,
      backgroundColor: Colors.transparent,
      actions: actions,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            size: 34, color: BlocTheme.theme.default900Color),
        // `Navigator.pop` aynı karede `didPop` ile çakışırsa `_debugLocked` assert’i tetiklenebilir;
        // sonraki karede `maybePop` güvenli. Kayıt sonucu bu ekrandan `Navigator.pop(context, record)` ile gelir.
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).maybePop();
            }
          });
        },
      ),
      iconTheme: IconThemeData(color: BlocTheme.theme.default900Color),
      flexibleSpace: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              //backgroundSvgPath,
              BlocTheme.theme.appBarTopSvgPath,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      title: Text(
        title,
        style: BlocTheme.theme.textTitleSemiBold(
            color: BlocTheme.theme.defaultGray900Color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
