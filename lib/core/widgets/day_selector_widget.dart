import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/l10n/app_labels.dart';
import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final int selectedDay;
  final Function(int) onDayChanged;

  const DaySelector({
    Key? key,
    required this.selectedDay,
    required this.onDayChanged,
  }) : super(key: key);

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Seçili güne scroll yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  void didUpdateWidget(DaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Seçili gün değiştiğinde scroll yap
    if (oldWidget.selectedDay != widget.selectedDay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDay() {
    if (!_scrollController.hasClients) return;
    
    // Her gün kutusu: 80px genişlik + 10px margin = 90px
    const double itemWidth = 90.0;
    final double targetPosition = (widget.selectedDay - 1) * itemWidth;
    
    // Seçili günün ekranda görünür olması için scroll yap
    // Eğer scroll edilebilir alan yoksa (tüm günler görünüyorsa) scroll yapma
    if (_scrollController.position.maxScrollExtent > 0) {
      // Seçili günün pozisyonuna scroll yap, ama max scroll extent'i aşmasın
      final double scrollPosition = targetPosition.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildDay(int day, String label) {
    final bool isSelected = widget.selectedDay == day;
    return InkWell(
      onTap: () {
        widget.onDayChanged(day);
      },
      child: Container(
        width: 80,
        alignment: Alignment.center,
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        ),
      ),
    );
  }

  final double iconBoxHeight = 44; // Gün kutusunun yüksekliğiyle uyumlu
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sol ikon
        IconButton(
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset - 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          icon: Container(
            height: iconBoxHeight,
            width: iconBoxHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor, // İç beyaz
              border: Border.all(
                color: BlocTheme.theme.default900Color, // Yeşil çerçeve
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: BlocTheme.theme.default900Color, // Yeşil ikon
            ),
          ),
        ),

        // Günleri taşıyan scrollable alan
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                buildDay(1, AppLabels.current.monday),
                buildDay(2, AppLabels.current.tuesday),
                buildDay(3, AppLabels.current.wednesday),
                buildDay(4, AppLabels.current.thursday),
                buildDay(5, AppLabels.current.friday),
                buildDay(6, AppLabels.current.saturday),
                buildDay(7, AppLabels.current.sunday),
              ],
            ),
          ),
        ),

        // Sağ ikon
        IconButton(
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset + 100,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          icon: Container(
            height: iconBoxHeight,
            width: iconBoxHeight,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BlocTheme.theme.defaultWhiteColor, // İç beyaz
              border: Border.all(
                color: BlocTheme.theme.default900Color, // Yeşil çerçeve
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: BlocTheme.theme.default900Color, // Yeşil ikon
            ),
          ),
        ),
      ],
    );
  }
}
