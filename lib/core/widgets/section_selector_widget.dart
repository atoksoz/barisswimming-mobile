import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

import '../../data/model/movements_model.dart';

class SectionSelector extends StatefulWidget {
  final List<MovementsModel> movements;
  final String selectedSectionId;
  final Function(String) onSectionChanged;

  const SectionSelector({
    super.key,
    required this.movements,
    required this.selectedSectionId,
    required this.onSectionChanged,
  });

  @override
  State<SectionSelector> createState() => _SectionSelectorState();
}

class _SectionSelectorState extends State<SectionSelector> {
  late ScrollController _scrollController;
  late Map<String, GlobalKey> _buttonKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Her section için GlobalKey oluştur
    _buttonKeys = {
      "": GlobalKey(), // "Tümü" butonu için
      for (var m in widget.movements) m.section_id: GlobalKey(),
    };

    // İlk çizimde seçili butona scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(covariant SectionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    final key = _buttonKeys[widget.selectedSectionId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget buildSectionButton(String label, String id) {
    final isSelected = widget.selectedSectionId == id;
    final key = _buttonKeys[id];

    return Container(
      key: key,
      margin: const EdgeInsetsDirectional.only(end: 10),
      child: InkWell(
        onTap: () => widget.onSectionChanged(id),
        child: Container(
          width: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? BlocTheme.theme.default500Color : BlocTheme.theme.defaultWhiteColor,
            border: Border.all(color: BlocTheme.theme.defaultGray700Color),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: BlocTheme.theme.textCaptionSemiBold(
              color: BlocTheme.theme.default900Color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // section_id -> section_name eşlemesi
    final Map<String, String> sectionNames = {
      for (var m in widget.movements) m.section_id: m.section_name,
    };

    // section_id -> count eşlemesi
    final Map<String, int> sectionCounts = {};
    for (var m in widget.movements) {
      sectionCounts[m.section_id] = (sectionCounts[m.section_id] ?? 0) + 1;
    }

    // section'ları sıralayalım (isimlerine göre)
    final sortedEntries = sectionNames.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    const double iconBoxHeight = 44;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Sol ok
          IconButton(
            onPressed: _scrollLeft,
            icon: Container(
              height: iconBoxHeight,
              width: iconBoxHeight,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BlocTheme.theme.defaultWhiteColor,
                border: Border.all(
                  color: BlocTheme.theme.default900Color,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: BlocTheme.theme.default900Color,
              ),
            ),
          ),

          // Scrollable section list
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: [
                  // Tümü butonu
                  buildSectionButton("${AppLabels.current.all} (${widget.movements.length})", ""),

                  // Diğer sectionlar
                  ...sortedEntries.map((e) {
                    final label = "${e.value} (${sectionCounts[e.key] ?? 0})";
                    return buildSectionButton(label, e.key);
                  }).toList(),
                ],
              ),
            ),
          ),

          // Sağ ok
          IconButton(
            onPressed: _scrollRight,
            icon: Container(
              height: iconBoxHeight,
              width: iconBoxHeight,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BlocTheme.theme.defaultWhiteColor,
                border: Border.all(
                  color: BlocTheme.theme.default900Color,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: BlocTheme.theme.default900Color,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}
