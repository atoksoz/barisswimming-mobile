import 'dart:convert';

import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String appName = '';
  String version = '';
  String description = '';
  String footer = '';
  String iconPath = '';

  @override
  void initState() {
    super.initState();
    loadAboutData();
    loadAppInfo();
  }

  Future<void> loadAboutData() async {
    final String response =
        await rootBundle.loadString('assets/config/about_us.json');
    final data = json.decode(response);
    setState(() {
      appName = data['app_name'];
      description = data['description'];
      footer = data['footer'];
    });
  }

  Future<void> loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TopAppBarWidget(
          title: "Hakkında",
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              if (BlocTheme.theme.applicationLogoPath.isNotEmpty)
                Image.asset(
                  BlocTheme.theme.applicationLogoPath,
                  width: 200,
                  height: 200,
                ),
              const SizedBox(height: 20),
              Text(
                appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Inter",
                ),
              ),
              Text(
                version,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: "Inter",
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
              ),
              const Spacer(),
              Text(
                footer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          tab: NavTab.profile,
        ));
  }
}
