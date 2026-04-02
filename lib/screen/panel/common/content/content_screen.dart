import 'dart:convert';

import 'package:e_sport_life/config/app-content/app_content.dart';
import 'package:e_sport_life/config/app-content/app_content_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ContentType { kvkk, membershipRules, facilityRules, serviceRules, groupRules }

class ContentScreen extends StatefulWidget {
  final ContentType contentType;
  final String appBarTitle;

  const ContentScreen({
    super.key,
    required this.contentType,
    required this.appBarTitle,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  String _title = '';
  String? _content;
  List<String> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final cubitContent = context.read<AppContentCubit>().state;
    final item = _getContentItem(cubitContent);

    if (item != null) {
      _applyContentItem(item);
      return;
    }

    await _loadFromAsset();
  }

  ContentItem? _getContentItem(AppContent? appContent) {
    if (appContent == null) return null;
    switch (widget.contentType) {
      case ContentType.kvkk:
        return appContent.kvkk;
      case ContentType.membershipRules:
        return appContent.membershipRules;
      case ContentType.facilityRules:
        return appContent.facilityRules;
      case ContentType.serviceRules:
        return appContent.serviceRules;
      case ContentType.groupRules:
        return appContent.groupRules;
    }
  }

  void _applyContentItem(ContentItem item) {
    setState(() {
      _title = item.title;
      _content = item.content;
      _rules = item.rules ?? [];
      _isLoading = false;
    });
  }

  Future<void> _loadFromAsset() async {
    try {
      final assetPath = _assetPath;
      final raw = await rootBundle.loadString(assetPath);
      final data = json.decode(raw) as Map<String, dynamic>;
      final item = ContentItem.fromJson(data);
      _applyContentItem(item);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _assetPath {
    switch (widget.contentType) {
      case ContentType.kvkk:
        return 'assets/config/kvkk.json';
      case ContentType.membershipRules:
        return 'assets/config/membership_rules.json';
      case ContentType.facilityRules:
        return 'assets/config/facility_rules.json';
      case ContentType.serviceRules:
        return 'assets/config/service_rules.json';
      case ContentType.groupRules:
        return 'assets/config/group_rules.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;

    return Scaffold(
      appBar: TopAppBarWidget(title: widget.appBarTitle),
      body: _isLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _content != null
              ? _buildContentBody(theme)
              : _buildRulesBody(theme),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  Widget _buildContentBody(BaseTheme theme) {
    final paragraphs = _content!.split('\n\n');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, style: theme.textTitle()),
            const SizedBox(height: 20),
            ...paragraphs.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  paragraph,
                  style: theme.textBody(),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesBody(BaseTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(_title, style: theme.textTitle()),
          );
        }
        final ruleIndex = index - 1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ruleIndex + 1}) ',
                style: theme.textBodyBold(),
              ),
              Expanded(
                child: Text(
                  _rules[ruleIndex],
                  style: theme.textBody(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
