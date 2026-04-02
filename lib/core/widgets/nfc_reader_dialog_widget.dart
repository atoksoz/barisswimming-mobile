import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/nfc_reader_service.dart';
import 'package:flutter/material.dart';

/// NFC kart okuma popup'ı.
/// Kart okunduğunda `Future<String?>` olarak kart numarasını döner.
/// Kullanıcı kapatırsa veya hata olursa `null` döner.
Future<String?> showNfcReaderDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final theme = BlocTheme.theme;
      final labels = AppLabels.current;

      NfcReaderService.startSession(
        onCardRead: (cardNumber) {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop(cardNumber);
          }
        },
        onError: () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop(null);
          }
        },
      );

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  await NfcReaderService.stopSession();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(null);
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: theme.default500Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close,
                      color: theme.defaultWhiteColor, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Icon(Icons.nfc_rounded, size: 64, color: theme.default700Color),
            const SizedBox(height: 16),
            Text(
              labels.readNfcCard,
              style: theme.textBodyBold(color: theme.defaultBlackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              labels.nfcReadingCard,
              style: theme.textCaption(color: theme.panelSubTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.default700Color),
              ),
            ),
          ],
        ),
      );
    },
  );
}
