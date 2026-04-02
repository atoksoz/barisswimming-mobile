import 'dart:convert';

import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/services/jwt_storage_service.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/member_action_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionHistoryScreen extends StatefulWidget {
  const ActionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ActionHistoryScreen> createState() => _ActionHistoryScreenState();
}
 
class _ActionHistoryScreenState extends State<ActionHistoryScreen> {
  static const int _perPage = 20;
  static const double _cardHeight = 55.0;
  static const double _iconSize = 36.0;

  final ScrollController _scrollController = ScrollController();
  final List<MemberActionModel> _actions = [];

  int _currentPage = 1;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) {
        setState(() {
          _isLoading = false;
          _isInitialLoading = false;
        });
        return;
      }

      final url = ApiHamamSpaUrlConstants.getMyActionsUrl(
        externalConfig.apiHamamspaUrl,
        page: _currentPage,
        itemsPerPage: _perPage,
      );
      final token = await JwtStorageService.getToken() as String;
      final response = await RequestUtil.get(url, token: token);
      final json = jsonDecode(response!.body) as Map<String, dynamic>;

      final output = json["output"] as Map<String, dynamic>;
      final lastPage = output["lastPage"] as int? ?? 1;
      final newItems = (output["actions"] as List)
          .map((item) => MemberActionModel.fromJson(item))
          .toList();

      setState(() {
        _actions.addAll(newItems);
        _hasMore = _currentPage < lastPage;
        _currentPage++;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.pastEntryHistory),
      body: _isInitialLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _actions.isEmpty
              ? const Center(child: NoDataTextWidget())
              : _buildList(),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.profile),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _actions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _actions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicatorWidget()),
          );
        }
        return _buildActionCard(_actions[index]);
      },
    );
  }

  Widget _buildActionCard(MemberActionModel data) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(spreadRadius: 1, color: theme.defaultGray50Color),
        ],
        color: theme.defaultWhiteColor,
        border: Border.all(color: theme.defaultGray50Color),
        borderRadius:
            BorderRadius.all(Radius.circular(theme.panelCardRadius)),
      ),
      margin: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      width: MediaQuery.sizeOf(context).width,
      height: _cardHeight,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsetsDirectional.fromSTEB(5, 8, 0, 0),
              child: SvgPicture.asset(
                data.isEntry
                    ? theme.turnstileInSvgPath
                    : theme.turnstileOutSvgPath,
                width: _iconSize,
                height: _iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          data.isEntry ? labels.entryIn : labels.entryOut,
                          textAlign: TextAlign.left,
                          softWrap: false,
                          style: theme.textBodyBold(
                              color: theme.defaultGray700Color),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          data.actionTime,
                          textAlign: TextAlign.left,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: theme.textCaption(
                            color: data.isEntry
                                ? theme.defaultGray900Color
                                : theme.defaultRed700Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
