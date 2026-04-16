import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/splash_screen_service.dart';
import 'package:e_sport_life/core/utils/shared-preferences/splash_utils.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/screen/panel/common/slider/slider_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _navigationDelay = Duration(seconds: 1);
  static const _sliderFallbackDelay = Duration(seconds: 4);
  static const _startupWatchdogDelay = Duration(seconds: 6);
  static const _cacheReadTimeout = Duration(seconds: 2);

  List<String> _sliderImages = [];
  String _greetingMessage = '';
  int _currentIndex = 0;
  bool _isSliderVisible = false;
  bool _hasNavigated = false;
  Timer? _startupWatchdog;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startupWatchdog = Timer(_startupWatchdogDelay, _navigateToSliderScreen);
    _handleSplashFlow();
  }

  @override
  void dispose() {
    _startupWatchdog?.cancel();
    super.dispose();
  }

  Future<void> _handleSplashFlow() async {
    try {
      final storedSlider = await getSplashScreenSliderItems()
          .timeout(_cacheReadTimeout, onTimeout: () => null);

      if (!mounted) return;

      if (storedSlider != null && storedSlider.isNotEmpty) {
        setState(() {
          _sliderImages = storedSlider;
          _isSliderVisible = true;
        });
        _startSliderFallbackNavigation();
      } else {
        _startDelayedNavigation();
      }
    } catch (_) {
      _startDelayedNavigation();
    } finally {
      SplashScreenService.fetchAndStoreSplashData(context);
    }
  }

  void _startDelayedNavigation() {
    _setGreeting();
    Timer(_navigationDelay, () {
      _navigateToSliderScreen();
    });
  }

  void _startSliderFallbackNavigation() {
    Timer(_sliderFallbackDelay, () {
      _navigateToSliderScreen();
    });
  }

  void _navigateToSliderScreen() {
    if (!mounted || _hasNavigated) return;
    _startupWatchdog?.cancel();
    _hasNavigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SliderScreen()),
    );
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    final labels = AppLabels.current;
    String text;
    if (hour >= 5 && hour < 12) {
      text = labels.goodMorning;
    } else if (hour >= 12 && hour < 18) {
      text = labels.goodAfternoon;
    } else if (hour >= 18 && hour < 22) {
      text = labels.goodEvening;
    } else {
      text = labels.goodNight;
    }
    setState(() {
      _greetingMessage = text;
    });
  }

  void _handleSliderChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == _sliderImages.length - 1) {
      Future.delayed(_navigationDelay, () {
        if (_currentIndex == _sliderImages.length - 1) {
          _navigateToSliderScreen();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlocTheme.theme.defaultBlackColor,
      body: _isSliderVisible ? _buildSlider() : _buildGreeting(),
    );
  }

  Widget _buildSlider() {
    return Center(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          viewportFraction: 1,
          height: MediaQuery.sizeOf(context).height,
          onPageChanged: (index, reason) {
            _handleSliderChanged(index);
          },
        ),
        itemCount: _sliderImages.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Image.network(
              _sliderImages[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: LoadingIndicatorWidget(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Center(
      child: Text(
        _greetingMessage,
        style: BlocTheme.theme.text4Xl,
        textAlign: TextAlign.center,
      ),
    );
  }
}