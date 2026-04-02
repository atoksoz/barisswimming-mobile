import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

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
    final data = tag.data;

    final nfca = data['nfca'] as Map<String, dynamic>?;
    if (nfca != null) {
      return (nfca['identifier'] as List<dynamic>?)?.cast<int>();
    }
    final nfcb = data['nfcb'] as Map<String, dynamic>?;
    if (nfcb != null) {
      return (nfcb['identifier'] as List<dynamic>?)?.cast<int>();
    }
    final isodep = data['isodep'] as Map<String, dynamic>?;
    if (isodep != null) {
      return (isodep['identifier'] as List<dynamic>?)?.cast<int>();
    }
    final mifare = data['mifare'] as Map<String, dynamic>?;
    if (mifare != null) {
      return (mifare['identifier'] as List<dynamic>?)?.cast<int>();
    }
    final iso7816 = data['iso7816'] as Map<String, dynamic>?;
    if (iso7816 != null) {
      return (iso7816['identifier'] as List<dynamic>?)?.cast<int>();
    }
    final iso15693 = data['iso15693'] as Map<String, dynamic>?;
    if (iso15693 != null) {
      return (iso15693['identifier'] as List<dynamic>?)?.cast<int>();
    }

    return null;
  }
}
