import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/shared-preferences/locale_cache_utils.dart';
import 'package:flutter/material.dart';

/// Profil ekranlarında TR/EN dil seçimi.
///
/// [onLocaleChanged]: Dil değişince üst widget'ın `setState` ile yenilenmesi için
/// verilir; böylece `AppLabels.current` metinleri güncellenir.
class ProfileLanguageSelectorWidget extends StatelessWidget {
  const ProfileLanguageSelectorWidget({
    super.key,
    this.onLocaleChanged,
  });

  final VoidCallback? onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final current = AppLabels.currentLocale;
    final isTr = current == SupportedLocale.tr;

    return PopupMenuButton<SupportedLocale>(
      onSelected: (locale) {
        AppLabels.changeLocale(locale);
        LocaleCacheUtils.save(locale);
        onLocaleChanged?.call();
      },
      offset: const Offset(0, 44),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.defaultWhiteColor,
      itemBuilder: (_) => [
        _profileLocaleMenuItem(
          locale: SupportedLocale.tr,
          flag: '🇹🇷',
          label: 'Türkçe',
          isSelected: isTr,
          theme: theme,
        ),
        _profileLocaleMenuItem(
          locale: SupportedLocale.en,
          flag: '🇬🇧',
          label: 'English',
          isSelected: !isTr,
          theme: theme,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: theme.defaultWhiteColor,
          border: Border.all(color: theme.defaultGray200Color, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTr ? '🇹🇷' : '🇬🇧',
              style: theme.textLabel(),
            ),
            const SizedBox(width: 6),
            Text(
              isTr ? 'TR' : 'EN',
              style: theme.textCaption(color: theme.default900Color),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              color: theme.default700Color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

PopupMenuItem<SupportedLocale> _profileLocaleMenuItem({
  required SupportedLocale locale,
  required String flag,
  required String label,
  required bool isSelected,
  required dynamic theme,
}) {
  return PopupMenuItem<SupportedLocale>(
    value: locale,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.default300Color : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(flag, style: theme.textSubtitle()),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textBody(
                color: isSelected
                    ? theme.default700Color
                    : theme.defaultBlackColor,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: theme.default700Color, size: 20),
        ],
      ),
    ),
  );
}
