import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Sabit değerli (statik) QR kod ekranı.
/// Verilen [value] değerini QR olarak gösterir — geri sayım/yenileme yoktur.
class MemberFixedQrScreen extends StatefulWidget {
  final String value;
  final String? infoText;
  final String? topText;

  const MemberFixedQrScreen({
    Key? key,
    required this.value,
    this.infoText,
    this.topText,
  }) : super(key: key);

  @override
  State<MemberFixedQrScreen> createState() => _MemberFixedQrScreenState();
}

class _MemberFixedQrScreenState extends State<MemberFixedQrScreen> {
  static const double _maxBrightness = 1.0;
  static const double _qrSize = 250.0;
  static const int _numericPadLength = 10;

  late String _paddedValue;
  double _brightness = _maxBrightness;

  @override
  void initState() {
    super.initState();
    _paddedValue = RegExp(r'^\d+$').hasMatch(widget.value)
        ? widget.value.padLeft(_numericPadLength, '0')
        : widget.value;
    _initBrightness();
  }

  Future<void> _initBrightness() async {
    await _setBrightness(_maxBrightness);
    _brightness = _maxBrightness;
  }

  Future<void> _changeBrightness(double value) async {
    setState(() => _brightness = value);
    await _setBrightness(value);
  }

  Future<void> _setBrightness(double value) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (_) {}
    try {
      await ScreenBrightness.instance.setSystemScreenBrightness(value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(
        title: labels.qrCode,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.topText != null && widget.topText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    widget.topText!,
                    textAlign: TextAlign.center,
                    style: theme.textCounter(color: theme.default900Color)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    labels.scanQrCode,
                    maxLines: 1,
                    style: theme.textHeadline(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: _paddedValue,
                version: QrVersions.auto,
                size: _qrSize,
              ),
              const SizedBox(height: 20),
              Text(
                _paddedValue,
                style: theme.textTitle().copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              if (widget.infoText != null && widget.infoText!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Text(
                    widget.infoText!,
                    textAlign: TextAlign.center,
                    style: theme.textBody(color: theme.defaultGray500Color),
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    labels.screenBrightness,
                    maxLines: 1,
                    style: theme.textLabel(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 32,
                      color: theme.default900Color,
                    ),
                    Expanded(
                      child: Slider(
                        value: _brightness,
                        onChanged: _changeBrightness,
                        min: 0,
                        max: 1,
                        activeColor: theme.default900Color,
                        inactiveColor:
                            theme.default900Color.withOpacity(0.9),
                        label: "${(_brightness * 100).toInt()}%",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        tab: NavTab.qr,
      ),
    );
  }
}
