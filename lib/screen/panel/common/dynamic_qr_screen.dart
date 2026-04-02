import 'dart:async';
import 'dart:math' as math;

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/security_code_qr_service.dart';
import 'package:e_sport_life/core/utils/internet_connection_utils.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/show_no_internet_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Member, trainer ve admin panellerinde ortak kullanılan dinamik QR kod ekranı.
///
/// [preChecks] ile role'e özel ek kontroller enjekte edilir.
/// true dönerse QR oluşturulur, false dönerse işlem durur
/// (callback kendi hata UI'ını gösterir).
class DynamicQrScreen extends StatefulWidget {
  final Future<bool> Function(BuildContext context)? preChecks;

  const DynamicQrScreen({super.key, this.preChecks});

  @override
  State<DynamicQrScreen> createState() => _DynamicQrScreenState();
}

class _DynamicQrScreenState extends State<DynamicQrScreen> {
  final _noScreenshot = NoScreenshot.instance;

  static const int _defaultCountdown = 10;
  static const double _maxBrightness = 1.0;
  static const double _qrSize = 205.0;

  String _qrData = "";
  String _statusText = "";
  int _remainSeconds = _defaultCountdown;
  double _brightness = _maxBrightness;
  bool _showQrCode = false;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _noScreenshot.screenshotOff();
    _checkAndGenerate();
    _initBrightness();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ─── İlk açılışta çalışır: internet → servis → preChecks → QR ───

  Future<void> _checkAndGenerate() async {
    setState(() {
      _isLoading = true;
      _showQrCode = false;
      _statusText = "";
    });

    if (!await _internetAndServiceCheck()) return;

    if (widget.preChecks != null) {
      final proceed = await widget.preChecks!(context);
      if (!proceed || !mounted) return;
    }

    await _generateQr();
  }

  // ─── Yenile butonunda çalışır: internet → servis → QR (preChecks yok) ───

  Future<void> _refreshQr() async {
    setState(() {
      _isLoading = true;
      _showQrCode = false;
      _statusText = "";
    });
    _timer?.cancel();

    if (!await _internetAndServiceCheck()) return;

    await _generateQr();
  }

  // ─── Ortak kontroller ───

  Future<bool> _internetAndServiceCheck() async {
    final labels = AppLabels.current;

    final hasInternet = await InternetConnectionUtil.checkInternetConnection();
    if (!hasInternet) {
      if (mounted) await showNoInternetDialog(context);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = labels.checkInternetConnection;
        });
      }
      return false;
    }

    final externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = labels.configNotFound;
        });
      }
      return false;
    }

    final serviceOk = await InternetConnectionUtil.checkSecurityCodeService(
        externalConfig.securityCode);
    if (!serviceOk) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = labels.securityCodeServiceUnavailable;
        });
      }
      return false;
    }

    return true;
  }

  // ─── QR oluştur ───

  Future<void> _generateQr() async {
    await _initBrightness();
    final labels = AppLabels.current;

    final externalConfig =
        context.read<ExternalApplicationsConfigCubit>().state;
    if (externalConfig == null) return;

    final result = await SecurityCodeQrService.generateQrCode(
      securityCodeBaseUrl: externalConfig.securityCode,
      applicationId: externalConfig.applicationId.toString(),
    );

    if (!mounted) return;

    if (!result.success) {
      if (result.errorMessage != null) {
        await warningDialog(context,
            message: result.errorMessage!,
            path: BlocTheme.theme.errorSvgPath);
      }
      setState(() {
        _isLoading = false;
        _showQrCode = false;
        _statusText = result.errorMessage ?? labels.qrCodeCreateFailed;
      });
      return;
    }

    setState(() {
      _qrData = result.qrData!;
      _showQrCode = true;
      _isLoading = false;
      _remainSeconds = _defaultCountdown;
    });
    _startTimer();
  }

  // ─── Timer ───

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainSeconds > 0) {
        setState(() => _remainSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  // ─── Parlaklık ───

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

  // ─── UI ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            reverse: false,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (!_isLoading &&
                      !_showQrCode &&
                      _statusText.isNotEmpty) ...[
                    _buildErrorState(),
                  ],
                  if (_isLoading) ...[
                    _buildLoadingState(),
                  ],
                  if (!_isLoading && _showQrCode) ...[
                    _buildQrState(),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!_isLoading && _showQrCode) _buildRefreshButton(),
      ]),
    );
  }

  // ─── Hata / Durum mesajı ───

  Widget _buildErrorState() {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: theme.textError(),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: _checkAndGenerate,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.defaultWhiteColor,
                  border: Border.all(color: theme.default800Color),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(25)),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh,
                        size: 24, color: theme.default800Color),
                    const SizedBox(width: 8),
                    Text(
                      labels.tryAgain,
                      style: theme.textBodyBold(
                          color: theme.default800Color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Yükleniyor ───

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0, 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 150, 0, 0),
                                child: Text(
                                  AppLabels.current.qrCodeGenerating,
                                  maxLines: 1,
                                  style: BlocTheme.theme.textHeadline(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
        const SizedBox(height: 150),
        const Center(child: LoadingIndicatorWidget()),
      ],
    );
  }

  // ─── QR Görüntüleme ───

  Widget _buildQrState() {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final isExpired = _remainSeconds == 0;

    return Column(
      children: [
        const SizedBox(height: 15),
        // Başlık
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              isExpired ? labels.renewQrCode : labels.scanQrCode,
              maxLines: 1,
              style: theme.textHeadline(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Sayaç
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: theme.default800Color,
                  value: _remainSeconds / _defaultCountdown,
                ),
              ),
              Text(
                "$_remainSeconds",
                maxLines: 1,
                style: theme.textCounter(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // QR + köşe işaretçileri
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: _qrSize,
              height: _qrSize,
              child: !isExpired
                  ? QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: _qrSize,
                    )
                  : Icon(Icons.block,
                      size: 100,
                      color: theme.defaultGray400Color),
            ),
            const Positioned(
                top: 0,
                left: 0,
                child: CornerMarker(
                    position: CornerPosition.topLeft)),
            const Positioned(
                top: 0,
                right: 0,
                child: CornerMarker(
                    position: CornerPosition.topRight)),
            const Positioned(
                bottom: 0,
                right: 0,
                child: CornerMarker(
                    position: CornerPosition.bottomRight)),
            const Positioned(
                bottom: 0,
                left: 0,
                child: CornerMarker(
                    position: CornerPosition.bottomLeft)),
          ],
        ),
        const SizedBox(height: 30),
        // Parlaklık etiketi
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              labels.screenBrightness,
              maxLines: 1,
              style: theme.textLabel(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Parlaklık slider
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
      ],
    );
  }

  // ─── Yenile Butonu (menü üstüne sabit) ───

  Widget _buildRefreshButton() {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;
    final isExpired = _remainSeconds == 0;
    final buttonColor =
        isExpired ? theme.default800Color : theme.defaultGray300Color;
   
    return Opacity( 
      opacity: isExpired ? 1.0 : 0.9, 
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: isExpired ? _refreshQr : null,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                color: theme.defaultGray50Color,
              )
            ],
            color: theme.defaultWhiteColor,
            border: Border.all(color: buttonColor),
            borderRadius: const BorderRadius.all(
                Radius.circular(25)),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 50,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  size: 32,
                  color: buttonColor,
                ),
                const SizedBox(width: 12),
                Text(
                  labels.refreshCode,
                  style: theme.textBodyBold(color: buttonColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Köşe İşaretçileri ───

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class CornerMarker extends StatelessWidget {
  final CornerPosition position;

  const CornerMarker({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _rotationAngle(),
      child: CustomPaint(
        size: const Size(50, 50),
        painter: _CornerPainter(),
      ),
    );
  }

  double _rotationAngle() {
    switch (position) {
      case CornerPosition.topLeft:
        return 0;
      case CornerPosition.topRight:
        return math.pi / 2;
      case CornerPosition.bottomRight:
        return math.pi;
      case CornerPosition.bottomLeft:
        return 3 * math.pi / 2;
    }
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BlocTheme.theme.defaultBlackColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    const offset = -10.0;
    const length = 60.0;

    path.moveTo(offset, offset);
    path.lineTo(offset + length, offset);

    path.moveTo(offset, offset);
    path.lineTo(offset, offset + length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
