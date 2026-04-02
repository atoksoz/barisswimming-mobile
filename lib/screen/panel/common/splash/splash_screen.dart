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

  List<String> _sliderImages = [];
  String _greetingMessage = '';
  int _currentIndex = 0;
  bool _isSliderVisible = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _handleSplashFlow();
  }

  Future<void> _handleSplashFlow() async {
    try {
      final storedSlider = await getSplashScreenSliderItems();

      if (storedSlider != null && storedSlider.isNotEmpty) {
        setState(() {
          _sliderImages = storedSlider;
          _isSliderVisible = true;
        });
      } else {
        _startDelayedNavigation();
      }
    } catch (_) {
      // Non-blocking
    } finally {
      SplashScreenService.fetchAndStoreSplashData(context);
    }
  }

  void _startDelayedNavigation() {
    _setGreeting();
    Timer(_navigationDelay, () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SliderScreen()),
      );
    });
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
        if (!mounted) return;
        if (_currentIndex == _sliderImages.length - 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SliderScreen()),
          );
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
