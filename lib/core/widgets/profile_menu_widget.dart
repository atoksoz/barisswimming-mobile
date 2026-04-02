import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';

class ProfileMenuItem {
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.title,
    required this.onTap,
  });
}

class ProfileMenuCard extends StatelessWidget {
  final ProfileMenuItem item;

  const ProfileMenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;

    return InkWell(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.only(
            top: 10.0, bottom: 10.0, left: 10, right: 10),
        decoration: BoxDecoration(
          color: theme.defaultWhiteColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              blurStyle: BlurStyle.outer,
              color: theme.defaultGray900Color,
              offset: Offset.zero,
              spreadRadius: 1,
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        width: MediaQuery.sizeOf(context).width,
        height: 58,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin:
                    const EdgeInsetsDirectional.fromSTEB(10, 5, 0, 5),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              softWrap: false,
                              style: theme.textBodyLarge(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin:
                    const EdgeInsetsDirectional.fromSTEB(20, 5, 10, 5),
                child: Icon(
                  Icons.chevron_right_outlined,
                  color: theme.defaultGray700Color,
                  size: 36.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
