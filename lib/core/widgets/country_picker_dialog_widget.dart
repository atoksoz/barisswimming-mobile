import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/helpers.dart';

class CountryPickerDialogWidget extends StatefulWidget {
  final List<Country> countries;
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const CountryPickerDialogWidget({
    Key? key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  State<CountryPickerDialogWidget> createState() =>
      _CountryPickerDialogWidgetState();
}

class _CountryPickerDialogWidgetState extends State<CountryPickerDialogWidget> {
  late List<Country> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.countries)
      ..sort((a, b) => a.localizedName('tr').compareTo(b.localizedName('tr')));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(widget.countries)
          ..sort((a, b) =>
              a.localizedName('tr').compareTo(b.localizedName('tr')));
      } else {
        _filtered = widget.countries.stringSearch(query)
          ..sort((a, b) =>
              a.localizedName('tr').compareTo(b.localizedName('tr')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlocTheme.theme;
    final labels = AppLabels.current;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: theme.defaultWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.default100Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.public,
                    color: theme.default700Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  labels.selectCountry,
                  style: theme.textLabelBold(color: theme.default700Color),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: theme.default500Color,
                  style: theme.inputTextStyle(),
                  decoration: InputDecoration(
                    hintText: labels.search,
                    hintStyle:
                        theme.textBody(color: theme.defaultGray500Color),
                    prefixIcon: Icon(Icons.search,
                        color: theme.default700Color, size: 22),
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: theme.default700Color, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: theme.default700Color, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      color: theme.default700Color,
                      thickness: 1,
                      height: 0,
                    ),
                    itemBuilder: (_, index) {
                      final country = _filtered[index];
                      final isSelected =
                          country.code == widget.selectedCountry.code;
                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected ? theme.default50Color : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.localizedName('tr'),
                            style: theme.textBody(
                              color: isSelected
                                  ? theme.default700Color
                                  : theme.defaultBlackColor,
                            ),
                          ),
                          trailing: Text(
                            '+${country.dialCode}',
                            style: theme.textBody(color: theme.default700Color),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () {
                            widget.onCountrySelected(country);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.default500Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: theme.defaultBlackColor,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
