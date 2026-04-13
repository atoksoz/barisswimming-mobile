import 'package:e_sport_life/config/external-applications-config/external_applications_config_cubit.dart';
import 'package:e_sport_life/config/themes/base_theme.dart';
import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/constants/relationship_type.dart';
import 'package:e_sport_life/core/constants/url/api_hamam_spa_url_constants.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:e_sport_life/core/utils/request_util.dart';
import 'package:e_sport_life/core/widgets/bottom_navigation_bar_widget.dart';
import 'package:e_sport_life/core/widgets/loading_indicator_widget.dart';
import 'package:e_sport_life/core/widgets/no_data_text_widget.dart';
import 'package:e_sport_life/core/widgets/top_appbar_widget.dart';
import 'package:e_sport_life/data/model/member_guardian_list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GuardianListScreen extends StatefulWidget {
  const GuardianListScreen({Key? key}) : super(key: key);

  @override
  State<GuardianListScreen> createState() => _GuardianListScreenState();
}

class _GuardianListScreenState extends State<GuardianListScreen> {
  late Future<List<MemberGuardianListItemModel>> _guardiansFuture;

  @override
  void initState() {
    super.initState();
    _guardiansFuture = _fetchGuardians();
  }

  Future<List<MemberGuardianListItemModel>> _fetchGuardians() async {
    try {
      final externalConfig =
          context.read<ExternalApplicationsConfigCubit>().state;
      if (externalConfig == null) return [];
      final apiUrl = externalConfig.apiHamamspaUrl;
      if (apiUrl.isEmpty) return [];

      final url = ApiHamamSpaUrlConstants.getMyGuardiansUrl(apiUrl);
      final result = await RequestUtil.getJson(url);

      if (result.isSuccess && result.output is List) {
        return (result.output as List)
            .map(
              (e) => MemberGuardianListItemModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _professionDisplay(AppLabels labels, String? key) {
    if (key == null) return '';
    final k = key.trim();
    if (k.isEmpty) return '';
    return labels.guardianProfessionGroupLabels[k] ?? k;
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLabels.current;

    return Scaffold(
      appBar: TopAppBarWidget(title: labels.guardianInfo.replaceAll('\n', ' ')),
      body: FutureBuilder<List<MemberGuardianListItemModel>>(
        future: _guardiansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicatorWidget());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return _buildGuardianList(snapshot.data!);
          } else {
            return const Center(child: NoDataTextWidget());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildGuardianList(List<MemberGuardianListItemModel> guardians) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: guardians.length,
      itemBuilder: (context, index) {
        final g = guardians[index];
        final name = g.name.trim();
        final phone = g.phone.trim();
        final relation = RelationshipType.getLabel(g.relation?.toString());
        final isPrimary = g.isPrimary;

        return Container(
          decoration: BoxDecoration(
            color: theme.defaultGray100Color,
            border: Border.all(color: theme.defaultGray200Color),
            borderRadius:
                BorderRadius.all(Radius.circular(theme.panelCardRadius)),
          ),
          margin: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16, 0, 10, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? '—' : name,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: theme.textBodyBold(
                                  color: theme.default900Color),
                            ),
                            if (relation.isNotEmpty)
                              Text(
                                relation,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: theme.textCaption(
                                    color: theme.defaultGray900Color),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (isPrimary)
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.default100Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              labels.primaryGuardian,
                              style: theme.textMini(
                                  color: theme.default700Color),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (g.hasDetailSection)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.defaultWhiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(theme.panelCardRadius),
                      bottomRight: Radius.circular(theme.panelCardRadius),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (phone.isNotEmpty) ...[
                        _phoneRow(theme, phone, onTap: () => _callPhone(phone)),
                      ],
                      if (g.secondaryPhone != null &&
                          g.secondaryPhone!.trim().isNotEmpty) ...[
                        if (phone.isNotEmpty) const SizedBox(height: 8),
                        _phoneRow(
                          theme,
                          g.secondaryPhone!.trim(),
                          onTap: () => _callPhone(g.secondaryPhone!.trim()),
                        ),
                      ],
                      if (g.email != null && g.email!.trim().isNotEmpty) ...[
                        if (phone.isNotEmpty ||
                            (g.secondaryPhone != null &&
                                g.secondaryPhone!.trim().isNotEmpty))
                          const SizedBox(height: 8),
                        _emailRow(theme, g.email!.trim()),
                      ],
                      if (g.professionGroup != null &&
                          g.professionGroup!.trim().isNotEmpty) ...[
                        if (_hasAnyAbovePhoneEmail(
                            phone, g.secondaryPhone, g.email))
                          const SizedBox(height: 8),
                        _labeledValueBlock(
                          theme,
                          labels.guardianProfessionGroupField,
                          _professionDisplay(labels, g.professionGroup),
                        ),
                      ],
                      if (g.province != null && g.province!.trim().isNotEmpty) ...[
                        if (_hasAnyAboveProvince(phone, g.secondaryPhone, g.email,
                            g.professionGroup))
                          const SizedBox(height: 8),
                        _labeledValueBlock(
                          theme,
                          labels.guardianProvinceField,
                          g.province!.trim(),
                        ),
                      ],
                      if (g.district != null && g.district!.trim().isNotEmpty) ...[
                        if (_hasAnyAboveDistrict(phone, g.secondaryPhone,
                            g.email, g.professionGroup, g.province))
                          const SizedBox(height: 8),
                        _labeledValueBlock(
                          theme,
                          labels.guardianDistrictField,
                          g.district!.trim(),
                        ),
                      ],
                      if (g.address != null && g.address!.trim().isNotEmpty) ...[
                        if (_hasAnyAboveAddress(phone, g.secondaryPhone, g.email,
                            g.professionGroup, g.province, g.district))
                          const SizedBox(height: 8),
                        _labeledValueBlock(
                          theme,
                          labels.guardianAddressField,
                          g.address!.trim(),
                          multiline: true,
                        ),
                      ],
                      if (g.note != null && g.note!.trim().isNotEmpty) ...[
                        if (_hasAnyAboveNote(phone, g.secondaryPhone, g.email,
                            g.professionGroup, g.province, g.district, g.address))
                          const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(Icons.notes_outlined,
                                  size: 14,
                                  color: theme.defaultGray500Color),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                g.note!.trim(),
                                style: theme.textCaption(
                                    color: theme.defaultGray500Color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _hasAnyAbovePhoneEmail(
    String phone,
    String? secondaryPhone,
    String? email,
  ) {
    return phone.isNotEmpty ||
        (secondaryPhone != null && secondaryPhone.trim().isNotEmpty) ||
        (email != null && email.trim().isNotEmpty);
  }

  bool _hasAnyAboveProvince(
    String phone,
    String? secondaryPhone,
    String? email,
    String? professionGroup,
  ) {
    return _hasAnyAbovePhoneEmail(phone, secondaryPhone, email) ||
        (professionGroup != null && professionGroup.trim().isNotEmpty);
  }

  bool _hasAnyAboveDistrict(
    String phone,
    String? secondaryPhone,
    String? email,
    String? professionGroup,
    String? province,
  ) {
    return _hasAnyAboveProvince(phone, secondaryPhone, email, professionGroup) ||
        (province != null && province.trim().isNotEmpty);
  }

  bool _hasAnyAboveAddress(
    String phone,
    String? secondaryPhone,
    String? email,
    String? professionGroup,
    String? province,
    String? district,
  ) {
    return _hasAnyAboveDistrict(
            phone, secondaryPhone, email, professionGroup, province) ||
        (district != null && district.trim().isNotEmpty);
  }

  bool _hasAnyAboveNote(
    String phone,
    String? secondaryPhone,
    String? email,
    String? professionGroup,
    String? province,
    String? district,
    String? address,
  ) {
    return _hasAnyAboveAddress(phone, secondaryPhone, email, professionGroup,
            province, district) ||
        (address != null && address.trim().isNotEmpty);
  }

  Widget _phoneRow(
    BaseTheme theme,
    String phone, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 14, color: theme.default900Color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              phone,
              style: theme.textCaption(color: theme.defaultGray700Color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailRow(BaseTheme theme, String email) {
    return InkWell(
      onTap: () => _openEmail(email),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child:
                Icon(Icons.mail_outline, size: 14, color: theme.default900Color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              email,
              style: theme.textCaption(color: theme.defaultGray700Color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledValueBlock(
    BaseTheme theme,
    String label,
    String value, {
    bool multiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textMini(color: theme.defaultGray500Color),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textCaption(color: theme.defaultGray700Color),
          maxLines: multiline ? 6 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
