import 'package:e_sport_life/config/themes/bloc_theme.dart';
import 'package:e_sport_life/core/widgets/custom_confirmation_dialog_widget.dart';
import 'package:e_sport_life/core/widgets/warning_dialog_widget.dart';
import 'package:e_sport_life/data/model/group_lesson_resarvation_model.dart';
import 'package:e_sport_life/screen/group-lesson-screen/group_lesson_screen.dart';
//import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/services/resarvation_service.dart';
import '../../core/widgets/bottom_navigation_bar_widget.dart';
import '../../core/widgets/top_appbar_widget.dart';
import '../../data/model/group_lesson_model.dart';

class GroupLessonDetail extends StatefulWidget {
  final GroupLessonModel lesson;
  const GroupLessonDetail({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  @override
  State<GroupLessonDetail> createState() => _GroupLessonDetailState();
}

class _GroupLessonDetailState extends State<GroupLessonDetail> {
  int selectedTab = 0;
  int? selectedSeatId;
  bool? hasActivePackage;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<GroupLessonModel>> groupLessons;
  late Future<List<GroupLessonResarvationModel>> groupLessonResarvations;

  @override
  void initState() {
    super.initState();
    // Initialize selectedSeatId from API if member has already selected a seat
    if (widget.lesson.seat_selection?.member?.selected_seat_id != null) {
      selectedSeatId = widget.lesson.seat_selection!.member!.selected_seat_id;
    }
    _checkPackage();
  }

  Future<void> _checkPackage() async {
    if (widget.lesson.is_paid && !widget.lesson.member_registered) {
      final result = await ResarvationService.hasActiveBranchPackage(context,
          services_id: widget.lesson.only_purchased_members_can_register
              ? widget.lesson.services_id
              : null);
      if (mounted) {
        setState(() {
          hasActivePackage = result;
        });
      }
    } else {
      setState(() {
        hasActivePackage = true;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopAppBarWidget(title: "Grup Ders Detayı"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: ((lesson.member_registered == true) ||
                    (lesson.can_today_resarvation == true &&
                        lesson.remain_limit > 0))
                ? 100
                : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lesson.service_plan_name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: BlocTheme.theme.default900Color,
                            ),
                          ),
                        ),
                        _buildPriceBadge(lesson),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Eğitmen Bölümü
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BlocTheme.theme.defaultGray50Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          if (lesson.employee_image != null &&
                              lesson.employee_image!.isNotEmpty)
                            CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  NetworkImage(lesson.employee_image!),
                            )
                          else
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: BlocTheme.theme.default900Color
                                  .withOpacity(0.1),
                              child: Icon(Icons.person,
                                  color: BlocTheme.theme.default900Color,
                                  size: 30),
                            ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.employee_name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: BlocTheme.theme.default900Color,
                                  ),
                                ),
                                Text(
                                  "Eğitmen",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: BlocTheme.theme.default900Color
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (lesson.is_paid && hasActivePackage == false) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BlocTheme.theme.defaultRed700Color
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: BlocTheme.theme.defaultRed700Color
                                  .withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: BlocTheme.theme.defaultRed700Color,
                                size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lesson.only_purchased_members_can_register
                                    ? "Bu ders sadece paketi olan üyeler içindir. Rezervasyon için önce bu dersi satın almanız gereklidir."
                                    : "Bu ders ücretlidir. Rezervasyon yapabilmek için aktif bir branş paketinizin olması gerekmektedir.",
                                style: TextStyle(
                                  color: BlocTheme.theme.defaultRed700Color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Bilgi Kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Builder(
                        builder: (context) {
                          List<Widget> infoItems = [];

                          // 1. Ders Saati
                          infoItems.add(_buildInfoItem(
                            Icons.access_time_filled,
                            "Ders Saati",
                            "${lesson.plan_date} ${lesson.time}",
                          ));

                          // 2. Kontenjan
                          infoItems.add(_buildInfoItem(
                            Icons.event_available,
                            "Kontenjan",
                            "${lesson.person_limit} Kişi",
                          ));

                          // 2.5 Min Limit
                          if (lesson.min_limit > 0) {
                            infoItems.add(_buildInfoItem(
                              Icons.group_outlined,
                              "Min Katılım",
                              "${lesson.min_limit} Kişi",
                            ));
                          }

                          // 3. Açılış (Şartlı)
                          if (lesson.enable_time.trim().isNotEmpty &&
                              lesson.enable_time.trim() != "00:00:00" &&
                              lesson.enable_time.trim() != "00:00") {
                            infoItems.add(_buildInfoItem(
                              Icons.timer_outlined,
                              "Açılış",
                              lesson.enable_time,
                            ));
                          }

                          // 4. Durum
                          infoItems.add(_buildInfoItem(
                            lesson.is_paid
                                ? Icons.payments
                                : Icons.card_giftcard,
                            "Durum",
                            lesson.is_paid ? "Ücretli" : "Ücretsiz",
                            valueColor: lesson.is_paid
                                ? BlocTheme.theme.defaultRed700Color
                                : BlocTheme.theme.default900Color,
                          ));

                          // 5. Konum (Şartlı)
                          if (lesson.enable_seat_selection &&
                              lesson.seat_selection != null &&
                              lesson.seat_selection!.locations.isNotEmpty) {
                            infoItems.add(_buildInfoItem(
                              Icons.location_on,
                              "Konum",
                              lesson.seat_selection!.locations.first.name,
                            ));
                          }

                          // 6. Kısıt (Şartlı)
                          if (lesson.only_purchased_members_can_register) {
                            infoItems.add(_buildInfoItem(
                              Icons.verified_user,
                              "Kayıt Yetkisi",
                              "Dersi satın alanlar",
                              valueColor: BlocTheme.theme.defaultRed700Color,
                            ));
                          }

                          // İkili satırlar oluştur
                          List<Widget> rows = [];
                          for (int i = 0; i < infoItems.length; i += 2) {
                            rows.add(
                              Row(
                                children: [
                                  Expanded(child: infoItems[i]),
                                  if (i + 1 < infoItems.length)
                                    Expanded(child: infoItems[i + 1])
                                  else
                                    const Expanded(child: SizedBox()),
                                ],
                              ),
                            );
                            if (i + 2 < infoItems.length) {
                              rows.add(const SizedBox(height: 15));
                            }
                          }

                          return Column(children: rows);
                        },
                      ),
                    ),

                    if (lesson.explanation != "") ...[
                      const SizedBox(height: 25),
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lesson.explanation,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              BlocTheme.theme.default900Color.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),

                    // Doluluk Oranı
                    Text(
                      'Doluluk Oranı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BlocTheme.theme.default900Color,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: 35,
                                  sections: [
                                    PieChartSectionData(
                                      color: (lesson.person_count >=
                                              lesson.person_limit)
                                          ? BlocTheme.theme.defaultRed700Color
                                          : BlocTheme.theme.default900Color,
                                      value: lesson.person_count.toDouble(),
                                      showTitle: false,
                                      radius: 12,
                                    ),
                                    PieChartSectionData(
                                      color:
                                          BlocTheme.theme.defaultGray300Color,
                                      value: (lesson.person_limit -
                                              lesson.person_count)
                                          .toDouble(),
                                      showTitle: false,
                                      radius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${lesson.person_count}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: (lesson.person_count >=
                                            lesson.person_limit)
                                        ? BlocTheme.theme.defaultRed700Color
                                        : BlocTheme.theme.default900Color,
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: BlocTheme.theme.defaultGray300Color,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                ),
                                Text(
                                  '${lesson.person_limit}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: BlocTheme.theme.default900Color
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusIndicator(
                                "Mevcut Katılımcı",
                                "${lesson.person_count} Kişi",
                                (lesson.person_count >= lesson.person_limit)
                                    ? BlocTheme.theme.defaultRed700Color
                                    : BlocTheme.theme.default900Color,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusIndicator(
                                "Kalan Kontenjan",
                                "${lesson.person_limit - lesson.person_count} Kişi",
                                BlocTheme.theme.defaultGray500Color,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (lesson.enable_seat_selection &&
                        lesson.seat_selection != null &&
                        lesson.seat_selection!.locations.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      Text(
                        'Yer Seçimi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BlocTheme.theme.default900Color,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ],
                ),
              ),
              if (lesson.enable_seat_selection &&
                  lesson.seat_selection != null &&
                  lesson.seat_selection!.locations.isNotEmpty) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double minItemWidth = 100.0;
                    const double spacing = 10.0;
                    const double horizontalPadding = 20.0;
                    final double availableWidth =
                        constraints.maxWidth - (horizontalPadding * 2);

                    final int crossAxisCount =
                        ((availableWidth + spacing) / (minItemWidth + spacing))
                            .floor();
                    final int safeCrossAxisCount =
                        crossAxisCount > 0 ? crossAxisCount : 1;

                    final double totalSpacing =
                        (safeCrossAxisCount - 1) * spacing;
                    final double itemWidth =
                        (availableWidth - totalSpacing) / safeCrossAxisCount;

                    final allSeats = lesson.seat_selection!.locations
                        .expand((location) => location.seats)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: horizontalPadding),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: safeCrossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: itemWidth / 90,
                        ),
                        itemCount: allSeats.length,
                        itemBuilder: (context, index) {
                          final seat = allSeats[index];
                          final memberSelectedSeatId =
                              lesson.seat_selection?.member?.selected_seat_id;
                          final isReserved = lesson
                                  .seat_selection!.reserved_seat_ids
                                  .contains(seat.id) ||
                              (lesson.member_registered &&
                                  memberSelectedSeatId != null &&
                                  seat.id == memberSelectedSeatId);
                          final isSelectable = !isReserved &&
                              !lesson.member_registered &&
                              lesson.can_today_resarvation;

                          final bool showGreenBorder =
                              !lesson.member_registered &&
                                  selectedSeatId == seat.id &&
                                  !isReserved;
                          final bool showRedBorder = lesson.member_registered &&
                              memberSelectedSeatId != null &&
                              memberSelectedSeatId == seat.id;

                          Widget seatWidget = Container(
                            decoration: BoxDecoration(
                              color: BlocTheme.theme.defaultGray100Color,
                              borderRadius: BorderRadius.circular(15),
                              border: showGreenBorder
                                  ? Border.all(
                                      color: BlocTheme.theme.default700Color,
                                      width: 2,
                                    )
                                  : showRedBorder
                                      ? Border.all(
                                          color: BlocTheme
                                              .theme.defaultRed700Color,
                                          width: 2,
                                        )
                                      : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 35,
                                  color: isReserved
                                      ? BlocTheme.theme.defaultRed700Color
                                      : BlocTheme.theme.default800Color,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    seat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: BlocTheme.theme.default900Color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (isSelectable) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSeatId = seat.id;
                                });
                              },
                              child: seatWidget,
                            );
                          } else {
                            return seatWidget;
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      bottomSheet: (lesson.member_registered == true) ||
              (lesson.can_today_resarvation == true && lesson.remain_limit > 0)
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lesson.member_registered && lesson.is_paid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              color: BlocTheme.theme.defaultRed700Color,
                              size: 36),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Ücretli dersler sadece yönetim tarafından iptal edilmektedir.",
                              style: TextStyle(
                                color: BlocTheme.theme.defaultRed700Color,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lesson.member_registered == false
                            ? (lesson.enable_seat_selection &&
                                    selectedSeatId == null
                                ? BlocTheme.theme.defaultGray200Color
                                : BlocTheme.theme.default500Color)
                            : (lesson.is_paid
                                ? BlocTheme.theme.defaultGray400Color
                                : BlocTheme.theme.defaultRed700Color),
                        disabledBackgroundColor:
                            BlocTheme.theme.defaultGray300Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: (lesson.member_registered && lesson.is_paid)
                          ? null
                          : () async {
                              if (lesson.member_registered == false) {
                                int? packageId;
                                if (lesson.is_paid) {
                                  final package = await ResarvationService
                                      .getActiveBranchPackage(context,
                                          services_id: lesson
                                                  .only_purchased_members_can_register
                                              ? lesson.services_id
                                              : null);
                                  if (package == null) {
                                    await warningDialog(context,
                                        message: lesson
                                                .only_purchased_members_can_register
                                            ? "Bu ders sadece paketi olan üyeler içindir. Rezervasyon için önce bu dersi satın almanız gereklidir."
                                            : "Ücretli derse rezervasyon yaptırmak için önce satın almanız gereklidir.",
                                        path: BlocTheme.theme.subtractSvgPath);
                                    return;
                                  }
                                  packageId = int.tryParse(package.member_register_id ?? "");
                                }

                                if (lesson.enable_seat_selection &&
                                    selectedSeatId == null) {
                                  await warningDialog(context,
                                      message: "Lütfen bir yer seçiniz.",
                                      path: BlocTheme.theme.subtractSvgPath);
                                  return;
                                }
                                var message = lesson.service_plan_name +
                                    ' Grup dersine rezarvasyon yaptırmak istediğinize emin misiniz ?';
                                var result = await customConfirmationDialog(
                                    context,
                                    message: message,
                                    svgPath: BlocTheme.theme.attentionSvgPath);
                                if (result == true) {
                                  var response = await ResarvationService
                                      .addGroupLessonResarvation(context,
                                          service_plan_id: lesson.id,
                                          dayName: lesson.day_name,
                                          seated_location_id: selectedSeatId,
                                          member_register_id: packageId);

                                  if (response["output"] == false) {
                                    var errorText = (response["extras"] != ""
                                        ? response["extras"]
                                        : "Rezarvasyon oluşturulurken bir hata oluştu, lütfen daha sonra tekrar deneyiniz.");
                                    await warningDialog(context,
                                        message: errorText,
                                        path: BlocTheme.theme.subtractSvgPath);
                                  } else {
                                    await warningDialog(context,
                                        message:
                                            "Rezarvasyon başarıyla oluşturuldu.",
                                        path: BlocTheme.theme.attentionSvgPath);
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GroupLesson(),
                                        ),
                                        (route) => route.isFirst,
                                      );
                                    }
                                  }
                                }
                              } else {
                                var message = lesson.service_plan_name +
                                    ' Grup dersi rezarvasyonunu iptal etmek istediğinize emin misiniz ?';
                                var result = await customConfirmationDialog(
                                    context,
                                    message: message,
                                    svgPath: BlocTheme.theme.attentionSvgPath);
                                if (result == true) {
                                  var response = await ResarvationService
                                      .cancelGroupLessonResarvation(context,
                                          service_plan_id: lesson.id);

                                  if (response["output"] == false) {
                                    var errorText = (response["extras"] != ""
                                        ? response["extras"]
                                        : "Rezarvasyon iptal edilirken bir hata oluştu, lütfen daha sonra tekrar deneyiniz.");
                                    await warningDialog(context,
                                        message: errorText,
                                        path: BlocTheme.theme.subtractSvgPath);
                                  } else {
                                    await warningDialog(context,
                                        message:
                                            "Rezarvasyon başarıyla iptal edildi.",
                                        path: BlocTheme.theme.attentionSvgPath);
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GroupLesson(),
                                        ),
                                        (route) => route.isFirst,
                                      );
                                    }
                                  }
                                }
                              }
                            },
                      child: Text(
                        lesson.member_registered
                            ? "Randevuyu İptal Et"
                            : "Randevu Oluştur",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lesson.member_registered == false
                              ? (lesson.enable_seat_selection &&
                                      selectedSeatId == null
                                  ? BlocTheme.theme.defaultGray600Color
                                  : BlocTheme.theme.defaultGrayColor)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBarWidget(tab: NavTab.home),
    );
  }

  Widget _buildPriceBadge(GroupLessonModel data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.is_paid
            ? BlocTheme.theme.defaultRed700Color.withOpacity(0.1)
            : BlocTheme.theme.default900Color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        data.is_paid ? "Ücretli" : "Ücretsiz",
        style: TextStyle(
          color: data.is_paid
              ? BlocTheme.theme.defaultRed700Color
              : BlocTheme.theme.default900Color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: valueColor ?? BlocTheme.theme.default800Color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: BlocTheme.theme.default900Color.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? BlocTheme.theme.default900Color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: BlocTheme.theme.default900Color.withOpacity(0.5),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
