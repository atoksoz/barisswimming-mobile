import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

class NfcReaderService {
  static Future<bool> isAvailable() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  static Future<void> startSession({
    required void Function(String cardNumber) onCardRead,
    required void Function() onError,
  }) async {
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        final cardNumber = extractCardNumber(tag);
        await NfcManager.instance.stopSession();

        if (cardNumber != null && cardNumber.isNotEmpty) {
          onCardRead(cardNumber);
        } else {
          onError();
        }
      },
    );
  }

  static Future<void> stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  static String? extractCardNumber(NfcTag tag) {
    try {
      final identifier = _getTagIdentifier(tag);
      if (identifier == null || identifier.isEmpty) return null;

      int decimal = 0;
      for (final byte in identifier) {
        decimal = (decimal << 8) | byte;
      }
      final decimalStr = decimal.toString().padLeft(10, '0');

      debugPrint('NFC UID bytes: $identifier → decimal: $decimalStr');
      return decimalStr;
    } catch (_) {
      return null;
    }
  }

  static List<int>? _getTagIdentifier(NfcTag tag) {
    final androidTag = NfcTagAndroid.from(tag);
    if (androidTag != null) {
      return androidTag.id.toList(growable: false);
    }

    final miFare = MiFareIos.from(tag);
    if (miFare != null) {
      return miFare.identifier.toList(growable: false);
    }

    final iso7816 = Iso7816Ios.from(tag);
    if (iso7816 != null) {
      return iso7816.identifier.toList(growable: false);
    }

    final iso15693 = Iso15693Ios.from(tag);
    if (iso15693 != null) {
      return iso15693.identifier.toList(growable: false);
    }

    return null;
  }
}
